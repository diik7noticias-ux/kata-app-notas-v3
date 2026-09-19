import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

part 'home_screen.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  final String title;

  @HiveField(1)
  bool isCompleted;

  Task({
    required this.title,
    this.isCompleted = false,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Box<Task> taskBox;

  @override
  void initState() {
    super.initState();
    Hive.registerAdapter(TaskAdapter());
    Hive.openBox<Task>('tasks').then((box) {
      taskBox = box;
    });
  }

  void addTask(String title) {
    if (title.trim().isNotEmpty) {
      final newTask = Task(title: title);
      taskBox.add(newTask);
      setState(() {});
    }
  }

  void toggleTaskCompletion(int index) {
    final task = taskBox.getAt(index);
    if (task != null) {
      task.isCompleted = !task.isCompleted;
      taskBox.putAt(index, task);
      setState(() {});
    }
  }

  void deleteTask(int index) {
    taskBox.deleteAt(index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notas V3'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
            },
          ),
        ],
      ),
      body: ValueListenableBuilder<Box<Task>>(
        valueListenable: Hive.box<Task>('tasks').listenable(),
        builder: (context, box, _) {
          final tasks = box.values.toList().reversed.toList();
          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];
              return Dismissible(
                key: Key(task.title),
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  deleteTask(index);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tarefa removida'),
                      action: SnackBarAction(
                        label: 'Desfazer',
                        onPressed: null,
                      ),
                    ),
                  );
                },
                child: CheckboxListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  value: task.isCompleted,
                  onChanged: (value) {
                    toggleTaskCompletion(index);
                  },
                  secondary: const Icon(Icons.check_box_outline_blank),
                  activeCheckBoxColor: Colors.green,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              final titleController = TextEditingController();
              return AlertDialog(
                title: const Text('Adicionar Tarefa'),
                content: TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Título da tarefa',
                    border: OutlineInputBorder(),
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      addTask(titleController.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Adicionar'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}