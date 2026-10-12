import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../models/agendamento.dart';
import '../services/api_service.dart';

class AgendamentoScreen extends StatefulWidget {
  const AgendamentoScreen({super.key});

  @override
  State<AgendamentoScreen> createState() => _AgendamentoScreenState();
}

class _AgendamentoScreenState extends State<AgendamentoScreen> {
  final _qtdController = TextEditingController(text: '2');
  final _nomePcdController = TextEditingController();
  bool _isPcd = false;
  String? _tipoPcd;
  DateTime _dataSelecionada = DateTime.now().add(const Duration(hours: 2));
  bool _isLoading = false;

  final List<String> _opcoesPcd = [
    'Cadeirante / Mobilidade Reduzida',
    'Acompanhado de Cão-Guia',
    'Deficiência Visual / Baixa Visão',
    'LIBRAS / Deficiência Auditiva',
    'Ambiente Silencioso / Sensibilidade Sensorial',
    'Restrição Alimentar Severa (Alergia / Intolerância)',
    'Outras Necessidades Especiais'
  ];

  Future<void> _confirmarReserva() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;

    final usuarioId = prefs.getInt('usuario_id') ?? 0;

    if (usuarioId <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sessão inválida. Faça login novamente.')),
      );
      return;
    }

    final qtd = int.tryParse(_qtdController.text.trim()) ?? 0;
    if (qtd < 1 || qtd > 50) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe uma quantidade de pessoas entre 1 e 50.'),
        ),
      );
      return;
    }

    if (_isPcd && (_tipoPcd == null || _tipoPcd!.trim().isEmpty)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o tipo de necessidade especial.'),
        ),
      );
      return;
    }

    if (!_dataSelecionada.isAfter(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('A data e o horário devem ser futuros.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final isoDataHora = _dataSelecionada.toIso8601String();
      final reserva = Agendamento(
        usuarioId: usuarioId,
        dataHora: isoDataHora,
        qtdPessoas: qtd,
        isPcd: _isPcd,
        nomePcd: _isPcd ? _nomePcdController.text.trim() : '',
        tipoPcd: _isPcd ? _tipoPcd! : '',
      );

      final response = await ApiService.criarAgendamento(reserva);

      if (!mounted) return;
      if (response.statusCode == 401 || response.statusCode == 403) return;

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Reserva confirmada no Restaurante Florença!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              ApiService.errorMessage(
                response,
                fallback: 'Erro ao criar reserva.',
              ),
            ),
          ),
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
      appBar: AppBar(title: const Text('Reservar Mesa / Atendimento PCD')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Agendamento de Mesa',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: FlorencaApp.florencaWine),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _qtdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantidade de Pessoas',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.people),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.grey)),
              leading: const Icon(Icons.calendar_today,
                  color: FlorencaApp.florencaWine),
              title: Text(
                  'Data/Hora: ${_dataSelecionada.day}/${_dataSelecionada.month}/${_dataSelecionada.year} às ${_dataSelecionada.hour}:${_dataSelecionada.minute.toString().padLeft(2, '0')}'),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _dataSelecionada,
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 90)),
                );
                if (date != null) {
                  if (!context.mounted) return;
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(_dataSelecionada),
                  );
                  if (time != null && mounted) {
                    setState(() {
                      _dataSelecionada = DateTime(date.year, date.month,
                          date.day, time.hour, time.minute);
                    });
                  }
                }
              },
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text(
                  'Necessita de Atendimento Exclusivo PCD / Especial?'),
              value: _isPcd,
              onChanged: (val) => setState(() => _isPcd = val ?? false),
            ),
            if (_isPcd) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _nomePcdController,
                decoration: const InputDecoration(
                  labelText: 'Nome da Pessoa com Necessidade Especial',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.accessible),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _tipoPcd,
                decoration: const InputDecoration(
                    labelText: 'Tipo de Necessidade Especial',
                    border: OutlineInputBorder()),
                items: _opcoesPcd
                    .map((e) => DropdownMenuItem(
                        value: e,
                        child: Text(e, style: const TextStyle(fontSize: 13))))
                    .toList(),
                onChanged: (val) => setState(() => _tipoPcd = val),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: FlorencaApp.florencaWine,
                    foregroundColor: Colors.white),
                onPressed: _isLoading ? null : _confirmarReserva,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CONFIRMAR RESERVA DE MESA',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
