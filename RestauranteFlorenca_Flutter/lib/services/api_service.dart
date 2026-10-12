import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/usuario.dart';
import '../models/agendamento.dart';
import '../models/comanda_pedido.dart';
import '../models/cupom.dart';
import '../models/favorito.dart';
import '../models/fila_virtual.dart';

/// ============================================================================
/// PROJETO ACADÊMICO: Sistema de Gestão Gastronômica - Restaurante Florença
/// SERVIÇO DART: api_service.dart
/// DESCRIÇÃO: Cliente HTTP assíncrono para comunicação RESTful com a API C# (.NET).
/// ============================================================================

class ApiService {
  // 10.0.2.2 redireciona o tráfego do emulador Android para o localhost do PC host
  static const String baseUrl = 'http://10.0.2.2:5162/api';
  static bool _handlingUnauthorized = false;
  static Future<void> Function()? onUnauthorized;
  static void Function()? onForbidden;

  static Future<Map<String, String>> _headers() async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token')?.trim();
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  static Future<http.Response> _send(
    Future<http.Response> Function(Map<String, String> headers) request,
  ) async {
    final response = await request(await _headers());
    if (response.statusCode == 401) {
      await _handleUnauthorized();
    } else if (response.statusCode == 403) {
      onForbidden?.call();
    }
    return response;
  }

  static Future<void> _handleUnauthorized() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('usuario_id');
    await prefs.remove('usuario_nome');
    await prefs.remove('usuario_tipo');
    await onUnauthorized?.call();
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('usuario_id');
    await prefs.remove('usuario_nome');
    await prefs.remove('usuario_tipo');
    _handlingUnauthorized = false;
  }

  static void resetSessionExpiry() {
    _handlingUnauthorized = false;
  }

  static String errorMessage(
    http.Response response, {
    String fallback = 'Erro na comunicação com o servidor.',
  }) {
    if (response.statusCode == 403) {
      return 'Você não tem permissão para esta ação.';
    }
    if (response.statusCode == 401) {
      return 'Sua sessão expirou. Entre novamente.';
    }

    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic>) {
        final mensagem = body['mensagem'];
        if (mensagem is String && mensagem.isNotEmpty) return mensagem;

        final errors = body['errors'];
        if (errors is Map) {
          for (final messages in errors.values) {
            if (messages is List && messages.isNotEmpty) {
              return messages.first.toString();
            }
            if (messages is String && messages.isNotEmpty) return messages;
          }
        }
      }
    } on FormatException {
      // Respostas sem JSON utilizam a mensagem padrão abaixo.
    }

    return '$fallback (HTTP ${response.statusCode})';
  }

  // --- AUTENTICAÇÃO E USUÁRIOS ---
  static Future<http.Response> login(String usuario, String senha) async {
    return http.post(
      Uri.parse('$baseUrl/usuarios/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'usuario': usuario, 'senha': senha}),
    );
  }

  static Future<http.Response> cadastrarUsuario(Usuario usuario) async {
    return http.post(
      Uri.parse('$baseUrl/usuarios/cadastrar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nome': usuario.nome,
        'usuario': usuario.loginUsuario,
        'senha': usuario.senha,
      }),
    );
  }

  // --- AGENDAMENTOS / RESERVAS PCD ---
  static Future<http.Response> criarAgendamento(Agendamento reserva) async {
    return _send((headers) => http.post(
          Uri.parse('$baseUrl/agendamentos'),
          headers: headers,
          body: jsonEncode({
            'dataHora': reserva.dataHora,
            'qtdPessoas': reserva.qtdPessoas,
            'isPcd': reserva.isPcd,
            'nomePcd': reserva.nomePcd,
            'tipoPcd': reserva.tipoPcd,
          }),
        ));
  }

  static Future<http.Response> obterAgendamentosUsuario(int usuarioId) async {
    return _send((headers) => http.get(
          Uri.parse('$baseUrl/agendamentos/usuario/$usuarioId'),
          headers: headers,
        ));
  }

  static Future<http.Response> obterTodosAgendamentos() async {
    return _send((headers) => http.get(
          Uri.parse('$baseUrl/agendamentos'),
          headers: headers,
        ));
  }

  static Future<http.Response> cancelarAgendamento(int id) async {
    return _send((headers) => http.put(
          Uri.parse('$baseUrl/agendamentos/$id/cancelar'),
          headers: headers,
        ));
  }

  // --- COMANDAS E PEDIDOS ---
  static Future<http.Response> criarPedido(ComandaPedido pedido) async {
    return _send((headers) => http.post(
          Uri.parse('$baseUrl/comandaspedidos'),
          headers: headers,
          body: jsonEncode({
            'itensJson': pedido.itensJson,
            'valorTotal': pedido.valorTotal,
          }),
        ));
  }

  static Future<http.Response> obterPedidosUsuario(int usuarioId) async {
    return _send((headers) => http.get(
          Uri.parse('$baseUrl/comandaspedidos/usuario/$usuarioId'),
          headers: headers,
        ));
  }

  static Future<http.Response> obterTodosPedidos() async {
    return _send((headers) => http.get(
          Uri.parse('$baseUrl/comandaspedidos'),
          headers: headers,
        ));
  }

  static Future<http.Response> alterarStatusPedido(int id, String novoStatus) async {
    return _send((headers) => http.put(
          Uri.parse('$baseUrl/comandaspedidos/$id/status'),
          headers: headers,
          body: jsonEncode({'status': novoStatus}),
        ));
  }

  // --- FAVORITOS ---
  static Future<http.Response> obterFavoritos(int usuarioId) async {
    return _send((headers) => http.get(
          Uri.parse('$baseUrl/favoritos/usuario/$usuarioId'),
          headers: headers,
        ));
  }

  static Future<http.Response> adicionarFavorito(Favorito favorito) async {
    return _send((headers) => http.post(
          Uri.parse('$baseUrl/favoritos'),
          headers: headers,
          body: jsonEncode({
            'pratoNome': favorito.pratoNome,
            'preco': favorito.preco,
          }),
        ));
  }

  static Future<http.Response> removerFavorito(int id) async {
    return _send((headers) => http.delete(
          Uri.parse('$baseUrl/favoritos/$id'),
          headers: headers,
        ));
  }

  // --- FILA VIRTUAL ---
  static Future<http.Response> entrarFila(FilaVirtual entrada) async {
    return _send((headers) => http.post(
          Uri.parse('$baseUrl/filavirtual'),
          headers: headers,
          body: jsonEncode({'qtdPessoas': entrada.qtdPessoas}),
        ));
  }

  static Future<http.Response> obterFilaUsuario(int usuarioId) async {
    return _send((headers) => http.get(
          Uri.parse('$baseUrl/filavirtual/usuario/$usuarioId'),
          headers: headers,
        ));
  }

  static Future<http.Response> obterFilaTodos() async {
    return _send((headers) => http.get(
          Uri.parse('$baseUrl/filavirtual'),
          headers: headers,
        ));
  }

  static Future<http.Response> chamarFila(int id) async {
    return _send((headers) => http.put(
          Uri.parse('$baseUrl/filavirtual/$id/chamar'),
          headers: headers,
        ));
  }

  static Future<http.Response> cancelarFila(int id) async {
    return _send((headers) => http.put(
          Uri.parse('$baseUrl/filavirtual/$id/cancelar'),
          headers: headers,
        ));
  }

  // --- CUPONS ---
  static Future<http.Response> criarCupom(Cupom cupom) async {
    return _send((headers) => http.post(
          Uri.parse('$baseUrl/cupons'),
          headers: headers,
          body: jsonEncode({
            'usuarioId': cupom.usuarioId,
            'nomePromocao': cupom.nomePromocao,
            'codigoCupom': cupom.codigoCupom.toUpperCase(),
          }),
        ));
  }

  static Future<http.Response> obterCuponsUsuario(int usuarioId) async {
    return _send((headers) => http.get(
          Uri.parse('$baseUrl/cupons/usuario/$usuarioId'),
          headers: headers,
        ));
  }

  static Future<http.Response> validarCupomFuncionario(String codigo) async {
    return _send((headers) => http.post(
          Uri.parse('$baseUrl/cupons/validar-funcionario'),
          headers: headers,
          body: jsonEncode({'codigoCupom': codigo.toUpperCase()}),
        ));
  }

  static Future<http.Response> usarCupom(int id) async {
    return _send((headers) => http.put(
          Uri.parse('$baseUrl/cupons/$id/usar'),
          headers: headers,
        ));
  }
}
