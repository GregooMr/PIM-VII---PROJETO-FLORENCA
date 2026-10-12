using FlorencaApi.Data;
using FlorencaApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FlorencaApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class FavoritosController : ControllerBase
{
    private readonly AppDbContext _context;

    public FavoritosController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/favoritos/usuario/1
    [HttpGet("usuario/{usuarioId:int}")]
    public async Task<IActionResult> ObterPorUsuario(int usuarioId)
    {
        var favoritos = await _context.Favoritos
            .AsNoTracking()
            .Where(f => f.UsuarioId == usuarioId)
            .OrderByDescending(f => f.CreatedAt)
            .ToListAsync();

        return Ok(favoritos);
    }

    // POST: api/favoritos
    [HttpPost]
    public async Task<IActionResult> Adicionar([FromBody] Favorito favorito)
    {
        if (favorito.UsuarioId <= 0 ||
            string.IsNullOrWhiteSpace(favorito.PratoNome))
        {
            return BadRequest(new { mensagem = "Usuário e prato são obrigatórios." });
        }

        var existe = await _context.Favoritos.AnyAsync(f =>
            f.UsuarioId == favorito.UsuarioId &&
            f.PratoNome == favorito.PratoNome);

        if (existe)
            return Conflict(new { mensagem = "Este prato já está nos favoritos." });

        _context.Favoritos.Add(favorito);
        await _context.SaveChangesAsync();

        return CreatedAtAction(
            nameof(ObterPorUsuario),
            new { usuarioId = favorito.UsuarioId },
            favorito);
    }

    // DELETE: api/favoritos/1
    [HttpDelete("{id:int}")]
    public async Task<IActionResult> Remover(int id)
    {
        var favorito = await _context.Favoritos.FindAsync(id);

        if (favorito == null)
            return NotFound(new { mensagem = "Favorito não encontrado." });

        _context.Favoritos.Remove(favorito);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
