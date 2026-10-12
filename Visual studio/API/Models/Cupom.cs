using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FlorencaApi.Models;

[Table("cupons")]
public class Cupom
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("usuario_id")]
    public int UsuarioId { get; set; }

    [Column("nome_promocao")]
    public string NomePromocao { get; set; } = string.Empty;

    [Column("codigo_cupom")]
    public string CodigoCupom { get; set; } = string.Empty;

    [Column("is_usado")]
    public bool IsUsado { get; set; }

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}
