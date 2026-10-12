import 'package:flutter/material.dart';
import '../main.dart';
import 'func_agendamento_screen.dart';
import 'func_fila_screen.dart';
import 'func_pedido_screen.dart';
import 'func_promocao_screen.dart';
import 'login_screen.dart';
import '../services/api_service.dart';

class HomeFuncionarioScreen extends StatelessWidget {
  const HomeFuncionarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel da Equipe Staff'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService.logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Gestão & Operações do Restaurante',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FlorencaApp.florencaWine),
            ),
            const SizedBox(height: 20),
            _buildStaffButton(
              context,
              '👥 Gerenciar Fila Virtual\n(Chamar clientes e atualizar mesa)',
              FlorencaApp.florencaWine,
              () => const FuncFilaScreen(),
            ),
            const SizedBox(height: 16),
            _buildStaffButton(
              context,
              '📅 Visualizar Reservas & Mesas PCD\n(Conferir agendamentos e necessidades)',
              FlorencaApp.florencaOlive,
              () => const FuncAgendamentoScreen(),
            ),
            const SizedBox(height: 16),
            _buildStaffButton(
              context,
              '🎟️ Validar Cupons & Promoções\n(Consultar códigos resgatados)',
              FlorencaApp.florencaWine,
              () => const FuncPromocaoScreen(),
            ),
            const SizedBox(height: 16),
            _buildStaffButton(
              context,
              '🍳 Gerenciar Pedidos / Cozinha\n(Acompanhar e atualizar status dos pratos)',
              FlorencaApp.florencaOlive,
              () => const FuncPedidoScreen(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaffButton(BuildContext context, String text, Color color, Widget Function() screenBuilder) {
    return SizedBox(
      height: 80,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screenBuilder()));
        },
        child: Text(text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
