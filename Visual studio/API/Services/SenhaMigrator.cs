using FlorencaApi.Data;
using Microsoft.EntityFrameworkCore;

namespace FlorencaApi.Services;

/// <summary>
/// Converte senhas legadas em texto puro (ex.: dados de teste do script SQL)
/// para hash BCrypt na inicialização da API. Executa apenas uma vez por senha.
/// Hashes BCrypt sempre começam com "$2".
/// </summary>
public static class SenhaMigrator
{
    public static async Task MigrarAsync(IServiceProvider services)
    {
        using var scope = services.CreateScope();
        var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        var logger = scope.ServiceProvider.GetRequiredService<ILoggerFactory>()
            .CreateLogger("SenhaMigrator");

        var pendentes = await context.Usuarios
            .Where(u => !u.Senha.StartsWith("$2"))
            .ToListAsync();

        if (pendentes.Count == 0) return;

        foreach (var usuario in pendentes)
            usuario.Senha = BCrypt.Net.BCrypt.HashPassword(usuario.Senha);

        await context.SaveChangesAsync();
        logger.LogInformation("{Qtd} senha(s) legada(s) convertida(s) para BCrypt.", pendentes.Count);
    }
}
