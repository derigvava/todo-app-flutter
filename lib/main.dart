import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TodoListScreen(),
    );
  }
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  List<Map<String, dynamic>> tasks = [
  {'text': 'Изучить Flutter', 'completed': false},
  {'text': 'Написать To-Do приложение', 'completed': false},
  {'text': 'Выучить StatefulWidget', 'completed': true},
];

  @override
  void initState() {
    super.initState();
    _loadTasks(); // Загружаем задачи при запуске
  }

  // Загрузка задач из памяти
  Future<void> _loadTasks() async {
  final prefs = await SharedPreferences.getInstance();
  final saved = prefs.getStringList('tasks');
  
  if (saved != null) {
    // Конвертируем сохранённые строки в Map
    setState(() {
      tasks = saved.map((item) {
        final parts = item.split('|');
        return {
          'text': parts[0],
          'completed': parts[1] == 'true',
        };
      }).toList();
    });
  }
}

Future<void> _saveTasks() async {
  final prefs = await SharedPreferences.getInstance();
  // Конвертируем Map в строки для сохранения
  final toSave = tasks.map((task) {
    return '${task['text']}|${task['completed']}';
  }).toList();
  await prefs.setStringList('tasks', toSave);
}

void _addTask() async {
  print('[_addTask] called'); // Увидишь в консоли при нажатии кнопки

  final TextEditingController controller = TextEditingController();
  
  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Добавить задачу'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Введите текст задачи'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                Navigator.pop(context, controller.text.trim());
              }
            },
            child: const Text('Добавить'),
          ),
        ],
      );
    },
  );


  // Если пользователь ввёл текст
  if (result != null && result.isNotEmpty) {
    print('[_addTask] adding task: $result');
    setState(() {
      tasks.add({
        'text': result,
        'completed': false,
      });
    });
    _saveTasks(); // Сохраняем
  }
}

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
      _saveTasks(); // Сохраняем после удаления
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои задачи'),
      ),
      body: Container(
        color: Colors.blue[50],
        child: ListView.builder(
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(8.0),
              child: ListTile(
                leading: Checkbox(
  value: tasks[index]['completed'],
  onChanged: (newValue) {
    if (newValue != null) { // ← Добавляем проверку!
      setState(() {
        tasks[index]['completed'] = newValue;
        _saveTasks();
      });
    }
  },
),
                title: Text(
  tasks[index]['text'], // Обращаемся к полю 'text'
  style: TextStyle(
    decoration: tasks[index]['completed'] 
      ? TextDecoration.lineThrough 
      : TextDecoration.none,
  ),
),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTask(index),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
    );
  }
}