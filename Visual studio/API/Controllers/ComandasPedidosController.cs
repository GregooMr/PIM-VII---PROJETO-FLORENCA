using FlorencaApi.Data;
using FlorencaApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FlorencaApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ComandasPedidosController : ControllerBase
{
    private readonly AppDbContext _context;

    public ComandasPedidosController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/comandaspedidos/usuario/1
    [HttpGet("usuario/{usuarioId:int}")]
    public async Task<IActionResult> ObterPorUsuario(int usuarioId)
    {
        var pedidos = await _context.ComandasPedidos
            .AsNoTracking()
            .Where(p => p.UsuarioId == usuarioId)
            .OrderByDescending(p => p.CreatedAt)
            .ToListAsync();

        return Ok(pedidos);
    }

    // GET: api/comandaspedidos
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
    public async Task<IActionResult> Criar([FromBody] ComandaPedido pedido)
    {
        if (pedido.UsuarioId <= 0)
            return BadRequest(new { mensagem = "Usuário inválido." });

        if (pedido.ValorTotal < 0)
            return BadRequest(new { mensagem = "Valor total inválido." });

        var usuarioExiste = await _context.Usuarios
            .AnyAsync(u => u.Id == pedido.UsuarioId);

        if (!usuarioExiste)
            return NotFound(new { mensagem = "Usuário não encontrado." });

        pedido.Status = "ENVIADO";

        _context.ComandasPedidos.Add(pedido);
        await _context.SaveChangesAsync();

        return CreatedAtAction(
            nameof(ObterPorId),
            new { id = pedido.Id },
            pedido);
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

        return Ok(pedido);
    }

    // PUT: api/comandaspedidos/1/status
    [HttpPut("{id:int}/status")]
    public async Task<IActionResult> AlterarStatus(int id, [FromBody] AlterarStatusRequest request)
    {
        var statusPermitidos = new[]
        {
            "ENVIADO",
            "EM_PREPARO",
            "ENTREGUE",
            "CANCELADO"
        };

        if (!statusPermitidos.Contains(request.Status))
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
