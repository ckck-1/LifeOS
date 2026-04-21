import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/task_model.dart';
import '../core/task_service.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final TaskService _service = TaskService();
  List<LifeTask> _activeTasks = [];
  List<LifeTask> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _service.fetchTasks();
    setState(() {
      _activeTasks = data;
      _loading = false;
    });
  }

  void _handleSwipeComplete(int index) {
    setState(() {
      final task = _activeTasks.removeAt(index);
      task.completed = true;
      task.completedAt = "Just now";
      _history.insert(0, task);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _loading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF660000)))
        : Padding(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Tasks", style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                Text("${_activeTasks.length} remaining · AI-ranked by impact", 
                     style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 14)),
                const SizedBox(height: 24),
                Expanded(
                  child: ListView.builder(
                    itemCount: _activeTasks.length,
                    itemBuilder: (context, index) => _buildTaskCard(_activeTasks[index], index),
                  ),
                ),
                if (_history.isNotEmpty) _buildHistorySection(),
              ],
            ),
          ),
    );
  }

  Widget _buildTaskCard(LifeTask task, int index) {
    return Dismissible(
      key: Key(task.id ?? index.toString()),
      onDismissed: (_) => _handleSwipeComplete(index),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: const Color(0xFF83A88D).withOpacity(0.1),
        child: const Icon(LucideIcons.check, color: Color(0xFF83A88D)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF121316),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            _buildRankCircle(task.aiRank),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(task.title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  Text(task.description, style: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRankCircle(int rank) {
    bool isTop = rank == 1;
    return Container(
      width: 28, height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isTop ? const Color(0xFF50040C).withOpacity(0.3) : Colors.white.withOpacity(0.05),
      ),
      child: Center(
        child: Text(rank.toString(), 
          style: TextStyle(color: isTop ? Colors.red : Colors.white30, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildHistorySection() {
    return Column(
      children: [
        const Divider(color: Colors.white10),
        const Text("HISTORY", style: TextStyle(color: Colors.white24, fontSize: 10, letterSpacing: 1.5)),
        ..._history.take(3).map((t) => ListTile(
          leading: const Icon(LucideIcons.check, size: 16, color: Colors.white24),
          title: Text(t.title, style: const TextStyle(color: Colors.white24, decoration: TextDecoration.lineThrough, fontSize: 14)),
        )),
      ],
    );
  }
}