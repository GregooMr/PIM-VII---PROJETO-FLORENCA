import 'dart:convert';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/fila_virtual.dart';
import '../services/api_service.dart';

class FuncFilaScreen extends StatefulWidget {
  const FuncFilaScreen({super.key});

  @override
  State<FuncFilaScreen> createState() => _FuncFilaScreenState();
}

class _FuncFilaScreenState extends State<FuncFilaScreen> {
  List<FilaVirtual> _fila = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarFila();
  }

  Future<void> _carregarFila() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.obterFilaTodos();
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        setState(() {
          _fila = list.map((e) => FilaVirtual.fromJson(e)).where((f) => f.status == 'AGUARDANDO').toList();
        });
      }
    } catch (e) {
      // Erro
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _chamarProximo() async {
    if (_fila.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhum cliente aguardando na fila.')),
      );
      return;
    }

    final proximo = _fila.first;
    try {
      final response = await ApiService.chamarFila(proximo.id);
      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cliente #${proximo.usuarioId} chamado! Mesa pronta.')),
        );
        _carregarFila();
      }
    } catch (e) {
      // Erro
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gerenciador de Fila Virtual')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      title: Text('Clientes Aguardando: ${_fila.length}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: const Text('Gerencie o fluxo de atendimento da recepção.'),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(backgroundColor: FlorencaApp.florencaWine, foregroundColor: Colors.white),
                      onPressed: _chamarProximo,
                      icon: const Icon(Icons.notifications_active),
                      label: const Text('CHAMAR PRÓXIMO CLIENTE', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: _fila.isEmpty
                        ? const Center(child: Text('Nenhum cliente aguardando na fila.'))
                        : ListView.builder(
                            itemCount: _fila.length,
                            itemBuilder: (context, index) {
                              final item = _fila[index];
                              return Card(
                                child: ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: FlorencaApp.florencaWine,
                                    child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
                                  ),
                                  title: Text('Cliente #${item.usuarioId}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('Quantidade: ${item.qtdPessoas} pessoas'),
                                  trailing: const Chip(label: Text('AGUARDANDO')),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
