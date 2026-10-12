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
        if (!User.PodeAcessar(usuarioId))
            return Forbid();

        var favoritos = await _context.Favoritos
            .AsNoTracking()
            .Where(f => f.UsuarioId == usuarioId)
            .OrderByDescending(f => f.CreatedAt)
            .ToListAsync();

        return Ok(favoritos);
    }

    // POST: api/favoritos
    [HttpPost]
    public async Task<IActionResult> Adicionar([FromBody] FavoritoRequest request)
    {
        var usuarioId = User.EhFuncionario() && request.UsuarioId > 0
            ? request.UsuarioId
            : User.ObterUsuarioId();

        var existe = await _context.Favoritos.AnyAsync(f =>
            f.UsuarioId == usuarioId &&
            f.PratoNome == request.PratoNome);

        if (existe)
            return Conflict(new { mensagem = "Este prato já está nos favoritos." });

        var favorito = new Favorito
        {
            UsuarioId = usuarioId,
            PratoNome = request.PratoNome.Trim(),
            Preco = request.Preco
        };

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

        if (!User.PodeAcessar(favorito.UsuarioId))
            return Forbid();

        _context.Favoritos.Remove(favorito);
        await _context.SaveChangesAsync();

        return NoContent();
    }
}
