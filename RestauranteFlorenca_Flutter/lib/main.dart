import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

/// ============================================================================
/// PROJETO ACADÊMICO: Sistema de Gestão Gastronômica - Restaurante Florença
/// PONTO DE ENTRADA FLUTTER: main.dart
/// DESCRIÇÃO: Inicializa a aplicação Flutter, aplica a paleta corporativa
///            (Vinho Bordô, Dourado, Oliva e Creme) e define a rota inicial.
/// ============================================================================

void main() {
  runApp(const FlorencaApp());
}

class FlorencaApp extends StatelessWidget {
  const FlorencaApp({super.key});

  // Cores Oficiais do Restaurante Florença
  static const Color florencaWine = Color(0xFF6B122C);
  static const Color florencaGold = Color(0xFFD4AF37);
  static const Color florencaOlive = Color(0xFF4A5D3E);
  static const Color florencaCreamBg = Color(0xFFFAF7F2);
  static const Color florencaCardLight = Color(0xFFFFFFFF);
  static const Color florencaTextDark = Color(0xFF2C2C2C);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurante Florença',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: florencaCreamBg,
        primaryColor: florencaWine,
        colorScheme: ColorScheme.fromSeed(
          seedColor: florencaWine,
          primary: florencaWine,
          secondary: florencaGold,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: florencaWine,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 2,
        ),
        useMaterial3: true,
      ),
      home: const LoginScreen(),
    );
  }
}
