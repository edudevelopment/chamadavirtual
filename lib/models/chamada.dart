class Chamada {
  final String id;
  final String turmaId;
  final String nomeTurma;
  final DateTime dataHora;
  final List<String> alunosPresentes;
  final List<String> alunosAusentes;
  final int totalPresentes;
  final int totalAusentes;

  Chamada({
    required this.id,
    required this.turmaId,
    required this.nomeTurma,
    required this.dataHora,
    required this.alunosPresentes,
    required this.alunosAusentes,
    required this.totalPresentes,
    required this.totalAusentes,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'turmaId': turmaId,
      'nomeTurma': nomeTurma,
      'dataHora': dataHora.toIso8601String(),
      'alunosPresentes': alunosPresentes,
      'alunosAusentes': alunosAusentes,
      'totalPresentes': totalPresentes,
      'totalAusentes': totalAusentes,
    };
  }

  factory Chamada.fromJson(Map<String, dynamic> json) {
    return Chamada(
      id: json['id'],
      turmaId: json['turmaId'],
      nomeTurma: json['nomeTurma'],
      dataHora: DateTime.parse(json['dataHora']),
      alunosPresentes: List<String>.from(json['alunosPresentes']),
      alunosAusentes: List<String>.from(json['alunosAusentes']),
      totalPresentes: json['totalPresentes'],
      totalAusentes: json['totalAusentes'],
    );
  }
}