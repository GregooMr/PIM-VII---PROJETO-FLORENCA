import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/comanda_pedido.dart';
import '../services/api_service.dart';

class CarrinhoScreen extends StatefulWidget {
  const CarrinhoScreen({super.key});

  @override
  State<CarrinhoScreen> createState() => _CarrinhoScreenState();
}

class _CarrinhoScreenState extends State<CarrinhoScreen> {
  List<Map<String, dynamic>> _itens = [];
  double _totalGeral = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _carregarCarrinhoLocal();
  }

  Future<void> _carregarCarrinhoLocal() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> carrinhoJsonStr = prefs.getStringList('carrinho') ?? [];

    double total = 0.0;
    List<Map<String, dynamic>> list = [];

    for (var str in carrinhoJsonStr) {
      final item = jsonDecode(str);
      list.add(item);
      total += (item['preco'] as num).toDouble() * (item['qtd'] ?? 1);
    }

    setState(() {
      _itens = list;
      _totalGeral = total;
    });
  }

  Future<void> _removerItem(int index) async {
    final prefs = await SharedPreferences.getInstance();
    _itens.removeAt(index);

    List<String> newCarrinhoJsonStr = _itens.map((obj) => jsonEncode(obj)).toList();
    await prefs.setStringList('carrinho', newCarrinhoJsonStr);

    _carregarCarrinhoLocal();
  }

  Future<void> _enviarPedidoParaCozinha() async {
    if (_itens.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sua comanda está vazia!')),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id') ?? 0;

    if (usuarioId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão inválida. Faça login novamente.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final itensJson = jsonEncode(_itens);
      final pedido = ComandaPedido(
        usuarioId: usuarioId,
        itensJson: itensJson,
        valorTotal: _totalGeral,
      );

      final response = await ApiService.criarPedido(pedido);

      if (!mounted) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        await prefs.remove('carrinho');
        _carregarCarrinhoLocal();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pedido enviado para a cozinha! Buon Appetito!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao enviar pedido. HTTP ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minha Comanda / Carrinho')),
      body: _itens.isEmpty
          ? const Center(
              child: Text(
                'Sua comanda está vazia no momento.\nAdicione pratos pelo Cardápio!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _itens.length,
                    itemBuilder: (context, index) {
                      final item = _itens[index];
                      return Card(
                        child: ListTile(
                          title: Text(item['nome'], style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Preço: R\$ ${(item['preco'] as num).toStringAsFixed(2)}'),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: FlorencaApp.florencaWine),
                            onPressed: () => _removerItem(index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total da Comanda:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text('R\$ ${_totalGeral.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: FlorencaApp.florencaWine)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: FlorencaApp.florencaWine, foregroundColor: Colors.white),
                          onPressed: _isLoading ? null : _enviarPedidoParaCozinha,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('ENVIAR PEDIDO PARA A COZINHA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
