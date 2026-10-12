import 'package:flutter/material.dart';
import '../main.dart';

class SobreScreen extends StatelessWidget {
  const SobreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sobre a Florença Plural')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            _buildCard(
              'Responsabilidade Social & Diversidade',
              'Nossa culinária é italiana, mas nossa alma é plural. O Restaurante Florença tem o compromisso ativo com a equidade étnico-racial, o combate a qualquer forma de discriminação e o fortalecimento de equipes diversas na gastronomia.',
            ),
            const SizedBox(height: 16),
            _buildCard(
              'Legislação & Valorização Cultural',
              '• Lei 10.639/2003: Torna obrigatório o ensino da História e Cultura Afro-Brasileira, resgatando a contribuição decisiva do povo negro na formação do Brasil.\n\n'
              '• Lei 11.645/2008: Expande a legislação para incluir a História e Cultura dos Povos Indígenas.\n\n'
              'Na Florença, aplicamos essa diretriz através da formação contínua da nossa equipe e valorização da diversidade cultural.',
            ),
            const SizedBox(height: 16),
            _buildCard(
              'Propostas de Treinamento Corporativo',
              '1. Módulo de Atendimento Antirracista e Humanizado.\n'
              '2. Protocolo de Acolhimento e Acessibilidade para Pessoas com Deficiência (PCD).\n'
              '3. Capacitação em Linguagem Inclusiva e Diversidade Organizacional.',
            ),
            const SizedBox(height: 16),
            _buildCard(
              '♿ Recursos Tecnológicos de Acessibilidade no App',
              '• Deficiência Visual / Cobre-Cego: Suporte a Leitores de Tela (TalkBack/VoiceOver) através de Árvore Semântica nativa e descrições áudio-textuais.\n\n'
              '• Baixa Visão / Contraste: Paleta de alto contraste (WCAG AA/AAA) e suporte ao redimensionamento de fonte do sistema operacioanal.\n\n'
              '• Deficiência Auditiva / Surdos: Interface 100% visual com notificações por mensagens (SnackBars), além de opção de Atendimento presencial em LIBRAS nas reservas.\n\n'
              '• Sensibilidade Sensorial / Neurodivergentes: Opção de Reserva de Mesa para Ambientes Silenciosos e com iluminação reduzida.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Versão do App: 1.0.0 (Flutter) — Restaurante Florença Plural',
              style: TextStyle(color: Colors.grey, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(String title, String content) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: FlorencaApp.florencaWine)),
            const SizedBox(height: 10),
            Text(content, style: const TextStyle(fontSize: 14, height: 1.4, color: FlorencaApp.florencaTextDark)),
          ],
        ),
      ),
    );
  }
}
