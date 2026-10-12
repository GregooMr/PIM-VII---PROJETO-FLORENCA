class Favorito {
  final int id;
  final int usuarioId;
  final String pratoNome;
  final double preco;
  final String? createdAt;

  Favorito({
    this.id = 0,
    required this.usuarioId,
    required this.pratoNome,
    required this.preco,
    this.createdAt,
  });

  factory Favorito.fromJson(Map<String, dynamic> json) {
    return Favorito(
      id: json['id'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      pratoNome: json['pratoNome'] ?? '',
      preco: (json['preco'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['createdAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'pratoNome': pratoNome,
      'preco': preco,
    };
  }
}
