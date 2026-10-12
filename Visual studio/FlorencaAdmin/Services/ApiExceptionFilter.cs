using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc.ModelBinding;
using Microsoft.AspNetCore.Mvc.ViewFeatures;

namespace FlorencaAdmin.Services;

public class ApiUnauthorizedException : Exception { }

public class ApiExceptionFilter : IAsyncExceptionFilter
{
    public async Task OnExceptionAsync(ExceptionContext context)
    {
        switch (context.Exception)
        {
            // Token expirado/invalido: encerra a sessão e volta para o login.
            case ApiUnauthorizedException:
                await context.HttpContext.SignOutAsync(
                    CookieAuthenticationDefaults.AuthenticationScheme);
                context.Result = new RedirectToActionResult("Login", "Account", null);
                context.ExceptionHandled = true;
                break;

            // API desligada ou inacessível.
            case HttpRequestException:
            case TaskCanceledException:
                context.Result = new ViewResult
                {
                    ViewName = "Erro",
                    ViewData = new ViewDataDictionary(
                        new EmptyModelMetadataProvider(), context.ModelState)
                    {
                        Model = "Não foi possível conectar à API do Restaurante Florença. " +
                                "Verifique se ela está em execução (http://localhost:5162)."
                    }
                };
                context.ExceptionHandled = true;
                break;
        }
    }
}
