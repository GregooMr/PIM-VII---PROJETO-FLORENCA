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
public class CuponsController : ControllerBase
{
    private readonly AppDbContext _context;

    public CuponsController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/cupons/usuario/1
    [HttpGet("usuario/{usuarioId:int}")]
    public async Task<IActionResult> ObterPorUsuario(int usuarioId)
    {
        if (!User.PodeAcessar(usuarioId))
            return Forbid();

        var cupons = await _context.Cupons
            .AsNoTracking()
            .Where(c => c.UsuarioId == usuarioId)
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();

        return Ok(cupons);
    }

    // GET: api/cupons  (somente FUNCIONARIO - painel web)
    [Authorize(Roles = ClaimsExtensions.RoleFuncionario)]
    [HttpGet]
    public async Task<IActionResult> ObterTodos()
    {
        var cupons = await _context.Cupons
            .AsNoTracking()
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();

        return Ok(cupons);
    }

    // POST: api/cupons  (somente FUNCIONARIO emite cupons)
    [Authorize(Roles = ClaimsExtensions.RoleFuncionario)]
    [HttpPost]
    public async Task<IActionResult> Criar([FromBody] CupomRequest request)
    {
        var codigo = request.CodigoCupom.Trim().ToUpperInvariant();

        var usuarioExiste = await _context.Usuarios
            .AnyAsync(u => u.Id == request.UsuarioId);

        if (!usuarioExiste)
            return NotFound(new { mensagem = "Usuário não encontrado." });

        var codigoExiste = await _context.Cupons
            .AnyAsync(c => c.CodigoCupom == codigo);

        if (codigoExiste)
            return Conflict(new { mensagem = "Código de cupom já existente." });

        var cupom = new Cupom
        {
            UsuarioId = request.UsuarioId,
            NomePromocao = request.NomePromocao.Trim(),
            CodigoCupom = codigo,
            IsUsado = false
        };

        _context.Cupons.Add(cupom);
        await _context.SaveChangesAsync();

        return CreatedAtAction(
            nameof(ObterPorUsuario),
            new { usuarioId = cupom.UsuarioId },
            cupom);
    }

    // POST: api/cupons/validar  (o dono do cupom ou FUNCIONARIO)
    [HttpPost("validar")]
    public async Task<IActionResult> Validar([FromBody] ValidarCupomRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.CodigoCupom))
            return BadRequest(new { mensagem = "Código do cupom é obrigatório." });

        // Cliente só valida cupom próprio, mesmo que envie outro UsuarioId no corpo.
        var usuarioId = User.EhFuncionario() && request.UsuarioId > 0
            ? request.UsuarioId
            : User.ObterUsuarioId();

        var codigo = request.CodigoCupom.Trim().ToUpperInvariant();

        var cupom = await _context.Cupons
            .FirstOrDefaultAsync(c =>
                c.UsuarioId == usuarioId &&
                c.CodigoCupom == codigo);

        if (cupom == null)
            return NotFound(new { mensagem = "Cupom não encontrado." });

        if (cupom.IsUsado)
            return BadRequest(new { mensagem = "Este cupom já foi utilizado." });

        return Ok(cupom);
    }

    // POST: api/cupons/validar-funcionario  (somente FUNCIONARIO - caixa)
    [Authorize(Roles = ClaimsExtensions.RoleFuncionario)]
    [HttpPost("validar-funcionario")]
    public async Task<IActionResult> ValidarFuncionario([FromBody] ValidarCodigoRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.CodigoCupom))
            return BadRequest(new { mensagem = "Código do cupom é obrigatório." });

        var codigo = request.CodigoCupom.Trim().ToUpperInvariant();

        var cupom = await _context.Cupons
            .FirstOrDefaultAsync(c => c.CodigoCupom == codigo);

        if (cupom == null)
            return NotFound(new { mensagem = "Cupom não encontrado." });

        if (cupom.IsUsado)
            return BadRequest(new { mensagem = "Este cupom já foi utilizado." });

        return Ok(cupom);
    }

    // PUT: api/cupons/1/usar  (somente FUNCIONARIO dá baixa no caixa)
    [Authorize(Roles = ClaimsExtensions.RoleFuncionario)]
    [HttpPut("{id:int}/usar")]
    public async Task<IActionResult> Usar(int id)
    {
        var cupom = await _context.Cupons.FindAsync(id);

        if (cupom == null)
            return NotFound(new { mensagem = "Cupom não encontrado." });

        if (cupom.IsUsado)
            return BadRequest(new { mensagem = "Este cupom já foi utilizado." });

        cupom.IsUsado = true;
        await _context.SaveChangesAsync();

        return Ok(cupom);
    }
}

public class ValidarCupomRequest
{
    public int UsuarioId { get; set; }
    public string CodigoCupom { get; set; } = string.Empty;
}

public class ValidarCodigoRequest
{
    public string CodigoCupom { get; set; } = string.Empty;
}
