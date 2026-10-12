using FlorencaAdmin.Models;
using FlorencaAdmin.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FlorencaAdmin.Controllers;

/// <summary>Monitoramento de reservas, com destaque para mesas acessíveis (PCD).</summary>
[Authorize(Roles = "FUNCIONARIO")]
public class AgendamentosController : Controller
{
    private readonly ApiClient _api;

    public AgendamentosController(ApiClient api)
    {
        _api = api;
    }

    public async Task<IActionResult> Index(bool somentePcd = false, bool incluirPassadas = false)
    {
        var reservasTask = _api.ObterAgendamentosAsync();
        var nomesTask = _api.ObterNomesAsync();
        await Task.WhenAll(reservasTask, nomesTask);

        var reservas = reservasTask.Result.AsEnumerable();

        if (somentePcd)
            reservas = reservas.Where(r => r.IsPcd);

        // Por padrão oculta dias anteriores. (Checkbox desmarcado não envia valor,
        // por isso o parâmetro é "incluirPassadas" com padrão false.)
        if (!incluirPassadas)
            reservas = reservas.Where(r => r.DataHora >= DateTime.Today);

        var modelo = new AgendamentosViewModel
        {
            Reservas = reservas.OrderBy(r => r.DataHora).ToList(),
            Nomes = nomesTask.Result,
            SomentePcd = somentePcd,
            SomenteFuturas = !incluirPassadas
        };

        return View(modelo);
    }

    [HttpPost]
    public async Task<IActionResult> Cancelar(int id)
    {
        var resultado = await _api.CancelarAgendamentoAsync(id);

        if (resultado.Sucesso) TempData["Sucesso"] = $"Reserva #{id} cancelada.";
        else TempData["Erro"] = resultado.Mensagem;

        return RedirectToAction(nameof(Index));
    }
}
