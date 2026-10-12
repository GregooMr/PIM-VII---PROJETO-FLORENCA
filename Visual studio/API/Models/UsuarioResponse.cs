namespace FlorencaApi.Models;

public class UsuarioResponse
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Usuario { get; set; } = string.Empty;
    public string TipoUsuario { get; set; } = string.Empty;

    // Preenchido apenas na resposta de login. Os campos acima continuam no
    // mesmo lugar do JSON, então o app Flutter existente não quebra.
    public string? Token { get; set; }
}
