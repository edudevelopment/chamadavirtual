import 'package:chamadavirtual/models/turma.dart';
import 'package:chamadavirtual/services/storage_service.dart';
import 'package:flutter/material.dart';

class TurmasProvider extends ChangeNotifier {
  List<Turma> _turmas = [];
  bool _isLoading = false;

  List<Turma> get turmas => _turmas;
  bool get isLoading => _isLoading;

  Future<void> loadTurmas() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      _turmas = await StorageService.getTurmas();
    } catch (e) {
      _turmas = [];
    }
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTurma(String nome) async {
    final novaTurma = Turma(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      nome: nome,
      alunos: [],
      dataCriacao: DateTime.now(),
    );
    
    await StorageService.addTurma(novaTurma);
    await loadTurmas();
  }

  Future<void> deleteTurma(String turmaId) async {
    await StorageService.deleteTurma(turmaId);
    await loadTurmas();
  }
}