using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FlorencaApi.Models;

[Table("usuarios")]
public class Usuario
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Required]
    [Column("nome")]
    public string Nome { get; set; } = string.Empty;

    [Required]
    [Column("usuario")]
    public string LoginUsuario { get; set; } = string.Empty;

    [Required]
    [Column("senha")]
    public string Senha { get; set; } = string.Empty;

    [Required]
    [Column("tipo_usuario")]
    public string TipoUsuario { get; set; } = "CLIENTE";

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}
