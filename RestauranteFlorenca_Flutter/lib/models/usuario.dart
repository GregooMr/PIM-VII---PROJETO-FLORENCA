class Usuario {
  final int id;
  final String nome;
  final String loginUsuario;
  final String senha;
  final String tipoUsuario;

  Usuario({
    required this.id,
    required this.nome,
    required this.loginUsuario,
    required this.senha,
    required this.tipoUsuario,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'] ?? 0,
      nome: json['nome'] ?? '',
      loginUsuario: json['loginUsuario'] ?? json['usuario'] ?? '',
      senha: json['senha'] ?? '',
      tipoUsuario: json['tipoUsuario'] ?? 'CLIENTE',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'loginUsuario': loginUsuario,
      'senha': senha,
      'tipoUsuario': tipoUsuario,
    };
  }
}
