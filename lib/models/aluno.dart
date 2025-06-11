class Aluno {
  final String id;
  final String nome;
  bool presente;

  Aluno({
    required this.id,
    required this.nome,
    this.presente = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'presente': presente,
    };
  }

  factory Aluno.fromJson(Map<String, dynamic> json) {
    return Aluno(
      id: json['id'],
      nome: json['nome'],
      presente: json['presente'] ?? false,
    );
  }

  Aluno copyWith({
    String? id,
    String? nome,
    bool? presente,
  }) {
    return Aluno(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      presente: presente ?? this.presente,
    );
  }
}