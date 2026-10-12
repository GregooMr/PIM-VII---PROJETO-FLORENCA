import 'dart:convert';
import 'package:flutter/material.dart';
import '../main.dart';
import '../services/api_service.dart';

class FuncPromocaoScreen extends StatefulWidget {
  const FuncPromocaoScreen({super.key});

  @override
  State<FuncPromocaoScreen> createState() => _FuncPromocaoScreenState();
}

class _FuncPromocaoScreenState extends State<FuncPromocaoScreen> {
  final _codigoController = TextEditingController();
  bool _isLoading = false;

  Future<void> _validarEUsarCupom() async {
    final codigo = _codigoController.text.trim();
    if (codigo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite o código do cupom.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final resValidar = await ApiService.validarCupomFuncionario(codigo);

      if (!mounted) return;
      if (resValidar.statusCode == 401 || resValidar.statusCode == 403) return;

      if (resValidar.statusCode == 200) {
        final body = jsonDecode(resValidar.body);
        final cupomId = body['id'];

        final resUsar = await ApiService.usarCupom(cupomId);
        if (!mounted) return;
        if (resUsar.statusCode == 401 || resUsar.statusCode == 403) return;

        if (resUsar.statusCode == 200) {
          _codigoController.clear();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('✅ Cupom validado e marcado como utilizado!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(ApiService.errorMessage(resUsar))),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiService.errorMessage(resValidar))),
        );
      }
    } catch (e) {
      if (!mounted) return;
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
      appBar: AppBar(title: const Text('Validar Cupons / Recepção')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Informe o código do cupom apresentado pelo cliente no caixa para efetuar a validação e baixa no sistema.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _codigoController,
              decoration: const InputDecoration(
                labelText: 'Código do Cupom (Ex: FLOR-1234)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.confirmation_number),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: FlorencaApp.florencaWine, foregroundColor: Colors.white),
                onPressed: _isLoading ? null : _validarEUsarCupom,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('VALIDAR E MARCAR UTILIZADO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
