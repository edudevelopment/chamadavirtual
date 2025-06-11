import 'package:chamadavirtual/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/turma.dart';
import '../models/aluno.dart';
import '../models/chamada.dart';

class FazerChamadaPage extends StatefulWidget {
  final Turma turma;

  const FazerChamadaPage({super.key, required this.turma});

  @override
  State<FazerChamadaPage> createState() => _FazerChamadaPageState();
}

class _FazerChamadaPageState extends State<FazerChamadaPage> with TickerProviderStateMixin {
  late List<Aluno> _alunos;
  bool _isSaving = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _alunos = widget.turma.alunos.map((aluno) => 
      aluno.copyWith(presente: false)).toList();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  int get _totalPresentes => _alunos.where((aluno) => aluno.presente).length;
  int get _totalAusentes => _alunos.length - _totalPresentes;

  void _togglePresenca(int index) {
    setState(() {
      _alunos[index] = _alunos[index].copyWith(presente: !_alunos[index].presente);
    });
  }

  Future<void> _finalizarChamada() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final alunosPresentes = _alunos
          .where((aluno) => aluno.presente)
          .map((aluno) => aluno.nome)
          .toList();
      
      final alunosAusentes = _alunos
          .where((aluno) => !aluno.presente)
          .map((aluno) => aluno.nome)
          .toList();

      final chamada = Chamada(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        turmaId: widget.turma.id,
        nomeTurma: widget.turma.nome,
        dataHora: DateTime.now(),
        alunosPresentes: alunosPresentes,
        alunosAusentes: alunosAusentes,
        totalPresentes: _totalPresentes,
        totalAusentes: _totalAusentes,
      );

      await StorageService.addChamada(chamada);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chamada finalizada! $_totalPresentes presentes, $_totalAusentes ausentes'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao salvar chamada'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Fazer Chamada',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          _buildHeader(),
          _buildCounters(),
          Expanded(child: _buildAlunosList()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.school,
                color: Colors.black,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.turma.nome,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.black.withOpacity(0.9),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd/MM/yyyy - HH:mm').format(DateTime.now()),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.black.withOpacity(0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCounters() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.scale(
          scale: _animation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: _buildCounterCard(
                    'Presentes',
                    _totalPresentes.toString(),
                    Colors.green,
                    Icons.check_circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildCounterCard(
                    'Ausentes',
                    _totalAusentes.toString(),
                    Colors.red,
                    Icons.cancel,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCounterCard(String label, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlunosList() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 211, 185, 246),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.group,
                  color: Colors.black,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Alunos (${_alunos.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              itemCount: _alunos.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final aluno = _alunos[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: aluno.presente
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                      width: aluno.presente ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: aluno.presente
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.outline.withOpacity(0.2),
                        child: Icon(
                          Icons.person,
                          color: Colors.black,
                        )
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          aluno.nome,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.black,
                            fontWeight: aluno.presente ? FontWeight.w500 : FontWeight.normal,
                          ),
                        ),
                      ),
                      Transform.scale(
                        scale: 1.2,
                        child: Checkbox(
                          value: aluno.presente,
                          onChanged: (_) => _togglePresenca(index),
                          activeColor: Theme.of(context).colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: _isSaving ? null : _finalizarChamada,
            icon: _isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Icon(
                  Icons.check,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
            label: Text(
              _isSaving ? 'Salvando...' : 'Finalizar Chamada',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}