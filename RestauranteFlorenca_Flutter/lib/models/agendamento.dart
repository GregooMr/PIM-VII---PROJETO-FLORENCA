class Agendamento {
  final int id;
  final int usuarioId;
  final String dataHora;
  final int qtdPessoas;
  final bool isPcd;
  final String nomePcd;
  final String tipoPcd;
  final String status;

  Agendamento({
    this.id = 0,
    required this.usuarioId,
    required this.dataHora,
    required this.qtdPessoas,
    this.isPcd = false,
    this.nomePcd = '',
    this.tipoPcd = '',
    this.status = 'CONFIRMADO',
  });

  factory Agendamento.fromJson(Map<String, dynamic> json) {
    return Agendamento(
      id: json['id'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      dataHora: json['dataHora'] ?? '',
      qtdPessoas: json['qtdPessoas'] ?? 1,
      isPcd: json['isPcd'] ?? false,
      nomePcd: json['nomePcd'] ?? '',
      tipoPcd: json['tipoPcd'] ?? '',
      status: json['status'] ?? 'CONFIRMADO',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'dataHora': dataHora,
      'qtdPessoas': qtdPessoas,
      'isPcd': isPcd,
      'nomePcd': nomePcd,
      'tipoPcd': tipoPcd,
      'status': status,
    };
  }
}
