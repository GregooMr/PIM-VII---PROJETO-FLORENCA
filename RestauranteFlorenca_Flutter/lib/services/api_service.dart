import 'dart:convert';
import 'package:http/http.dart' as http;
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

  // --- AUTENTICAÇÃO E USUÁRIOS ---
  static Future<http.Response> login(String usuario, String senha) async {
    return await http.post(
      Uri.parse('$baseUrl/usuarios/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'usuario': usuario, 'senha': senha}),
    );
  }

  static Future<http.Response> cadastrarUsuario(Usuario usuario) async {
    return await http.post(
      Uri.parse('$baseUrl/usuarios/cadastrar'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(usuario.toJson()),
    );
  }

  // --- AGENDAMENTOS / RESERVAS PCD ---
  static Future<http.Response> criarAgendamento(Agendamento reserva) async {
    return await http.post(
      Uri.parse('$baseUrl/agendamentos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(reserva.toJson()),
    );
  }

  static Future<http.Response> obterAgendamentosUsuario(int usuarioId) async {
    return await http.get(Uri.parse('$baseUrl/agendamentos/usuario/$usuarioId'));
  }

  static Future<http.Response> obterTodosAgendamentos() async {
    return await http.get(Uri.parse('$baseUrl/agendamentos'));
  }

  static Future<http.Response> cancelarAgendamento(int id) async {
    return await http.put(Uri.parse('$baseUrl/agendamentos/$id/cancelar'));
  }

  // --- COMANDAS E PEDIDOS ---
  static Future<http.Response> criarPedido(ComandaPedido pedido) async {
    return await http.post(
      Uri.parse('$baseUrl/comandaspedidos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(pedido.toJson()),
    );
  }

  static Future<http.Response> obterPedidosUsuario(int usuarioId) async {
    return await http.get(Uri.parse('$baseUrl/comandaspedidos/usuario/$usuarioId'));
  }

  static Future<http.Response> obterTodosPedidos() async {
    return await http.get(Uri.parse('$baseUrl/comandaspedidos'));
  }

  static Future<http.Response> alterarStatusPedido(int id, String novoStatus) async {
    return await http.put(
      Uri.parse('$baseUrl/comandaspedidos/$id/status'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'status': novoStatus}),
    );
  }

  // --- FAVORITOS ---
  static Future<http.Response> obterFavoritos(int usuarioId) async {
    return await http.get(Uri.parse('$baseUrl/favoritos/usuario/$usuarioId'));
  }

  static Future<http.Response> adicionarFavorito(Favorito favorito) async {
    return await http.post(
      Uri.parse('$baseUrl/favoritos'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(favorito.toJson()),
    );
  }

  static Future<http.Response> removerFavorito(int id) async {
    return await http.delete(Uri.parse('$baseUrl/favoritos/$id'));
  }

  // --- FILA VIRTUAL ---
  static Future<http.Response> entrarFila(FilaVirtual entrada) async {
    return await http.post(
      Uri.parse('$baseUrl/filavirtual'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(entrada.toJson()),
    );
  }

  static Future<http.Response> obterFilaUsuario(int usuarioId) async {
    return await http.get(Uri.parse('$baseUrl/filavirtual/usuario/$usuarioId'));
  }

  static Future<http.Response> obterFilaTodos() async {
    return await http.get(Uri.parse('$baseUrl/filavirtual'));
  }

  static Future<http.Response> chamarFila(int id) async {
    return await http.put(Uri.parse('$baseUrl/filavirtual/$id/chamar'));
  }

  static Future<http.Response> cancelarFila(int id) async {
    return await http.put(Uri.parse('$baseUrl/filavirtual/$id/cancelar'));
  }

  // --- CUPONS ---
  static Future<http.Response> criarCupom(Cupom cupom) async {
    return await http.post(
      Uri.parse('$baseUrl/cupons'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(cupom.toJson()),
    );
  }

  static Future<http.Response> obterCuponsUsuario(int usuarioId) async {
    return await http.get(Uri.parse('$baseUrl/cupons/usuario/$usuarioId'));
  }

  static Future<http.Response> validarCupomFuncionario(String codigo) async {
    return await http.post(
      Uri.parse('$baseUrl/cupons/validar-funcionario'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'codigoCupom': codigo}),
    );
  }

  static Future<http.Response> usarCupom(int id) async {
    return await http.put(Uri.parse('$baseUrl/cupons/$id/usar'));
  }
}
