using FlorencaAdmin.Services;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Mvc;

var builder = WebApplication.CreateBuilder(args);

// ---------------------------------------------------------------------------
// MVC: filtros globais
//  - AutoValidateAntiforgeryToken: protege todos os POST contra CSRF
//  - ApiExceptionFilter: trata sessão expirada (401) e API fora do ar
// ---------------------------------------------------------------------------
builder.Services.AddControllersWithViews(options =>
{
    options.Filters.Add(new AutoValidateAntiforgeryTokenAttribute());
    options.Filters.Add<ApiExceptionFilter>();
});

// ---------------------------------------------------------------------------
// Cliente HTTP tipado para a API REST (Model do painel = dados vindos da API).
// O BearerTokenHandler anexa o JWT do usuário logado em cada requisição.
// ---------------------------------------------------------------------------
builder.Services.AddHttpContextAccessor();
builder.Services.AddTransient<BearerTokenHandler>();

builder.Services
    .AddHttpClient<ApiClient>(client =>
    {
        var baseUrl = builder.Configuration["Api:BaseUrl"]
                      ?? throw new InvalidOperationException("Configure 'Api:BaseUrl'.");
        client.BaseAddress = new Uri(baseUrl);
        client.Timeout = TimeSpan.FromSeconds(15);
    })
    .AddHttpMessageHandler<BearerTokenHandler>();

// ---------------------------------------------------------------------------
// Autenticação do painel por cookie (HttpOnly). O JWT da API fica guardado
// dentro do cookie criptografado, nunca em JavaScript ou na URL.
// ---------------------------------------------------------------------------
builder.Services
    .AddAuthentication(CookieAuthenticationDefaults.AuthenticationScheme)
    .AddCookie(options =>
    {
        options.LoginPath = "/Account/Login";
        options.AccessDeniedPath = "/Account/Login";
        options.Cookie.Name = "FlorencaAdmin.Auth";
        options.Cookie.HttpOnly = true;
        options.Cookie.SameSite = SameSiteMode.Lax;
        options.ExpireTimeSpan = TimeSpan.FromHours(8); // mesmo prazo do JWT
        options.SlidingExpiration = false;
    });

builder.Services.AddAuthorization();

var app = builder.Build();

if (!app.Environment.IsDevelopment())
{
    app.UseExceptionHandler("/Home/Erro");
}

app.UseStaticFiles();
app.UseRouting();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllerRoute(
    name: "default",
    pattern: "{controller=Home}/{action=Index}/{id?}");

app.Run();
