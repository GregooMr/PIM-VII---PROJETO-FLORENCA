using FlorencaApi.Data;
using FlorencaApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FlorencaApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class FilaVirtualController : ControllerBase
{
    private readonly AppDbContext _context;

    public FilaVirtualController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/filavirtual
    [HttpGet]
    public async Task<IActionResult> ObterTodos()
    {
        var fila = await _context.FilaVirtual
            .AsNoTracking()
            .OrderBy(f => f.CreatedAt)
            .ToListAsync();

        return Ok(fila);
    }

    // GET: api/filavirtual/usuario/1
    [HttpGet("usuario/{usuarioId:int}")]
    public async Task<IActionResult> ObterPorUsuario(int usuarioId)
    {
        var fila = await _context.FilaVirtual
            .AsNoTracking()
            .Where(f => f.UsuarioId == usuarioId)
            .OrderByDescending(f => f.CreatedAt)
            .ToListAsync();

        return Ok(fila);
    }

    // POST: api/filavirtual
    [HttpPost]
    public async Task<IActionResult> Entrar([FromBody] FilaVirtual entrada)
    {
        if (entrada.UsuarioId <= 0)
            return BadRequest(new { mensagem = "Usuário inválido." });

        if (entrada.QtdPessoas <= 0)
            return BadRequest(new { mensagem = "A quantidade de pessoas deve ser maior que zero." });

        var usuarioExiste = await _context.Usuarios
            .AnyAsync(u => u.Id == entrada.UsuarioId);

        if (!usuarioExiste)
            return NotFound(new { mensagem = "Usuário não encontrado." });

        var jaNaFila = await _context.FilaVirtual.AnyAsync(f =>
            f.UsuarioId == entrada.UsuarioId &&
            f.Status == "AGUARDANDO");

        if (jaNaFila)
            return Conflict(new { mensagem = "Você já está na fila virtual." });

        entrada.Status = "AGUARDANDO";

        _context.FilaVirtual.Add(entrada);
        await _context.SaveChangesAsync();

        return CreatedAtAction(
            nameof(ObterPorUsuario),
            new { usuarioId = entrada.UsuarioId },
            entrada);
    }

    // PUT: api/filavirtual/1/chamar
    [HttpPut("{id:int}/chamar")]
    public async Task<IActionResult> Chamar(int id)
    {
        var entrada = await _context.FilaVirtual.FindAsync(id);

        if (entrada == null)
            return NotFound(new { mensagem = "Entrada da fila não encontrada." });

        if (entrada.Status != "AGUARDANDO")
            return BadRequest(new { mensagem = "Esta entrada não está aguardando." });

        entrada.Status = "MESA_PRONTA";
        await _context.SaveChangesAsync();

        return Ok(entrada);
    }

    // PUT: api/filavirtual/1/cancelar
    [HttpPut("{id:int}/cancelar")]
    public async Task<IActionResult> Cancelar(int id)
    {
        var entrada = await _context.FilaVirtual.FindAsync(id);

        if (entrada == null)
            return NotFound(new { mensagem = "Entrada da fila não encontrada." });

        if (entrada.Status != "AGUARDANDO")
            return BadRequest(new { mensagem = "Esta entrada não está aguardando." });

        entrada.Status = "CANCELADO";
        await _context.SaveChangesAsync();

        return Ok(entrada);
    }
}
