import 'package:flutter/material.dart';
import '../main.dart';
import 'agendamento_screen.dart';
import 'cardapio_screen.dart';
import 'carrinho_screen.dart';
import 'fidelidade_screen.dart';
import 'fila_screen.dart';
import 'historico_screen.dart';
import 'login_screen.dart';
import 'perfil_screen.dart';
import 'promocao_screen.dart';
import 'sobre_screen.dart';

class HomeClienteScreen extends StatelessWidget {
  const HomeClienteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurante Florença'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const PerfilScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: FlorencaApp.florencaWine),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Restaurante Florença', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Gastronomia & Inclusão Social', style: TextStyle(color: FlorencaApp.florencaGold, fontSize: 14)),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Cardápio Digital'),
              onTap: () => _navegar(context, const CardapioScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.event_seat),
              title: const Text('Reservar Mesa / PCD'),
              onTap: () => _navegar(context, const AgendamentoScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('Fila Virtual'),
              onTap: () => _navegar(context, const FilaScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.shopping_cart),
              title: const Text('Minha Comanda / Carrinho'),
              onTap: () => _navegar(context, const CarrinhoScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Histórico de Pedidos & Reservas'),
              onTap: () => _navegar(context, const HistoricoScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.local_offer),
              title: const Text('Promoções & Cupons'),
              onTap: () => _navegar(context, const PromocaoScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.card_membership),
              title: const Text('Programa de Fidelidade'),
              onTap: () => _navegar(context, const FidelidadeScreen()),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Sobre a Florença Plural'),
              onTap: () => _navegar(context, const SobreScreen()),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Bem-vindo ao Restaurante Florença!\nCombine a autêntica culinária italiana com inovação tecnológica e acolhimento inclusivo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: FlorencaApp.florencaTextDark),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildHomeButton(context, '📖 Cardápio', Icons.restaurant_menu, FlorencaApp.florencaWine, () => const CardapioScreen()),
                  _buildHomeButton(context, '📅 Reservar / PCD', Icons.event_seat, FlorencaApp.florencaOlive, () => const AgendamentoScreen()),
                  _buildHomeButton(context, '👥 Fila Virtual', Icons.people, FlorencaApp.florencaWine, () => const FilaScreen()),
                  _buildHomeButton(context, '🎟️ Promoções', Icons.local_offer, FlorencaApp.florencaOlive, () => const PromocaoScreen()),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navegar(BuildContext context, Widget screen) {
    Navigator.pop(context);
    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  Widget _buildHomeButton(BuildContext context, String title, IconData icon, Color color, Widget Function() screenBuilder) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => screenBuilder())),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 42, color: color),
            const SizedBox(height: 12),
            Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
