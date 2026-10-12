using System.Net;
using System.Net.Http.Json;
using System.Text.Json;
using FlorencaAdmin.Models;

namespace FlorencaAdmin.Services;

/// <summary>
/// Camada de acesso à API REST ASP.NET Core. Todos os dados do painel
/// vêm daqui, o que garante que web e mobile usem as mesmas regras de negócio.
/// </summary>
public class ApiClient
{
    private static readonly JsonSerializerOptions Json = new(JsonSerializerDefaults.Web);
    private readonly HttpClient _http;

    public ApiClient(HttpClient http)
    {
        _http = http;
    }

    // ---------------------------------------------------------------- Login
    public async Task<LoginResponse?> LoginAsync(string usuario, string senha)
    {
        using var resp = await _http.PostAsJsonAsync(
            "api/usuarios/login", new { usuario, senha }, Json);

        if (resp.StatusCode == HttpStatusCode.Unauthorized ||
            resp.StatusCode == HttpStatusCode.BadRequest)
            return null;

        resp.EnsureSuccessStatusCode();
        return await resp.Content.ReadFromJsonAsync<LoginResponse>(Json);
    }

    // --------------------------------------------------------------- Leituras
    public Task<List<Pedido>> ObterPedidosAsync() => GetListAsync<Pedido>("api/comandaspedidos");
    public Task<List<FilaItem>> ObterFilaAsync() => GetListAsync<FilaItem>("api/filavirtual");
    public Task<List<Agendamento>> ObterAgendamentosAsync() => GetListAsync<Agendamento>("api/agendamentos");
    public Task<List<Cupom>> ObterCuponsAsync() => GetListAsync<Cupom>("api/cupons");
    public Task<List<UsuarioInfo>> ObterUsuariosAsync() => GetListAsync<UsuarioInfo>("api/usuarios");

    public async Task<Dictionary<int, string>> ObterNomesAsync()
    {
        var usuarios = await ObterUsuariosAsync();
        return usuarios.ToDictionary(u => u.Id, u => u.Nome);
    }

    // ------------------------------------------------------------------ Ações
    public Task<ResultadoApi> AlterarStatusPedidoAsync(int id, string status) =>
        EnviarAsync(HttpMethod.Put, $"api/comandaspedidos/{id}/status", new { status });

    public Task<ResultadoApi> ChamarFilaAsync(int id) =>
        EnviarAsync(HttpMethod.Put, $"api/filavirtual/{id}/chamar");

    public Task<ResultadoApi> CancelarFilaAsync(int id) =>
        EnviarAsync(HttpMethod.Put, $"api/filavirtual/{id}/cancelar");

    public Task<ResultadoApi> CancelarAgendamentoAsync(int id) =>
        EnviarAsync(HttpMethod.Put, $"api/agendamentos/{id}/cancelar");

    public Task<ResultadoApi> UsarCupomAsync(int id) =>
        EnviarAsync(HttpMethod.Put, $"api/cupons/{id}/usar");

    public Task<ResultadoApi> CriarCupomAsync(int usuarioId, string nomePromocao, string codigoCupom) =>
        EnviarAsync(HttpMethod.Post, "api/cupons", new { usuarioId, nomePromocao, codigoCupom });

    public async Task<(Cupom? Cupom, string? Erro)> ValidarCupomAsync(string codigo)
    {
        using var resp = await _http.PostAsJsonAsync(
            "api/cupons/validar-funcionario", new { codigoCupom = codigo }, Json);

        VerificarAutorizacao(resp);

        if (resp.IsSuccessStatusCode)
            return (await resp.Content.ReadFromJsonAsync<Cupom>(Json), null);

        return (null, await LerMensagemAsync(resp));
    }

    // ---------------------------------------------------------------- Helpers
    private async Task<List<T>> GetListAsync<T>(string url)
    {
        using var resp = await _http.GetAsync(url);
        VerificarAutorizacao(resp);
        resp.EnsureSuccessStatusCode();
        return await resp.Content.ReadFromJsonAsync<List<T>>(Json) ?? new List<T>();
    }

    private async Task<ResultadoApi> EnviarAsync(HttpMethod metodo, string url, object? corpo = null)
    {
        using var req = new HttpRequestMessage(metodo, url);

        if (corpo != null)
            req.Content = JsonContent.Create(corpo, options: Json);

        using var resp = await _http.SendAsync(req);
        VerificarAutorizacao(resp);

        return resp.IsSuccessStatusCode
            ? ResultadoApi.Ok()
            : ResultadoApi.Falha(await LerMensagemAsync(resp));
    }

    private static void VerificarAutorizacao(HttpResponseMessage resp)
    {
        // 401 = token ausente/expirado; 403 = perfil sem permissão.
        if (resp.StatusCode == HttpStatusCode.Unauthorized ||
            resp.StatusCode == HttpStatusCode.Forbidden)
            throw new ApiUnauthorizedException();
    }

    private static async Task<string> LerMensagemAsync(HttpResponseMessage resp)
    {
        try
        {
            await using var stream = await resp.Content.ReadAsStreamAsync();
            using var doc = await JsonDocument.ParseAsync(stream);
            var root = doc.RootElement;

            if (root.ValueKind == JsonValueKind.Object)
            {
                if (root.TryGetProperty("mensagem", out var m) && m.ValueKind == JsonValueKind.String)
                    return m.GetString() ?? "Operação não realizada.";

                // Erros de validação automática ([ApiController] + DataAnnotations)
                if (root.TryGetProperty("errors", out var e) && e.ValueKind == JsonValueKind.Object)
                {
                    foreach (var campo in e.EnumerateObject())
                        foreach (var erro in campo.Value.EnumerateArray())
                            return erro.GetString() ?? "Dados inválidos.";
                }
            }
        }
        catch (Exception)
        {
            // corpo vazio ou não-JSON: usa a mensagem padrão abaixo
        }

        return $"A API retornou o erro {(int)resp.StatusCode}.";
    }
}

public record ResultadoApi(bool Sucesso, string Mensagem)
{
    public static ResultadoApi Ok() => new(true, string.Empty);
    public static ResultadoApi Falha(string mensagem) => new(false, mensagem);
}
