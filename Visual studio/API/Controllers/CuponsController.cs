using FlorencaApi.Data;
using FlorencaApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FlorencaApi.Controllers;

[ApiController]
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
        var cupons = await _context.Cupons
            .AsNoTracking()
            .Where(c => c.UsuarioId == usuarioId)
            .OrderByDescending(c => c.CreatedAt)
            .ToListAsync();

        return Ok(cupons);
    }

    // POST: api/cupons
    [HttpPost]
    public async Task<IActionResult> Criar([FromBody] Cupom cupom)
    {
        if (cupom.UsuarioId <= 0 ||
            string.IsNullOrWhiteSpace(cupom.NomePromocao) ||
            string.IsNullOrWhiteSpace(cupom.CodigoCupom))
        {
            return BadRequest(new { mensagem = "Usuário, promoção e código são obrigatórios." });
        }

        var usuarioExiste = await _context.Usuarios
            .AnyAsync(u => u.Id == cupom.UsuarioId);

        if (!usuarioExiste)
            return NotFound(new { mensagem = "Usuário não encontrado." });

        var codigoExiste = await _context.Cupons
            .AnyAsync(c => c.CodigoCupom == cupom.CodigoCupom);

        if (codigoExiste)
            return Conflict(new { mensagem = "Código de cupom já existente." });

        cupom.IsUsado = false;
        _context.Cupons.Add(cupom);
        await _context.SaveChangesAsync();

        return CreatedAtAction(
            nameof(ObterPorUsuario),
            new { usuarioId = cupom.UsuarioId },
            cupom);
    }

    // POST: api/cupons/validar
    [HttpPost("validar")]
    public async Task<IActionResult> Validar([FromBody] ValidarCupomRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.CodigoCupom))
            return BadRequest(new { mensagem = "Código do cupom é obrigatório." });

        var cupom = await _context.Cupons
            .FirstOrDefaultAsync(c =>
                c.UsuarioId == request.UsuarioId &&
                c.CodigoCupom == request.CodigoCupom);

        if (cupom == null)
            return NotFound(new { mensagem = "Cupom não encontrado." });

        if (cupom.IsUsado)
            return BadRequest(new { mensagem = "Este cupom já foi utilizado." });

        return Ok(cupom);
    }

    // POST: api/cupons/validar-funcionario
    [HttpPost("validar-funcionario")]
    public async Task<IActionResult> ValidarFuncionario([FromBody] ValidarCodigoRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.CodigoCupom))
            return BadRequest(new { mensagem = "Código do cupom é obrigatório." });

        var cupom = await _context.Cupons
            .FirstOrDefaultAsync(c => c.CodigoCupom == request.CodigoCupom);

        if (cupom == null)
            return NotFound(new { mensagem = "Cupom não encontrado." });

        if (cupom.IsUsado)
            return BadRequest(new { mensagem = "Este cupom já foi utilizado." });

        return Ok(cupom);
    }

    // PUT: api/cupons/1/usar
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
