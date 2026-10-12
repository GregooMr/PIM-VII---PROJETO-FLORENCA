import 'dart:convert';
import 'package:flutter/material.dart';
import '../main.dart';
import '../models/agendamento.dart';
import '../services/api_service.dart';

class FuncAgendamentoScreen extends StatefulWidget {
  const FuncAgendamentoScreen({super.key});

  @override
  State<FuncAgendamentoScreen> createState() => _FuncAgendamentoScreenState();
}

class _FuncAgendamentoScreenState extends State<FuncAgendamentoScreen> {
  List<Agendamento> _reservas = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarReservas();
  }

  Future<void> _carregarReservas() async {
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.obterTodosAgendamentos();
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        setState(() {
          _reservas = list.map((e) => Agendamento.fromJson(e)).toList();
        });
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
      appBar: AppBar(
        title: const Text('Reservas & Mesas PCD'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _carregarReservas),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reservas.isEmpty
              ? const Center(child: Text('Nenhum agendamento cadastrado.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reservas.length,
                  itemBuilder: (context, index) {
                    final item = _reservas[index];
                    return Card(
                      color: item.isPcd ? const Color(0xFFFFF0F5) : Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('📅 Data/Hora: ${item.dataHora.replaceAll('T', ' ')}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                            Text('👥 Pessoas: ${item.qtdPessoas}'),
                            Text(
                              '♿ Requer Mesa PCD: ${item.isPcd ? "SIM (Atenção Especial)" : "Não"}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: item.isPcd ? FlorencaApp.florencaWine : Colors.black,
                              ),
                            ),
                            if (item.isPcd) Text('👤 Convidado: ${item.nomePcd} (${item.tipoPcd})'),
                            Text('STATUS: ${item.status}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
