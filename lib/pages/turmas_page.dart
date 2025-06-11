import 'package:chamadavirtual/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/turma.dart';
import 'editar_turma_page.dart';
import 'chamada_page.dart';

class TurmasProvider extends ChangeNotifier {
  List<Turma> _turmas = [];
  bool _isLoading = true;

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

class TurmasPage extends StatefulWidget {
  const TurmasPage({super.key});

  @override
  State<TurmasPage> createState() => _TurmasPageState();
}

class _TurmasPageState extends State<TurmasPage> {
    List<Turma> _turmas = [];
    bool _isLoading = true;
    late AnimationController _animationController;
    
    Future<void> _loadTurmas() async {
    try {
      final turmas = await StorageService.getTurmas();
      setState(() {
        _turmas = turmas;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _turmas = [];
        _isLoading = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => TurmasProvider()..loadTurmas(),
      child: Scaffold(
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
            'Turmas',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
          actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: () {
              setState(() {
                _isLoading = true;
              });
              _loadTurmas();
            },
          ),
        ],
        ),
        body: Consumer<TurmasProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (provider.turmas.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 80,
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhuma turma cadastrada',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Toque no botão + para adicionar sua primeira turma',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.turmas.length,
              itemBuilder: (context, index) {
                final turma = provider.turmas[index];
                return _buildTurmaCard(context, turma, provider);
              },
            );
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showAddTurmaDialog(context),
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: Icon(
            Icons.add,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          label: Text(
            'Nova Turma',
            style: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTurmaCard(BuildContext context, Turma turma, TurmasProvider provider) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _navigateToEditTurma(context, turma),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.school,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            turma.nome,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${turma.alunos.length} alunos',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: const Color.fromARGB(255, 71, 71, 71),
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Colors.black,
                      ),
                      onSelected: (value) {
                        if (value == 'delete') {
                          _showDeleteConfirmation(context, turma, provider);
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Excluir'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToEditTurma(context, turma),
                        icon: Icon(
                          Icons.edit,
                          size: 18,
                          color: Theme.of(context).colorScheme.onSecondary,
                        ),
                        label: Text(
                          'Editar',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSecondary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.secondary,
                          foregroundColor: Theme.of(context).colorScheme.onSecondary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: turma.alunos.isEmpty 
                          ? null 
                          : () => _navigateToFazerChamada(context, turma),
                        icon: Icon(
                          Icons.how_to_reg,
                          size: 18,
                          color: turma.alunos.isEmpty 
                            ? Colors.grey
                            : Theme.of(context).colorScheme.onPrimary,
                        ),
                        label: Text(
                          'Chamada',
                          style: TextStyle(
                            color: turma.alunos.isEmpty 
                              ? Colors.grey
                              : Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: turma.alunos.isEmpty 
                            ? const Color.fromARGB(255, 100, 100, 100)
                            : Theme.of(context).colorScheme.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToEditTurma(BuildContext context, Turma turma) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditarTurmaPage(turma: turma),
      ),
    );
    if (context.mounted) {
      Provider.of<TurmasProvider>(context, listen: false).loadTurmas();
    }
  }

  void _navigateToFazerChamada(BuildContext context, Turma turma) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FazerChamadaPage(turma: turma),
      ),
    );
  }

  void _showAddTurmaDialog(BuildContext context) {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Nova Turma'),
        content: TextField(
          style: TextStyle(color: Colors.white),
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Nome da turma',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Provider.of<TurmasProvider>(dialogContext, listen: false)
                    .addTurma(controller.text.trim());
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Criar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Turma turma, TurmasProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirmar exclusão'),
        content: Text('Deseja realmente excluir a turma "${turma.nome}"?', style: TextStyle(color: Colors.white),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
          ElevatedButton(
            onPressed: () {
              provider.deleteTurma(turma.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
  

}