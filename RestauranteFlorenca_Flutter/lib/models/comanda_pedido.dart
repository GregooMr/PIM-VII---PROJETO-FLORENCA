class ComandaPedido {
  final int id;
  final int usuarioId;
  final String itensJson;
  final double valorTotal;
  final String status;
  final String? createdAt;

  ComandaPedido({
    this.id = 0,
    required this.usuarioId,
    required this.itensJson,
    required this.valorTotal,
    this.status = 'ENVIADO',
    this.createdAt,
  });

  factory ComandaPedido.fromJson(Map<String, dynamic> json) {
    return ComandaPedido(
      id: json['id'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      itensJson: json['itensJson'] ?? '[]',
      valorTotal: (json['valorTotal'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? 'ENVIADO',
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'itensJson': itensJson,
      'valorTotal': valorTotal,
      'status': status,
    };
  }
}
