using System.ComponentModel.DataAnnotations;
using System.Text.Json;

namespace FlorencaAdmin.Models;

// ---------------------------------------------------------------------------
// MODEL: representações dos dados devolvidos pela API REST.
// ---------------------------------------------------------------------------

public class LoginResponse
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Usuario { get; set; } = string.Empty;
    public string TipoUsuario { get; set; } = string.Empty;
    public string? Token { get; set; }
}

public class UsuarioInfo
{
    public int Id { get; set; }
    public string Nome { get; set; } = string.Empty;
    public string Usuario { get; set; } = string.Empty;
    public string TipoUsuario { get; set; } = string.Empty;
}

public class Pedido
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public string ItensJson { get; set; } = "[]";
    public decimal ValorTotal { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }

    /// <summary>
    /// Converte o campo itens_json (salvo pelo app Flutter) em uma lista legível.
    /// Aceita tanto "qtd" quanto "quantidade" para compatibilidade com os dois formatos.
    /// </summary>
    public List<ItemPedido> ObterItens()
    {
        var itens = new List<ItemPedido>();

        try
        {
            using var doc = JsonDocument.Parse(ItensJson);
            if (doc.RootElement.ValueKind != JsonValueKind.Array) return itens;

            foreach (var el in doc.RootElement.EnumerateArray())
            {
                if (el.ValueKind != JsonValueKind.Object) continue;

                itens.Add(new ItemPedido
                {
                    Nome = LerTexto(el, "prato", "nome", "prato_nome"),
                    Quantidade = (int)LerNumero(el, 1, "qtd", "quantidade"),
                    Preco = LerNumero(el, 0, "preco")
                });
            }
        }
        catch (Exception)
        {
            // JSON inválido: devolve a lista vazia e o painel mostra "sem itens".
        }

        return itens;
    }

    private static string LerTexto(JsonElement el, params string[] chaves)
    {
        foreach (var chave in chaves)
            if (el.TryGetProperty(chave, out var v) && v.ValueKind == JsonValueKind.String)
                return v.GetString() ?? "Item";
        return "Item";
    }

    private static decimal LerNumero(JsonElement el, decimal padrao, params string[] chaves)
    {
        foreach (var chave in chaves)
            if (el.TryGetProperty(chave, out var v) && v.ValueKind == JsonValueKind.Number)
                return v.GetDecimal();
        return padrao;
    }
}

public class ItemPedido
{
    public string Nome { get; set; } = string.Empty;
    public int Quantidade { get; set; }
    public decimal Preco { get; set; }
}

public class FilaItem
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public int QtdPessoas { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class Agendamento
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public DateTime DataHora { get; set; }
    public int QtdPessoas { get; set; }
    public bool IsPcd { get; set; }
    public string? NomePcd { get; set; }
    public string? TipoPcd { get; set; }
    public string Status { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
}

public class Cupom
{
    public int Id { get; set; }
    public int UsuarioId { get; set; }
    public string NomePromocao { get; set; } = string.Empty;
    public string CodigoCupom { get; set; } = string.Empty;
    public bool IsUsado { get; set; }
    public DateTime CreatedAt { get; set; }
}

// ---------------------------------------------------------------------------
// VIEW MODELS: dados preparados para cada tela.
// ---------------------------------------------------------------------------

public class LoginViewModel
{
    [Required(ErrorMessage = "Informe o usuário.")]
    [Display(Name = "Usuário")]
    public string Usuario { get; set; } = string.Empty;

    [Required(ErrorMessage = "Informe a senha.")]
    [DataType(DataType.Password)]
    [Display(Name = "Senha")]
    public string Senha { get; set; } = string.Empty;

    public string? ReturnUrl { get; set; }
}

public class DashboardViewModel
{
    public int PedidosNovos { get; set; }
    public int PedidosEmPreparo { get; set; }
    public int FilaAguardando { get; set; }
    public int ReservasHoje { get; set; }
    public int ReservasPcdFuturas { get; set; }
    public int CuponsDisponiveis { get; set; }
}

public class PedidosViewModel
{
    public List<Pedido> Novos { get; set; } = new();
    public List<Pedido> EmPreparo { get; set; } = new();
    public List<Pedido> Finalizados { get; set; } = new();
    public Dictionary<int, string> Nomes { get; set; } = new();
}

public class FilaViewModel
{
    public List<FilaItem> Aguardando { get; set; } = new();
    public List<FilaItem> MesaPronta { get; set; } = new();
    public Dictionary<int, string> Nomes { get; set; } = new();
}

public class AgendamentosViewModel
{
    public List<Agendamento> Reservas { get; set; } = new();
    public Dictionary<int, string> Nomes { get; set; } = new();
    public bool SomentePcd { get; set; }
    public bool SomenteFuturas { get; set; }
}

public class CuponsViewModel
{
    public List<Cupom> Cupons { get; set; } = new();
    public List<UsuarioInfo> Clientes { get; set; } = new();
    public Dictionary<int, string> Nomes { get; set; } = new();

    // Resultado da validação de código no caixa
    public Cupom? CupomValidado { get; set; }
    public string? ErroValidacao { get; set; }

    [Display(Name = "Código do cupom")]
    public string? CodigoBusca { get; set; }
}

public class EmitirCupomViewModel
{
    [Required(ErrorMessage = "Selecione o cliente.")]
    [Range(1, int.MaxValue, ErrorMessage = "Selecione o cliente.")]
    public int UsuarioId { get; set; }

    [Required(ErrorMessage = "Informe o nome da promoção.")]
    [StringLength(100)]
    public string NomePromocao { get; set; } = string.Empty;

    [Required(ErrorMessage = "Informe o código.")]
    [StringLength(20)]
    public string CodigoCupom { get; set; } = string.Empty;
}

public static class NomesExtensions
{
    public static string NomeDe(this Dictionary<int, string> nomes, int id) =>
        nomes.TryGetValue(id, out var nome) ? nome : $"Cliente #{id}";
}
