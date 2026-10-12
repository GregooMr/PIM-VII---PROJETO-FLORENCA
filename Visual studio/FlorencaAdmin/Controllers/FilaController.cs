using FlorencaAdmin.Models;
using FlorencaAdmin.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FlorencaAdmin.Controllers;

/// <summary>Painel da recepção: fila de espera virtual.</summary>
[Authorize(Roles = "FUNCIONARIO")]
public class FilaController : Controller
{
    private readonly ApiClient _api;

    public FilaController(ApiClient api)
    {
        _api = api;
    }

    public async Task<IActionResult> Index()
    {
        var filaTask = _api.ObterFilaAsync();
        var nomesTask = _api.ObterNomesAsync();
        await Task.WhenAll(filaTask, nomesTask);

        var fila = filaTask.Result;

        var modelo = new FilaViewModel
        {
            Aguardando = fila.Where(f => f.Status == "AGUARDANDO").OrderBy(f => f.CreatedAt).ToList(),
            MesaPronta = fila.Where(f => f.Status == "MESA_PRONTA").OrderBy(f => f.CreatedAt).ToList(),
            Nomes = nomesTask.Result
        };

        return View(modelo);
    }

    [HttpPost]
    public async Task<IActionResult> Chamar(int id)
    {
        var resultado = await _api.ChamarFilaAsync(id);
        Notificar(resultado, "Cliente chamado: mesa pronta.");
        return RedirectToAction(nameof(Index));
    }

    [HttpPost]
    public async Task<IActionResult> Cancelar(int id)
    {
        var resultado = await _api.CancelarFilaAsync(id);
        Notificar(resultado, "Entrada removida da fila.");
        return RedirectToAction(nameof(Index));
    }

    private void Notificar(ResultadoApi resultado, string mensagemSucesso)
    {
        if (resultado.Sucesso) TempData["Sucesso"] = mensagemSucesso;
        else TempData["Erro"] = resultado.Mensagem;
    }
}
