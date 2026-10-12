using FlorencaAdmin.Models;
using FlorencaAdmin.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FlorencaAdmin.Controllers;

/// <summary>Painel da cozinha (KDS): acompanha e atualiza o preparo dos pedidos.</summary>
[Authorize(Roles = "FUNCIONARIO")]
public class PedidosController : Controller
{
    private static readonly string[] StatusValidos = { "EM_PREPARO", "ENTREGUE", "CANCELADO" };
    private readonly ApiClient _api;

    public PedidosController(ApiClient api)
    {
        _api = api;
    }

    public async Task<IActionResult> Index()
    {
        var pedidosTask = _api.ObterPedidosAsync();
        var nomesTask = _api.ObterNomesAsync();
        await Task.WhenAll(pedidosTask, nomesTask);

        var pedidos = pedidosTask.Result;

        var modelo = new PedidosViewModel
        {
            // Os mais antigos primeiro: a cozinha atende por ordem de chegada.
            Novos = pedidos.Where(p => p.Status == "ENVIADO").OrderBy(p => p.CreatedAt).ToList(),
            EmPreparo = pedidos.Where(p => p.Status == "EM_PREPARO").OrderBy(p => p.CreatedAt).ToList(),
            Finalizados = pedidos
                .Where(p => p.Status == "ENTREGUE" || p.Status == "CANCELADO")
                .OrderByDescending(p => p.CreatedAt)
                .Take(10)
                .ToList(),
            Nomes = nomesTask.Result
        };

        return View(modelo);
    }

    [HttpPost]
    public async Task<IActionResult> AlterarStatus(int id, string status)
    {
        if (!StatusValidos.Contains(status))
        {
            TempData["Erro"] = "Status inválido.";
            return RedirectToAction(nameof(Index));
        }

        var resultado = await _api.AlterarStatusPedidoAsync(id, status);

        if (resultado.Sucesso)
            TempData["Sucesso"] = $"Pedido #{id} atualizado para {status.Replace('_', ' ').ToLowerInvariant()}.";
        else
            TempData["Erro"] = resultado.Mensagem;

        return RedirectToAction(nameof(Index));
    }
}
