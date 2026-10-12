import 'package:flutter/material.dart';
import '../main.dart';

class FidelidadeScreen extends StatelessWidget {
  const FidelidadeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Programa de Fidelidade')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text('⭐ Cartão de Fidelidade Florença', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: FlorencaApp.florencaWine)),
                    SizedBox(height: 8),
                    Text('A cada 5 pedidos ou reservas concluídas, ganhe 1 sobremesa Tiramisù grátis!'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(5, (index) {
                final isConquistado = index < 3;
                return Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: isConquistado ? FlorencaApp.florencaOlive : Colors.grey[400],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      isConquistado ? '⭐\n${index + 1}' : '🔒\n${index + 1}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            const Text('Progresso atual: 3 de 5 selos conquistados.', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
