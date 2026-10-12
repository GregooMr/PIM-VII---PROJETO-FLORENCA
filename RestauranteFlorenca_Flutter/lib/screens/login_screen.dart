import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../services/api_service.dart';
import 'cadastro_screen.dart';
import 'home_cliente_screen.dart';
import 'home_funcionario_screen.dart';

class LoginScreen extends StatefulWidget {
  final bool sessionExpired;

  const LoginScreen({super.key, this.sessionExpired = false});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _usuarioController = TextEditingController();
  final _senhaController = TextEditingController();
  bool _isFuncionario = false;
  bool _isLoading = false;
  String? _mensagemErro;

  @override
  void initState() {
    super.initState();
    if (widget.sessionExpired) {
      _mensagemErro = 'Sua sessão expirou. Entre novamente.';
    }
  }

  Future<void> _fazerLogin() async {
    final usuario = _usuarioController.text.trim();
    final senha = _senhaController.text;

    if (usuario.isEmpty || senha.isEmpty) {
      setState(() => _mensagemErro = 'Preencha usuário e senha.');
      return;
    }

    setState(() {
      _isLoading = true;
      _mensagemErro = null;
    });

    try {
      final response = await ApiService.login(usuario, senha);

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);
        final String tipo = userData['tipoUsuario'] ?? 'CLIENTE';
        final token = userData['token']?.toString().trim() ?? '';

        if (token.isEmpty) {
          setState(() {
            _mensagemErro = 'Não foi possível iniciar a sessão. Tente novamente.';
          });
          return;
        }

        if (_isFuncionario && tipo.toUpperCase() != 'FUNCIONARIO') {
          setState(() {
            _mensagemErro = 'Este usuário não possui acesso de funcionário.';
            _isLoading = false;
          });
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt('usuario_id', userData['id']);
        await prefs.setString('usuario_nome', userData['nome'] ?? '');
        await prefs.setString('usuario_tipo', tipo);
        await prefs.setString('token', token);
        ApiService.resetSessionExpiry();

        if (!mounted) return;

        if (tipo.toUpperCase() == 'FUNCIONARIO') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeFuncionarioScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeClienteScreen()),
          );
        }
      } else {
        setState(() {
          _mensagemErro = response.statusCode == 401
              ? 'Usuário ou senha incorretos.'
              : ApiService.errorMessage(
                  response,
                  fallback: 'Falha ao entrar.',
                );
        });
      }
    } catch (e) {
      setState(() {
        _mensagemErro = 'Falha de conexão com a API: $e';
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Imagem de Fundo do Restaurante com Ajuste de Tela
          Positioned.fill(
            child: Image.asset(
              'assets/images/restaurante.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(color: FlorencaApp.florencaWine);
              },
            ),
          ),
          // Camada Escura Semi-Transparente (Overlay)
          Positioned.fill(
            child: Container(
              color: Colors.black.withValues(alpha: 0.55),
            ),
          ),
          // Conteúdo centralizado (Card de Login)
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                elevation: 8,
                color: Colors.white.withValues(alpha: 0.95),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Restaurante Florença',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: FlorencaApp.florencaWine,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Trattoria Tradizionale & Culinária Plural',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _usuarioController,
                        decoration: const InputDecoration(
                          labelText: 'Usuário',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _senhaController,
                        obscureText: true,
                        decoration: const InputDecoration(
                          labelText: 'Senha',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.lock),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Checkbox(
                            value: _isFuncionario,
                            activeColor: FlorencaApp.florencaWine,
                            onChanged: (val) => setState(() => _isFuncionario = val ?? false),
                          ),
                          const Text(
                            'Acesso Equipe / Funcionário',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                      if (_mensagemErro != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          _mensagemErro!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: FlorencaApp.florencaWine,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: _isLoading ? null : _fazerLogin,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text('ENTRAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const CadastroScreen()),
                          );
                        },
                        child: const Text(
                          'Não possui conta? Cadastre-se aqui',
                          style: TextStyle(color: FlorencaApp.florencaWine, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

}
