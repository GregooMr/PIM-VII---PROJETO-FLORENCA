import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/cupom.dart';
import '../services/api_service.dart';

class PromocaoScreen extends StatelessWidget {
  const PromocaoScreen({super.key});

  Future<void> _resgatarCupom(BuildContext context, String nomePromocao) async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id') ?? 0;

    if (usuarioId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Faça login novamente.')),
      );
      return;
    }

    try {
      final codigo = 'FLOR-${Random().nextInt(8999) + 1000}';
      final cupom = Cupom(usuarioId: usuarioId, nomePromocao: nomePromocao, codigoCupom: codigo);

      final response = await ApiService.criarCupom(cupom);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final codGerado = body['codigoCupom'] ?? codigo;
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Cupom "$nomePromocao" resgatado!\nCódigo: $codGerado')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro de conexão: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Promoções & Cupons Exclusivos')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildCupomCard(context, 'Combo Massa em Dobro', 'Na compra de 1 Spaghetti, ganhe 50% de desconto no segundo.', FlorencaApp.florencaWine),
          _buildCupomCard(context, 'Festival de Risotos', '20% OFF em qualquer Risoto no jantar de terça a quinta.', FlorencaApp.florencaOlive),
          _buildCupomCard(context, 'Combo Bruschetta & Vinho', 'Ganhe 1 porção de Bruschetta ao pedir uma taça de vinho.', FlorencaApp.florencaWine),
        ],
      ),
    );
  }

  Widget _buildCupomCard(BuildContext context, String titulo, String desc, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🎟️ $titulo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 6),
            Text(desc, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: color, foregroundColor: Colors.white),
                onPressed: () => _resgatarCupom(context, titulo),
                child: const Text('RESGATAR CUPOM'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
