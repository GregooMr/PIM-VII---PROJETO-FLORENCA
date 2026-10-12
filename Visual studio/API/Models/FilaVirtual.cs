using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FlorencaApi.Models;

[Table("fila_virtual")]
public class FilaVirtual
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("usuario_id")]
    public int UsuarioId { get; set; }

    [Column("qtd_pessoas")]
    public int QtdPessoas { get; set; }

    [Column("status")]
    public string Status { get; set; } = "AGUARDANDO";

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}
