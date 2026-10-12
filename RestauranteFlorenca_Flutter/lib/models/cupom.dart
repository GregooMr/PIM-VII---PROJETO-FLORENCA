class Cupom {
  final int id;
  final int usuarioId;
  final String nomePromocao;
  final String codigoCupom;
  final bool isUsado;

  Cupom({
    this.id = 0,
    required this.usuarioId,
    required this.nomePromocao,
    required this.codigoCupom,
    this.isUsado = false,
  });

  factory Cupom.fromJson(Map<String, dynamic> json) {
    return Cupom(
      id: json['id'] ?? 0,
      usuarioId: json['usuarioId'] ?? 0,
      nomePromocao: json['nomePromocao'] ?? '',
      codigoCupom: json['codigoCupom'] ?? '',
      isUsado: json['isUsado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'usuarioId': usuarioId,
      'nomePromocao': nomePromocao,
      'codigoCupom': codigoCupom,
      'isUsado': isUsado,
    };
  }
}
