using FlorencaApi.Data;
using FlorencaApi.Models;
using FlorencaApi.Security;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FlorencaApi.Controllers;

[ApiController]
[Authorize]
[Route("api/[controller]")]
public class ComandasPedidosController : ControllerBase
{
    private static readonly string[] StatusPermitidos =
    {
        "ENVIADO",
        "EM_PREPARO",
        "ENTREGUE",
        "CANCELADO"
    };

    private readonly AppDbContext _context;

    public ComandasPedidosController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/comandaspedidos/usuario/1
    [HttpGet("usuario/{usuarioId:int}")]
    public async Task<IActionResult> ObterPorUsuario(int usuarioId)
    {
        if (!User.PodeAcessar(usuarioId))
            return Forbid();

        var pedidos = await _context.ComandasPedidos
            .AsNoTracking()
            .Where(p => p.UsuarioId == usuarioId)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();

        return Ok(pedidos);
    }

    // GET: api/comandaspedidos  (somente FUNCIONARIO - painel da cozinha)
    [Authorize(Roles = ClaimsExtensions.RoleFuncionario)]
    [HttpGet]
    public async Task<IActionResult> ObterTodos()
    {
        var pedidos = await _context.ComandasPedidos
            .AsNoTracking()
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();

        return Ok(pedidos);
    }

    // POST: api/comandaspedidos
    [HttpPost]
    public async Task<IActionResult> Criar([FromBody] PedidoRequest request)
    {
        var usuarioId = User.EhFuncionario() && request.UsuarioId > 0
            ? request.UsuarioId
            : User.ObterUsuarioId();

        if (request.ValorTotal < 0)
            return BadRequest(new { mensagem = "Valor total inválido." });

        var usuarioExiste = await _context.Usuarios.AnyAsync(u => u.Id == usuarioId);

        if (!usuarioExiste)
            return NotFound(new { mensagem = "Usuário não encontrado." });

        var pedido = new ComandaPedido
        {
            UsuarioId = usuarioId,
            ItensJson = request.ItensJson,
            ValorTotal = request.ValorTotal,
            Status = "ENVIADO"
        };

        _context.ComandasPedidos.Add(pedido);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(ObterPorId), new { id = pedido.Id }, pedido);
    }

    // GET: api/comandaspedidos/1
    [HttpGet("{id:int}")]
    public async Task<IActionResult> ObterPorId(int id)
    {
        var pedido = await _context.ComandasPedidos
            .AsNoTracking()
            .FirstOrDefaultAsync(p => p.Id == id);

        if (pedido == null)
            return NotFound(new { mensagem = "Pedido não encontrado." });

        if (!User.PodeAcessar(pedido.UsuarioId))
            return Forbid();

        return Ok(pedido);
    }

    // PUT: api/comandaspedidos/1/status  (somente FUNCIONARIO)
    [Authorize(Roles = ClaimsExtensions.RoleFuncionario)]
    [HttpPut("{id:int}/status")]
    public async Task<IActionResult> AlterarStatus(int id, [FromBody] AlterarStatusRequest request)
    {
        if (!StatusPermitidos.Contains(request.Status))
            return BadRequest(new { mensagem = "Status inválido." });

        var pedido = await _context.ComandasPedidos.FindAsync(id);

        if (pedido == null)
            return NotFound(new { mensagem = "Pedido não encontrado." });

        pedido.Status = request.Status;
        await _context.SaveChangesAsync();

        return Ok(pedido);
    }
}

public class AlterarStatusRequest
{
    public string Status { get; set; } = string.Empty;
}
