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
public class FilaVirtualController : ControllerBase
{
    private readonly AppDbContext _context;

    public FilaVirtualController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/filavirtual  (somente FUNCIONARIO - recepção)
    [Authorize(Roles = ClaimsExtensions.RoleFuncionario)]
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
        if (!User.PodeAcessar(usuarioId))
            return Forbid();

        var fila = await _context.FilaVirtual
            .AsNoTracking()
            .Where(f => f.UsuarioId == usuarioId)
            .OrderByDescending(f => f.CreatedAt)
            .ToListAsync();

        return Ok(fila);
    }

    // POST: api/filavirtual
    [HttpPost]
    public async Task<IActionResult> Entrar([FromBody] FilaRequest request)
    {
        var usuarioId = User.EhFuncionario() && request.UsuarioId > 0
            ? request.UsuarioId
            : User.ObterUsuarioId();

        if (request.QtdPessoas <= 0)
            return BadRequest(new { mensagem = "A quantidade de pessoas deve ser maior que zero." });

        var usuarioExiste = await _context.Usuarios.AnyAsync(u => u.Id == usuarioId);

        if (!usuarioExiste)
            return NotFound(new { mensagem = "Usuário não encontrado." });

        var jaNaFila = await _context.FilaVirtual.AnyAsync(f =>
            f.UsuarioId == usuarioId &&
            f.Status == "AGUARDANDO");

        if (jaNaFila)
            return Conflict(new { mensagem = "Você já está na fila virtual." });

        var entrada = new FilaVirtual
        {
            UsuarioId = usuarioId,
            QtdPessoas = request.QtdPessoas,
            Status = "AGUARDANDO"
        };

        _context.FilaVirtual.Add(entrada);
        await _context.SaveChangesAsync();

        return CreatedAtAction(
            nameof(ObterPorUsuario),
            new { usuarioId = entrada.UsuarioId },
            entrada);
    }

    // PUT: api/filavirtual/1/chamar  (somente FUNCIONARIO)
    [Authorize(Roles = ClaimsExtensions.RoleFuncionario)]
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

    // PUT: api/filavirtual/1/cancelar  (dono da entrada ou FUNCIONARIO)
    [HttpPut("{id:int}/cancelar")]
    public async Task<IActionResult> Cancelar(int id)
    {
        var entrada = await _context.FilaVirtual.FindAsync(id);

        if (entrada == null)
            return NotFound(new { mensagem = "Entrada da fila não encontrada." });

        if (!User.PodeAcessar(entrada.UsuarioId))
            return Forbid();

        if (entrada.Status != "AGUARDANDO")
            return BadRequest(new { mensagem = "Esta entrada não está aguardando." });

        entrada.Status = "CANCELADO";
        await _context.SaveChangesAsync();

        return Ok(entrada);
    }
}
