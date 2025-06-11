import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/turma.dart';
import '../../models/aluno.dart';
import '../../models/chamada.dart';

class StorageService {
  static const String _turmasKey = 'turmas';
  static const String _chamadasKey = 'chamadas';

  // Turmas
  static Future<List<Turma>> getTurmas() async {
    final prefs = await SharedPreferences.getInstance();
    final turmasJson = prefs.getString(_turmasKey);
    
    if (turmasJson == null) { //REMOVER DEPOIS DE PRONTO
      // Retorna dados de exemplo na primeira execução
      return _getDadosExemplo();
    }
    
    final List<dynamic> turmasList = jsonDecode(turmasJson);
    return turmasList.map((json) => Turma.fromJson(json)).toList();
  }

  static Future<void> saveTurmas(List<Turma> turmas) async {
    final prefs = await SharedPreferences.getInstance();
    final turmasJson = jsonEncode(turmas.map((turma) => turma.toJson()).toList());
    await prefs.setString(_turmasKey, turmasJson);
  }

  static Future<void> addTurma(Turma turma) async {
    final turmas = await getTurmas();
    turmas.add(turma);
    await saveTurmas(turmas);
  }

  static Future<void> updateTurma(Turma turmaAtualizada) async {
    final turmas = await getTurmas();
    final index = turmas.indexWhere((turma) => turma.id == turmaAtualizada.id);
    if (index != -1) {
      turmas[index] = turmaAtualizada;
      await saveTurmas(turmas);
    }
  }

  static Future<void> deleteTurma(String turmaId) async {
    final turmas = await getTurmas();
    turmas.removeWhere((turma) => turma.id == turmaId);
    await saveTurmas(turmas);
  }

  // Chamadas
  static Future<List<Chamada>> getChamadas() async {
    final prefs = await SharedPreferences.getInstance();
    final chamadasJson = prefs.getString(_chamadasKey);
    
    if (chamadasJson == null) {
      return [];
    }
    
    final List<dynamic> chamadasList = jsonDecode(chamadasJson);
    return chamadasList.map((json) => Chamada.fromJson(json)).toList();
  }

  static Future<void> saveChamadas(List<Chamada> chamadas) async {
    final prefs = await SharedPreferences.getInstance();
    final chamadasJson = jsonEncode(chamadas.map((chamada) => chamada.toJson()).toList());
    await prefs.setString(_chamadasKey, chamadasJson);
  }

  static Future<void> addChamada(Chamada chamada) async {
    final chamadas = await getChamadas();
    chamadas.insert(0, chamada); // Adiciona no início para mostrar as mais recentes primeiro
    await saveChamadas(chamadas);
  }

  // Dados de exemplo
  static List<Turma> _getDadosExemplo() {
    return [
      Turma(
        id: '1',
        nome: '6º Ano A',
        dataCriacao: DateTime.now().subtract(const Duration(days: 30)),
        alunos: [
          Aluno(id: '1_1', nome: 'Ana Silva'),
          Aluno(id: '1_2', nome: 'Bruno Santos'),
          Aluno(id: '1_3', nome: 'Carlos Oliveira'),
          Aluno(id: '1_4', nome: 'Diana Costa'),
          Aluno(id: '1_5', nome: 'Eduardo Lima'),
          Aluno(id: '1_6', nome: 'Fernanda Souza'),
        ],
      ),
      Turma(
        id: '2',
        nome: '7º Ano B',
        dataCriacao: DateTime.now().subtract(const Duration(days: 25)),
        alunos: [
          Aluno(id: '2_1', nome: 'Gabriel Ferreira'),
          Aluno(id: '2_2', nome: 'Helena Martins'),
          Aluno(id: '2_3', nome: 'Igor Alves'),
          Aluno(id: '2_4', nome: 'Julia Pereira'),
          Aluno(id: '2_5', nome: 'Lucas Rodrigues'),
          Aluno(id: '2_6', nome: 'Mariana Torres'),
          Aluno(id: '2_7', nome: 'Nicolas Barbosa'),
        ],
      ),
      Turma(
        id: '3',
        nome: '8º Ano C',
        dataCriacao: DateTime.now().subtract(const Duration(days: 20)),
        alunos: [
          Aluno(id: '3_1', nome: 'Olivia Nascimento'),
          Aluno(id: '3_2', nome: 'Pedro Campos'),
          Aluno(id: '3_3', nome: 'Quintina Moura'),
          Aluno(id: '3_4', nome: 'Rafael Dias'),
          Aluno(id: '3_5', nome: 'Sofia Carvalho'),
        ],
      ),
    ];
  }
}