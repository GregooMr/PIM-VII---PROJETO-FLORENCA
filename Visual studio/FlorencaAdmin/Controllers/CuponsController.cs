using FlorencaAdmin.Models;
using FlorencaAdmin.Services;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FlorencaAdmin.Controllers;

/// <summary>Caixa: valida, dá baixa e emite cupons promocionais.</summary>
[Authorize(Roles = "FUNCIONARIO")]
public class CuponsController : Controller
{
    private readonly ApiClient _api;

    public CuponsController(ApiClient api)
    {
        _api = api;
    }

    public async Task<IActionResult> Index()
    {
        return View(await MontarModeloAsync());
    }

    [HttpPost]
    public async Task<IActionResult> Validar(string? codigo)
    {
        var modelo = await MontarModeloAsync();
        modelo.CodigoBusca = codigo;

        if (string.IsNullOrWhiteSpace(codigo))
        {
            modelo.ErroValidacao = "Informe o código do cupom.";
        }
        else
        {
            var (cupom, erro) = await _api.ValidarCupomAsync(codigo.Trim());
            modelo.CupomValidado = cupom;
            modelo.ErroValidacao = erro;
        }

        return View("Index", modelo);
    }

    [HttpPost]
    public async Task<IActionResult> DarBaixa(int id)
    {
        var resultado = await _api.UsarCupomAsync(id);

        if (resultado.Sucesso) TempData["Sucesso"] = "Baixa realizada: cupom marcado como usado.";
        else TempData["Erro"] = resultado.Mensagem;

        return RedirectToAction(nameof(Index));
    }

    [HttpPost]
    public async Task<IActionResult> Emitir(EmitirCupomViewModel form)
    {
        if (!ModelState.IsValid)
        {
            TempData["Erro"] = ModelState.Values
                .SelectMany(v => v.Errors)
                .Select(e => e.ErrorMessage)
                .FirstOrDefault() ?? "Dados inválidos.";
            return RedirectToAction(nameof(Index));
        }

        var resultado = await _api.CriarCupomAsync(
            form.UsuarioId, form.NomePromocao.Trim(), form.CodigoCupom.Trim());

        if (resultado.Sucesso) TempData["Sucesso"] = "Cupom emitido com sucesso.";
        else TempData["Erro"] = resultado.Mensagem;

        return RedirectToAction(nameof(Index));
    }

    private async Task<CuponsViewModel> MontarModeloAsync()
    {
        var cuponsTask = _api.ObterCuponsAsync();
        var usuariosTask = _api.ObterUsuariosAsync();
        await Task.WhenAll(cuponsTask, usuariosTask);

        var usuarios = usuariosTask.Result;

        return new CuponsViewModel
        {
            Cupons = cuponsTask.Result,
            Clientes = usuarios
                .Where(u => u.TipoUsuario == "CLIENTE")
                .OrderBy(u => u.Nome)
                .ToList(),
            Nomes = usuarios.ToDictionary(u => u.Id, u => u.Nome)
        };
    }
}
