import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/agendamento.dart';
import '../models/comanda_pedido.dart';
import '../services/api_service.dart';

class HistoricoScreen extends StatefulWidget {
  const HistoricoScreen({super.key});

  @override
  State<HistoricoScreen> createState() => _HistoricoScreenState();
}

class _HistoricoScreenState extends State<HistoricoScreen> {
  List<ComandaPedido> _pedidos = [];
  List<Agendamento> _reservas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarHistorico();
  }

  Future<void> _carregarHistorico() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id') ?? 0;

    if (usuarioId <= 0) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final resPedidos = await ApiService.obterPedidosUsuario(usuarioId);
      final resReservas = await ApiService.obterAgendamentosUsuario(usuarioId);

      if (resPedidos.statusCode == 200) {
        final List<dynamic> listP = jsonDecode(resPedidos.body);
        _pedidos = listP.map((e) => ComandaPedido.fromJson(e)).toList();
      }

      if (resReservas.statusCode == 200) {
        final List<dynamic> listR = jsonDecode(resReservas.body);
        _reservas = listR.map((e) => Agendamento.fromJson(e)).toList();
      }
    } catch (e) {
      // Erro
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Histórico de Pedidos & Reservas')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : (_pedidos.isEmpty && _reservas.isEmpty)
              ? const Center(child: Text('Nenhum pedido ou reserva encontrado.'))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    if (_pedidos.isNotEmpty) ...[
                      const Text('🛒 Meus Pedidos & Comandas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FlorencaApp.florencaWine)),
                      const SizedBox(height: 12),
                      ..._pedidos.map((p) => _buildPedidoCard(p)),
                    ],
                    if (_reservas.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Text('📅 Minhas Reservas de Mesas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FlorencaApp.florencaWine)),
                      const SizedBox(height: 12),
                      ..._reservas.map((r) => _buildReservaCard(r)),
                    ],
                  ],
                ),
    );
  }

  Widget _buildPedidoCard(ComandaPedido p) {
    List<dynamic> itens = [];
    try {
      itens = jsonDecode(p.itensJson);
    } catch (e) {
      // Erro
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📋 Pedido #${p.id}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text('💰 Total: R\$ ${p.valorTotal.toStringAsFixed(2)}'),
            Text('📌 Status: ${p.status}'),
            const SizedBox(height: 8),
            const Text('🛒 Itens:', style: TextStyle(fontWeight: FontWeight.bold)),
            ...itens.map((item) => Text('  • ${item['nome']} (R\$ ${(item['preco'] as num).toStringAsFixed(2)})')),
          ],
        ),
      ),
    );
  }

  Widget _buildReservaCard(Agendamento r) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: r.isPcd ? const Color(0xFFFFF0F5) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📅 Data/Hora: ${r.dataHora.replaceAll('T', ' ')}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            Text('👥 Pessoas: ${r.qtdPessoas}'),
            Text('♿ Mesa PCD: ${r.isPcd ? "SIM (Atenção Especial)" : "Não"}'),
            if (r.isPcd) Text('👤 Convidado: ${r.nomePcd} (${r.tipoPcd})'),
            Text('STATUS: ${r.status}'),
          ],
        ),
      ),
    );
  }
}
