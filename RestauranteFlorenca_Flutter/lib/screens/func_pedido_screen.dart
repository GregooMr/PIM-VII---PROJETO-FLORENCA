import 'dart:convert';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/comanda_pedido.dart';
import '../services/api_service.dart';

class FuncPedidoScreen extends StatefulWidget {
  const FuncPedidoScreen({super.key});

  @override
  State<FuncPedidoScreen> createState() => _FuncPedidoScreenState();
}

class _FuncPedidoScreenState extends State<FuncPedidoScreen> {
  List<ComandaPedido> _pedidos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPedidos();
  }

  Future<void> _carregarPedidos() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.obterTodosPedidos();
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        setState(() {
          _pedidos = list.map((e) => ComandaPedido.fromJson(e)).toList();
        });
      }
    } catch (e) {
      // Erro
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _alterarStatus(int id, String novoStatus) async {
    try {
      final response = await ApiService.alterarStatusPedido(id, novoStatus);
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Status do pedido #$id alterado para $novoStatus')),
        );
        _carregarPedidos();
      }
    } catch (e) {
      // Erro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cozinha & Pedidos'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregarPedidos),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _pedidos.isEmpty
              ? const Center(child: Text('Nenhum pedido ativo no momento.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _pedidos.length,
                  itemBuilder: (context, index) {
                    final pedido = _pedidos[index];

                    List<dynamic> itens = [];
                    try {
                      itens = jsonDecode(pedido.itensJson);
                    } catch (e) {
                      // Erro
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📋 Pedido #${pedido.id} | Usuário #${pedido.usuarioId}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(height: 4),
                            Text('💰 Valor Total: R\$ ${pedido.valorTotal.toStringAsFixed(2)}'),
                            Text('📌 Status Atual: ${pedido.status}', style: const TextStyle(fontWeight: FontWeight.bold, color: FlorencaApp.florencaWine)),
                            const SizedBox(height: 8),
                            const Text('🛒 Itens:', style: TextStyle(fontWeight: FontWeight.bold)),
                            ...itens.map((item) => Text('  • ${item['nome']} (R\$ ${(item['preco'] as num).toStringAsFixed(2)})')),
                            const SizedBox(height: 12),
                            PopupMenuButton<String>(
                              onSelected: (status) => _alterarStatus(pedido.id, status),
                              itemBuilder: (context) => const [
                                PopupMenuItem(value: 'EM_PREPARO', child: Text('👨‍🍳 Em Preparo')),
                                PopupMenuItem(value: 'ENTREGUE', child: Text('✅ Entregue')),
                                PopupMenuItem(value: 'CANCELADO', child: Text('❌ Cancelar')),
                              ],
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: FlorencaApp.florencaWine,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.settings, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('⚙️ Alterar Status ▾', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
