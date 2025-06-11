import 'aluno.dart';

class Turma {
  final String id;
  String nome;
  List<Aluno> alunos;
  final DateTime dataCriacao;

  Turma({
    required this.id,
    required this.nome,
    required this.alunos,
    required this.dataCriacao,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'alunos': alunos.map((aluno) => aluno.toJson()).toList(),
      'dataCriacao': dataCriacao.toIso8601String(),
    };
  }

  factory Turma.fromJson(Map<String, dynamic> json) {
    return Turma(
      id: json['id'],
      nome: json['nome'],
      alunos: (json['alunos'] as List)
          .map((alunoJson) => Aluno.fromJson(alunoJson))
          .toList(),
      dataCriacao: DateTime.parse(json['dataCriacao']),
    );
  }

  Turma copyWith({
    String? id,
    String? nome,
    List<Aluno>? alunos,
    DateTime? dataCriacao,
  }) {
    return Turma(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      alunos: alunos ?? this.alunos,
      dataCriacao: dataCriacao ?? this.dataCriacao,
    );
  }
}