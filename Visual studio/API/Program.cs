using FlorencaApi.Data;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

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

builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

builder.WebHost.UseUrls(
    "http://0.0.0.0:5162",
    "https://0.0.0.0:7175"
);

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// Durante o desenvolvimento com Android, usamos HTTP na porta 5162.
// Evitamos redirecionamento automático para HTTPS para não causar
// problemas com certificado no emulador/dispositivo.
app.UseAuthorization();

app.MapControllers();

app.Run();
