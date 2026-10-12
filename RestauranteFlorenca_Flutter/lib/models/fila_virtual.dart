class FilaVirtual {
  final int id;
  final int usuarioId;
  final int qtdPessoas;
  final String status;
  final String? createdAt;

  FilaVirtual({
    this.id = 0,
    required this.usuarioId,
    required this.qtdPessoas,
    this.status = 'AGUARDANDO',
    this.createdAt,
  });

  factory FilaVirtual.fromJson(Map<String, dynamic> json) {
    return FilaVirtual(
      id: json['id'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      qtdPessoas: json['qtdPessoas'] ?? 1,
      status: json['status'] ?? 'AGUARDANDO',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'qtdPessoas': qtdPessoas,
      'status': status,
    };
  }
}
