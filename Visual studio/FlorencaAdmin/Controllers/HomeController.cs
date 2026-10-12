using FlorencaAdmin.Models;
using FlorencaAdmin.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FlorencaAdmin.Controllers;

[Authorize(Roles = "FUNCIONARIO")]
public class HomeController : Controller
{
    private readonly ApiClient _api;

    public HomeController(ApiClient api)
    {
        _api = api;
    }

    public async Task<IActionResult> Index()
    {
        var pedidosTask = _api.ObterPedidosAsync();
        var filaTask = _api.ObterFilaAsync();
        var reservasTask = _api.ObterAgendamentosAsync();
        var cuponsTask = _api.ObterCuponsAsync();

        await Task.WhenAll(pedidosTask, filaTask, reservasTask, cuponsTask);

        var agora = DateTime.Now;

        var modelo = new DashboardViewModel
        {
            PedidosNovos = pedidosTask.Result.Count(p => p.Status == "ENVIADO"),
            PedidosEmPreparo = pedidosTask.Result.Count(p => p.Status == "EM_PREPARO"),
            FilaAguardando = filaTask.Result.Count(f => f.Status == "AGUARDANDO"),
            ReservasHoje = reservasTask.Result.Count(r =>
                r.Status == "CONFIRMADO" && r.DataHora.Date == agora.Date),
            ReservasPcdFuturas = reservasTask.Result.Count(r =>
                r.Status == "CONFIRMADO" && r.IsPcd && r.DataHora >= agora),
            CuponsDisponiveis = cuponsTask.Result.Count(c => !c.IsUsado)
        };

        return View(modelo);
    }

    [AllowAnonymous]
    public IActionResult Erro() => View("Erro", "Ocorreu um erro inesperado. Tente novamente.");
}
