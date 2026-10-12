using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FlorencaApi.Models;

[Table("comandas_pedidos")]
public class ComandaPedido
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("usuario_id")]
    public int UsuarioId { get; set; }

    [Column("itens_json")]
    public string ItensJson { get; set; } = "[]";

    [Column("valor_total")]
    public decimal ValorTotal { get; set; }

    [Column("status")]
    public string Status { get; set; } = "ENVIADO";

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}
