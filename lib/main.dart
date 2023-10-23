import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskListScreen(),
    );
  }
}

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final String apiUrl = 'https://jsonplaceholder.typicode.com/todos';
  List<dynamic> tasks = [];

  @override
  void initState() {
    super.initState();
    fetchTasks(); // Initialize tasks when the widget is created.
  }

  Future<void> fetchTasks() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      setState(() {
        tasks = jsonDecode(response.body); // Update the tasks list.
      });
    } else {
      throw Exception('Failed to load tasks');
    }
  }

  Future<void> createTask() async {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'title': 'New Task',
        'completed': false,
      }),
    );

    if (response.statusCode == 201) {
      fetchTasks(); // Refresh the task list after creating a task.
    } else {
      throw Exception('Failed to create task');
    }
  }

  Future<void> updateTask(int id) async {
    final response = await http.put(
      Uri.parse('$apiUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'completed': true,
      }),
    );

    if (response.statusCode == 200) {
      fetchTasks(); // Refresh the task list after updating a task.
    } else {
      throw Exception('Failed to update task');
    }
  }

  Future<void> deleteTask(int id) async {
    final response = await http.delete(
      Uri.parse('$apiUrl/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      fetchTasks(); // Refresh the task list after deleting a task.
    } else {
      throw Exception('Failed to delete task');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('API Integration Demo'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return ListTile(
            title: Text(task['title']),
            leading: Checkbox(
              value: task['completed'],
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  setState(() {
                    task['completed'] = newValue;
                  });
                  updateTask(task['id']); // Update the task's completion status.
                }
              },
            ),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                deleteTask(task['id']); // Delete the task.
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          createTask(); // Create a new task.
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
