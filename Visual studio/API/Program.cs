using System.Text;
using FlorencaApi.Data;
using FlorencaApi.Services;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// ---------------------------------------------------------------------------
// Banco de dados (Entity Framework Core + SQL Server)
// ---------------------------------------------------------------------------
var connectionString = builder.Configuration.GetConnectionString("ConexaoFlorenca");

if (string.IsNullOrWhiteSpace(connectionString))
{
    throw new InvalidOperationException(
        "A connection string 'ConexaoFlorenca' não foi encontrada.");
}

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseSqlServer(
        connectionString,
        sqlOptions => sqlOptions.EnableRetryOnFailure()
    )
);

// ---------------------------------------------------------------------------
// Autenticação JWT
// ---------------------------------------------------------------------------
var jwtKey = builder.Configuration["Jwt:Key"];

if (string.IsNullOrWhiteSpace(jwtKey) || jwtKey.Length < 32)
{
    throw new InvalidOperationException(
        "Configure 'Jwt:Key' com pelo menos 32 caracteres (use dotnet user-secrets em produção).");
}

builder.Services.AddScoped<TokenService>();

builder.Services
    .AddAuthentication(JwtBearerDefaults.AuthenticationScheme)
    .AddJwtBearer(options =>
    {
        // Mantém os nomes curtos das claims ("sub", "role") exatamente como no token.
        options.MapInboundClaims = false;

        options.TokenValidationParameters = new TokenValidationParameters
        {
            ValidateIssuer = true,
            ValidateAudience = true,
            ValidateLifetime = true,
            ValidateIssuerSigningKey = true,
            ValidIssuer = builder.Configuration["Jwt:Issuer"],
            ValidAudience = builder.Configuration["Jwt:Audience"],
            IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey)),
            NameClaimType = "name",
            RoleClaimType = "role",
            ClockSkew = TimeSpan.FromMinutes(1)
        };
    });

builder.Services.AddAuthorization();

// ---------------------------------------------------------------------------
// CORS (painel administrativo MVC e eventuais clientes web)
// ---------------------------------------------------------------------------
var origens = builder.Configuration.GetSection("Cors:AllowedOrigins").Get<string[]>()
              ?? Array.Empty<string>();

builder.Services.AddCors(options =>
{
    options.AddPolicy("PainelAdmin", policy =>
        policy.WithOrigins(origens)
              .AllowAnyHeader()
              .AllowAnyMethod());
});

// ---------------------------------------------------------------------------
// Controllers + Swagger (com botão "Authorize" para testar o JWT)
// ---------------------------------------------------------------------------
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.SwaggerDoc("v1", new OpenApiInfo { Title = "API Restaurante Florença", Version = "v1" });

    c.AddSecurityDefinition("Bearer", new OpenApiSecurityScheme
    {
        Name = "Authorization",
        Type = SecuritySchemeType.Http,
        Scheme = "bearer",
        BearerFormat = "JWT",
        In = ParameterLocation.Header,
        Description = "Informe apenas o token JWT obtido em /api/usuarios/login."
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement
    {
        {
            new OpenApiSecurityScheme
            {
                Reference = new OpenApiReference
                {
                    Type = ReferenceType.SecurityScheme,
                    Id = "Bearer"
                }
            },
            Array.Empty<string>()
        }
    });
});

builder.WebHost.UseUrls(
    "http://0.0.0.0:5162",
    "https://0.0.0.0:7175"
);

var app = builder.Build();

// Converte senhas legadas (texto puro) para BCrypt na primeira execução.
await SenhaMigrator.MigrarAsync(app.Services);

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Durante o desenvolvimento com Android, usamos HTTP na porta 5162.
// Evitamos redirecionamento automático para HTTPS para não causar
// problemas com certificado no emulador/dispositivo.
// Em produção, habilite app.UseHttpsRedirection() e use HTTPS.

app.UseCors("PainelAdmin");

// A ordem importa: primeiro identifica quem é (Authentication),
// depois decide o que pode fazer (Authorization).
app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

app.Run();
