import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/favorito.dart';
import '../services/api_service.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  List<Favorito> _favoritos = [];
  String _nome = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPerfilEFavoritos();
  }

  Future<void> _carregarPerfilEFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    final usuarioId = prefs.getInt('usuario_id') ?? 0;
    _nome = prefs.getString('usuario_nome') ?? 'Cliente';

    if (usuarioId <= 0) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await ApiService.obterFavoritos(usuarioId);
      if (response.statusCode == 200) {
        final List<dynamic> list = jsonDecode(response.body);
        setState(() {
          _favoritos = list.map((e) => Favorito.fromJson(e)).toList();
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
      appBar: AppBar(title: const Text('Meu Perfil & Favoritos')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    color: Colors.white,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: FlorencaApp.florencaWine,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                      title: Text('Olá, $_nome!', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: const Text('Cliente do Restaurante Florença'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('❤️ Meus Pratos Favoritos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FlorencaApp.florencaWine)),
                  const SizedBox(height: 12),
                  Expanded(
                    child: _favoritos.isEmpty
                        ? const Center(child: Text('Você ainda não salvou pratos favoritos.'))
                        : ListView.builder(
                            itemCount: _favoritos.length,
                            itemBuilder: (context, index) {
                              final fav = _favoritos[index];
                              return Card(
                                child: ListTile(
                                  leading: const Text('❤️', style: TextStyle(fontSize: 20)),
                                  title: Text(fav.pratoNome, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  subtitle: Text('R\$ ${fav.preco.toStringAsFixed(2)}'),
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
