using System.ComponentModel.DataAnnotations;

namespace FlorencaApi.Models;

// DTOs de ENTRADA: o cliente só pode enviar os campos permitidos.
// Isso impede "overposting" (ex.: enviar Status = "CONCLUIDO" ou TipoUsuario = "FUNCIONARIO").

public class CadastroRequest
{
    [Required, StringLength(100, MinimumLength = 2)]
    public string Nome { get; set; } = string.Empty;

    [Required, StringLength(50, MinimumLength = 3)]
    public string Usuario { get; set; } = string.Empty;

    [Required, StringLength(100, MinimumLength = 4)]
    public string Senha { get; set; } = string.Empty;
}

public class AgendamentoRequest
{
    public int UsuarioId { get; set; }          // ignorado para CLIENTE (usa o id do token)
    public DateTime DataHora { get; set; }

    [Range(1, 50)]
    public int QtdPessoas { get; set; }

    public bool IsPcd { get; set; }

    [StringLength(100)]
    public string? NomePcd { get; set; }

    [StringLength(100)]
    public string? TipoPcd { get; set; }
}

public class PedidoRequest
{
    public int UsuarioId { get; set; }          // ignorado para CLIENTE (usa o id do token)

    [Required]
    public string ItensJson { get; set; } = "[]";

    [Range(0, 100000)]
    public decimal ValorTotal { get; set; }
}

public class CupomRequest
{
    [Range(1, int.MaxValue)]
    public int UsuarioId { get; set; }

    [Required, StringLength(100)]
    public string NomePromocao { get; set; } = string.Empty;

    [Required, StringLength(20)]
    public string CodigoCupom { get; set; } = string.Empty;
}

public class FavoritoRequest
{
    public int UsuarioId { get; set; }          // ignorado para CLIENTE (usa o id do token)

    [Required, StringLength(100)]
    public string PratoNome { get; set; } = string.Empty;

    [Range(0, 100000)]
    public decimal Preco { get; set; }
}

public class FilaRequest
{
    public int UsuarioId { get; set; }          // ignorado para CLIENTE (usa o id do token)

    [Range(1, 50)]
    public int QtdPessoas { get; set; }
}
