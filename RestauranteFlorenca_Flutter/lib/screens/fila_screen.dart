import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/fila_virtual.dart';
import '../services/api_service.dart';

class FilaScreen extends StatefulWidget {
  const FilaScreen({super.key});

  @override
  State<FilaScreen> createState() => _FilaScreenState();
}

class _FilaScreenState extends State<FilaScreen> {
  FilaVirtual? _minhaFila;
  Timer? _timer;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _atualizarFila();
    _iniciarPolling();
  }

  void _iniciarPolling() {
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _atualizarFila());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _atualizarFila() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id') ?? 0;

    if (usuarioId <= 0) return;

    try {
      final response = await ApiService.obterFilaUsuario(usuarioId);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        FilaVirtual? ativa;
        for (var item in list) {
          final f = FilaVirtual.fromJson(item);
          if (f.status == 'AGUARDANDO' || f.status == 'MESA_PRONTA') {
            ativa = f;
            break;
          }
        }
        if (mounted) setState(() => _minhaFila = ativa);
      }
    } catch (e) {
      // Ignora erro
    }
  }

  Future<void> _entrarNaFila() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id') ?? 0;

    setState(() => _isLoading = true);

    try {
      final entrada = FilaVirtual(usuarioId: usuarioId, qtdPessoas: 2);
      final response = await ApiService.entrarFila(entrada);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _atualizarFila();
      }
    } catch (e) {
      // Erro
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _sairDaFila() async {
    if (_minhaFila == null) return;
    setState(() => _isLoading = true);
    try {
      final response = await ApiService.cancelarFila(_minhaFila!.id);
      if (response.statusCode == 200) {
        setState(() => _minhaFila = null);
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
      appBar: AppBar(title: const Text('Fila Virtual de Espera')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      if (_minhaFila == null) ...[
                        const Text('Você não está na fila virtual', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        const Text('Entre na fila sem precisar aguardar fisicamente na recepção.'),
                      ] else if (_minhaFila!.status == 'MESA_PRONTA') ...[
                        const Text('🎉 SUA MESA ESTÁ PRONTA!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: FlorencaApp.florencaWine)),
                        const SizedBox(height: 12),
                        const Text('Dirija-se à recepção do salão para ser acomodado.'),
                      ] else ...[
                        const Text('Você está na Fila Virtual!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FlorencaApp.florencaWine)),
                        const SizedBox(height: 12),
                        const Text('Posição aproximada: 1ª da fila', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 6),
                        const Text('Tempo estimado: 5 minutos'),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _minhaFila == null ? FlorencaApp.florencaWine : Colors.grey[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _isLoading
                      ? null
                      : (_minhaFila == null ? _entrarNaFila : _sairDaFila),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : Text(_minhaFila == null ? 'ENTRAR NA FILA' : 'SAIR DA FILA', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
