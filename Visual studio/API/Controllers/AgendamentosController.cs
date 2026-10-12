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
public class AgendamentosController : ControllerBase
{
    private readonly AppDbContext _context;

    public AgendamentosController(AppDbContext context)
    {
        _context = context;
    }

    // GET: api/agendamentos  (somente FUNCIONARIO)
    [Authorize(Roles = ClaimsExtensions.RoleFuncionario)]
    [HttpGet]
    public async Task<IActionResult> ObterTodos()
    {
        var lista = await _context.Agendamentos
            .AsNoTracking()
            .OrderByDescending(a => a.DataHora)
            .ToListAsync();

        return Ok(lista);
    }

    // GET: api/agendamentos/usuario/1
    [HttpGet("usuario/{usuarioId:int}")]
    public async Task<IActionResult> ObterPorUsuario(int usuarioId)
    {
        if (!User.PodeAcessar(usuarioId))
            return Forbid();

        var lista = await _context.Agendamentos
            .AsNoTracking()
            .Where(a => a.UsuarioId == usuarioId)
            .OrderBy(a => a.DataHora)
            .ToListAsync();

        return Ok(lista);
    }

    // POST: api/agendamentos
    [HttpPost]
    public async Task<IActionResult> Criar([FromBody] AgendamentoRequest request)
    {
        // Cliente só reserva para si mesmo; funcionário pode reservar em nome de um cliente.
        var usuarioId = User.EhFuncionario() && request.UsuarioId > 0
            ? request.UsuarioId
            : User.ObterUsuarioId();

        if (request.DataHora <= DateTime.Now)
            return BadRequest(new { mensagem = "A data da reserva deve ser futura." });

        if (request.QtdPessoas <= 0)
            return BadRequest(new { mensagem = "A quantidade de pessoas deve ser maior que zero." });

        if (request.IsPcd && string.IsNullOrWhiteSpace(request.TipoPcd))
            return BadRequest(new { mensagem = "Informe o tipo de necessidade para a reserva acessível." });

        var usuarioExiste = await _context.Usuarios.AnyAsync(u => u.Id == usuarioId);

        if (!usuarioExiste)
            return NotFound(new { mensagem = "Usuário não encontrado." });

        var reserva = new Agendamento
        {
            UsuarioId = usuarioId,
            DataHora = request.DataHora,
            QtdPessoas = request.QtdPessoas,
            IsPcd = request.IsPcd,
            NomePcd = request.IsPcd ? request.NomePcd : null,
            TipoPcd = request.IsPcd ? request.TipoPcd : null,
            Status = "CONFIRMADO"
        };

        _context.Agendamentos.Add(reserva);
        await _context.SaveChangesAsync();

        return CreatedAtAction(nameof(ObterPorId), new { id = reserva.Id }, reserva);
    }

    // GET: api/agendamentos/1
    [HttpGet("{id:int}")]
    public async Task<IActionResult> ObterPorId(int id)
    {
        var reserva = await _context.Agendamentos
            .AsNoTracking()
            .FirstOrDefaultAsync(a => a.Id == id);

        if (reserva == null)
            return NotFound(new { mensagem = "Agendamento não encontrado." });

        if (!User.PodeAcessar(reserva.UsuarioId))
            return Forbid();

        return Ok(reserva);
    }

    // PUT: api/agendamentos/1/cancelar
    [HttpPut("{id:int}/cancelar")]
    public async Task<IActionResult> Cancelar(int id)
    {
        var reserva = await _context.Agendamentos.FindAsync(id);

        if (reserva == null)
            return NotFound(new { mensagem = "Agendamento não encontrado." });

        if (!User.PodeAcessar(reserva.UsuarioId))
            return Forbid();

        if (reserva.Status == "CONCLUIDO")
            return BadRequest(new { mensagem = "Não é possível cancelar uma reserva concluída." });

        reserva.Status = "CANCELADO";
        await _context.SaveChangesAsync();

        return Ok(reserva);
    }
}
