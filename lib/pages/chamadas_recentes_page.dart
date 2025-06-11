import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/chamada.dart';
import '../services/storage_service.dart';

class ChamadasRecentesPage extends StatefulWidget {
  const ChamadasRecentesPage({super.key});

  @override
  State<ChamadasRecentesPage> createState() => _ChamadasRecentesPageState();
}

class _ChamadasRecentesPageState extends State<ChamadasRecentesPage> with TickerProviderStateMixin {
  List<Chamada> _chamadas = [];
  bool _isLoading = true;
  Set<String> _expandedItems = {};
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadChamadas();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadChamadas() async {
    try {
      final chamadas = await StorageService.getChamadas();
      setState(() {
        _chamadas = chamadas;
        _isLoading = false;
      });
      _animationController.forward();
    } catch (e) {
      setState(() {
        _chamadas = [];
        _isLoading = false;
      });
    }
  }

  void _toggleExpanded(String chamadaId) {
    setState(() {
      if (_expandedItems.contains(chamadaId)) {
        _expandedItems.remove(chamadaId);
      } else {
        _expandedItems.add(chamadaId);
      }
    });
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
          'Chamadas Recentes',
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
              _loadChamadas();
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _chamadas.isEmpty
              ? _buildEmptyState()
              : _buildChamadasList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 80,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhuma chamada realizada',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'As chamadas realizadas aparecerão aqui',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChamadasList() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _chamadas.length,
          itemBuilder: (context, index) {
            final chamada = _chamadas[index];
            final isExpanded = _expandedItems.contains(chamada.id);
            
            return AnimatedContainer(
              duration: Duration(milliseconds: 200 + (index * 50)),
              curve: Curves.easeOutBack,
              margin: const EdgeInsets.only(bottom: 16),
              child: Transform.translate(
                offset: Offset(0, (1 - _animationController.value) * 50),
                child: Opacity(
                  opacity: _animationController.value,
                  child: _buildChamadaCard(chamada, isExpanded),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildChamadaCard(Chamada chamada, bool isExpanded) {
    return Container(
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
          onTap: () => _toggleExpanded(chamada.id),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildChamadaHeader(chamada, isExpanded),
                if (isExpanded) ...[
                  const SizedBox(height: 20),
                  _buildChamadaDetails(chamada),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChamadaHeader(Chamada chamada, bool isExpanded) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.school,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chamada.nomeTurma,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('dd/MM/yyyy - HH:mm').format(chamada.dataHora),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedRotation(
              turns: isExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildStatusChip(
              '✅ ${chamada.totalPresentes} presentes',
              Theme.of(context).colorScheme.secondary,
            ),
            const SizedBox(width: 8),
            _buildStatusChip(
              '❌ ${chamada.totalAusentes} ausentes',
              Theme.of(context).colorScheme.error,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildChamadaDetails(Chamada chamada) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 1,
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        const SizedBox(height: 20),
        if (chamada.alunosPresentes.isNotEmpty) ...[
          _buildAlunosSection(
            'Presentes',
            chamada.alunosPresentes,
            Theme.of(context).colorScheme.secondary,
            Icons.check_circle,
          ),
          const SizedBox(height: 16),
        ],
        if (chamada.alunosAusentes.isNotEmpty) ...[
          _buildAlunosSection(
            'Ausentes',
            chamada.alunosAusentes,
            Theme.of(context).colorScheme.error,
            Icons.cancel,
          ),
        ],
      ],
    );
  }

  Widget _buildAlunosSection(String title, List<String> alunos, Color color, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: color,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              '$title (${alunos.length})',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: alunos.map((aluno) => _buildAlunoChip(aluno, color)).toList(),
        ),
      ],
    );
  }

  Widget _buildAlunoChip(String nome, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 8,
            backgroundColor: color,
            child: Text(
              nome.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            nome,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}