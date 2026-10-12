using FlorencaApi.Data;
using FlorencaApi.Models;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FlorencaApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsuariosController : ControllerBase
{
    private readonly AppDbContext _context;

    public UsuariosController(AppDbContext context)
    {
        _context = context;
    }

    // POST: api/usuarios/login
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Usuario) ||
            string.IsNullOrWhiteSpace(request.Senha))
        {
            return BadRequest(new { mensagem = "Usuário e senha são obrigatórios." });
        }

        var user = await _context.Usuarios
            .AsNoTracking()
            .FirstOrDefaultAsync(u =>
                u.LoginUsuario == request.Usuario &&
                u.Senha == request.Senha);

        if (user == null)
        {
            return Unauthorized(new { mensagem = "Usuário ou senha incorretos." });
        }

        return Ok(new UsuarioResponse
        {
            Id = user.Id,
            Nome = user.Nome,
            Usuario = user.LoginUsuario,
            TipoUsuario = user.TipoUsuario
        });
    }

    // POST: api/usuarios/cadastrar
    [HttpPost("cadastrar")]
    public async Task<IActionResult> Cadastrar([FromBody] Usuario novoUser)
    {
        if (string.IsNullOrWhiteSpace(novoUser.Nome) ||
            string.IsNullOrWhiteSpace(novoUser.LoginUsuario) ||
            string.IsNullOrWhiteSpace(novoUser.Senha))
        {
            return BadRequest(new { mensagem = "Nome, usuário e senha são obrigatórios." });
        }

        var usuarioExiste = await _context.Usuarios
            .AnyAsync(u => u.LoginUsuario == novoUser.LoginUsuario);

        if (usuarioExiste)
        {
            return Conflict(new { mensagem = "Este nome de usuário já está cadastrado." });
        }

        // Usuários criados pelo aplicativo sempre entram como CLIENTE.
        novoUser.TipoUsuario = "CLIENTE";

        _context.Usuarios.Add(novoUser);
        await _context.SaveChangesAsync();

        return CreatedAtAction(
            nameof(ObterPorId),
            new { id = novoUser.Id },
            new UsuarioResponse
            {
                Id = novoUser.Id,
                Nome = novoUser.Nome,
                Usuario = novoUser.LoginUsuario,
                TipoUsuario = novoUser.TipoUsuario
            });
    }

    // GET: api/usuarios/1
    [HttpGet("{id:int}")]
    public async Task<IActionResult> ObterPorId(int id)
    {
        var user = await _context.Usuarios
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.Id == id);

        if (user == null)
            return NotFound(new { mensagem = "Usuário não encontrado." });

        return Ok(new UsuarioResponse
        {
            Id = user.Id,
            Nome = user.Nome,
            Usuario = user.LoginUsuario,
            TipoUsuario = user.TipoUsuario
        });
    }
}
