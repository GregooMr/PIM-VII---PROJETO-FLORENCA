using System.Security.Claims;
using FlorencaAdmin.Models;
using FlorencaAdmin.Services;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace FlorencaAdmin.Controllers;

public class AccountController : Controller
{
    private readonly ApiClient _api;

    public AccountController(ApiClient api)
    {
        _api = api;
    }

    [AllowAnonymous]
    [HttpGet]
    public IActionResult Login(string? returnUrl = null)
    {
        if (User.Identity?.IsAuthenticated == true)
            return RedirectToAction("Index", "Home");

        return View(new LoginViewModel { ReturnUrl = returnUrl });
    }

    [AllowAnonymous]
    [HttpPost]
    public async Task<IActionResult> Login(LoginViewModel model)
    {
        if (!ModelState.IsValid)
            return View(model);

        var resposta = await _api.LoginAsync(model.Usuario.Trim(), model.Senha);

        if (resposta == null || string.IsNullOrEmpty(resposta.Token))
        {
            ModelState.AddModelError(string.Empty, "Usuário ou senha incorretos.");
            return View(model);
        }

        // O painel é exclusivo da equipe (perfil FUNCIONARIO).
        if (!string.Equals(resposta.TipoUsuario, "FUNCIONARIO", StringComparison.OrdinalIgnoreCase))
        {
            ModelState.AddModelError(string.Empty, "Acesso restrito à equipe do restaurante.");
            return View(model);
        }

        var claims = new List<Claim>
        {
            new(ClaimTypes.NameIdentifier, resposta.Id.ToString()),
            new(ClaimTypes.Name, resposta.Nome),
            new(ClaimTypes.Role, resposta.TipoUsuario.ToUpperInvariant()),
            new("access_token", resposta.Token) // JWT usado nas chamadas à API
        };

        var identity = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);

        await HttpContext.SignInAsync(
            CookieAuthenticationDefaults.AuthenticationScheme,
            new ClaimsPrincipal(identity));

        if (!string.IsNullOrEmpty(model.ReturnUrl) && Url.IsLocalUrl(model.ReturnUrl))
            return LocalRedirect(model.ReturnUrl);

        return RedirectToAction("Index", "Home");
    }

    [Authorize]
    [HttpPost]
    public async Task<IActionResult> Logout()
    {
        await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);
        return RedirectToAction(nameof(Login));
    }
}
