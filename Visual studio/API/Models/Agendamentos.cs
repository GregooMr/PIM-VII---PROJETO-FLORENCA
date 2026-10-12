using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace FlorencaApi.Models;

[Table("agendamentos")]
public class Agendamento
{
    [Key]
    [Column("id")]
    public int Id { get; set; }

    [Column("usuario_id")]
    public int UsuarioId { get; set; }

    [Column("data_hora")]
    public DateTime DataHora { get; set; }

    [Column("qtd_pessoas")]
    public int QtdPessoas { get; set; }

    [Column("is_pcd")]
    public bool IsPcd { get; set; }

    [Column("nome_pcd")]
    public string? NomePcd { get; set; }

    [Column("tipo_pcd")]
    public string? TipoPcd { get; set; }

    [Column("status")]
    public string Status { get; set; } = "CONFIRMADO";

    [Column("created_at")]
    public DateTime CreatedAt { get; set; }
}
