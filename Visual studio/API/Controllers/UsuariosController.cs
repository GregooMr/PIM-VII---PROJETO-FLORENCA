using FlorencaApi.Data;
using FlorencaApi.Models;
using FlorencaApi.Security;
using FlorencaApi.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace FlorencaApi.Controllers;

[ApiController]
[Route("api/[controller]")]
public class UsuariosController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly TokenService _tokenService;

    public UsuariosController(AppDbContext context, TokenService tokenService)
    {
        _context = context;
        _tokenService = tokenService;
    }

    // POST: api/usuarios/login  (público)
    [AllowAnonymous]
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        if (string.IsNullOrWhiteSpace(request.Usuario) ||
            string.IsNullOrWhiteSpace(request.Senha))
        {
            return BadRequest(new { mensagem = "Usuário e senha são obrigatórios." });
        }

        // 1) Busca pelo login (consulta parametrizada pelo EF Core)
        var user = await _context.Usuarios
            .AsNoTracking()
            .FirstOrDefaultAsync(u => u.LoginUsuario == request.Usuario);

        // 2) Compara a senha digitada com o hash BCrypt armazenado.
        //    A mesma mensagem é usada para usuário inexistente e senha errada,
        //    evitando revelar quais logins existem.
        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Senha, user.Senha))
        {
            return Unauthorized(new { mensagem = "Usuário ou senha incorretos." });
        }

        // 3) Gera o JWT com id, nome e perfil (role)
        return Ok(new UsuarioResponse
        {
            Id = user.Id,
            Nome = user.Nome,
            Usuario = user.LoginUsuario,
            TipoUsuario = user.TipoUsuario,
            Token = _tokenService.Gerar(user)
        });
    }

    // POST: api/usuarios/cadastrar  (público)
    [AllowAnonymous]
    [HttpPost("cadastrar")]
    public async Task<IActionResult> Cadastrar([FromBody] CadastroRequest request)
    {
        var login = request.Usuario.Trim();

        var usuarioExiste = await _context.Usuarios
            .AnyAsync(u => u.LoginUsuario == login);

        if (usuarioExiste)
        {
            return Conflict(new { mensagem = "Este nome de usuário já está cadastrado." });
        }

        var novoUser = new Usuario
        {
            Nome = request.Nome.Trim(),
            LoginUsuario = login,
            Senha = BCrypt.Net.BCrypt.HashPassword(request.Senha),
            // Cadastro público SEMPRE cria CLIENTE. Contas de funcionário
            // só podem ser criadas por quem administra o banco de dados.
            TipoUsuario = ClaimsExtensions.RoleCliente
        };

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

    // GET: api/usuarios  (somente FUNCIONARIO) - usado pelo painel web
    [Authorize(Roles = ClaimsExtensions.RoleFuncionario)]
    [HttpGet]
    public async Task<IActionResult> ObterTodos()
    {
        var lista = await _context.Usuarios
            .AsNoTracking()
            .OrderBy(u => u.Nome)
            .Select(u => new UsuarioResponse
            {
                Id = u.Id,
                Nome = u.Nome,
                Usuario = u.LoginUsuario,
                TipoUsuario = u.TipoUsuario
            })
            .ToListAsync();

        return Ok(lista);
    }

    // GET: api/usuarios/1  (o próprio usuário ou FUNCIONARIO)
    [Authorize]
    [HttpGet("{id:int}")]
    public async Task<IActionResult> ObterPorId(int id)
    {
        if (!User.PodeAcessar(id))
            return Forbid();

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
