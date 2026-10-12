using System.Security.Claims;
using System.IdentityModel.Tokens.Jwt;

namespace FlorencaApi.Security;

/// <summary>
/// Métodos auxiliares para ler a identidade do usuário a partir do token JWT.
/// </summary>
public static class ClaimsExtensions
{
    public const string RoleFuncionario = "FUNCIONARIO";
    public const string RoleCliente = "CLIENTE";

    public static int ObterUsuarioId(this ClaimsPrincipal user)
    {
        var valor = user.FindFirstValue(JwtRegisteredClaimNames.Sub);
        return int.TryParse(valor, out var id) ? id : 0;
    }

    public static bool EhFuncionario(this ClaimsPrincipal user) =>
        user.IsInRole(RoleFuncionario);

    /// <summary>
    /// Funcionário acessa qualquer recurso; cliente acessa somente os próprios dados.
    /// </summary>
    public static bool PodeAcessar(this ClaimsPrincipal user, int usuarioIdDoRecurso) =>
        user.EhFuncionario() || user.ObterUsuarioId() == usuarioIdDoRecurso;
}
