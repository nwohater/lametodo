import 'package:flutter/material.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import '../database/sql_helper.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

class ToDoPage extends StatefulWidget {
  const ToDoPage({super.key});

  @override
  State<ToDoPage> createState() => _ToDoPageState();
}

class _ToDoPageState extends State<ToDoPage> {
  List<Map<String, dynamic>> _todos = [];

  void _refreshToDos() async {
    final data = await SQLHelper.getItems();
    setState(() {
      _todos = data;
    });
  }

  @override
  void initState() {
    super.initState();
    _refreshToDos();
    //print("...number of items: ${_todos.length}");
  }

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _addItem() async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    await SQLHelper.createItem(title, description);
    _refreshToDos();
    //print("...number of items: ${_todos.length}");
  }

  Future<void> _updateItem(int id) async {
    final title = _titleController.text;
    final description = _descriptionController.text;
    await SQLHelper.updateItem(id, title, description);
    _refreshToDos();
  }

  Future<void> _deleteItem(int id) async {
    await SQLHelper.deleteItem(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Item deleted'),
        duration: Duration(seconds: 1),
      ),
    );
    _refreshToDos();
  }

  Future<void> _deleteAll() async {
    await SQLHelper.deleteAll();
    _refreshToDos();
  }
  void _showForm(int? id) async {
    if (id != null) {
      final existingToDo = _todos.firstWhere((element) => element['id'] == id);
      _titleController.text = existingToDo['title'];
      _descriptionController.text = existingToDo['description'];
    }

    showModalBottomSheet(
      context: context,
      elevation: 5,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.only(top: 5, left: 15, right:15, bottom: MediaQuery.of(context).viewInsets.bottom + 120,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(
              height: 10
          ),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
          ),
          const SizedBox(
              height: 10
          ),
          ElevatedButton(
              onPressed: () async {
                if (id == null) {
                  await _addItem();
                }
                if (id != null) {
                  await _updateItem(id);
                }
                //clear the text fields
                _titleController.clear();
                _descriptionController.clear();
                //close the bottom sheet
                Navigator.of(context).pop();
              },
              child: Text(id == null ? 'Add' : 'Update'),
          ),
        ],
      ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.exit_to_app_rounded),
          onPressed: () => FlutterExitApp.exitApp(iosForceExit: true),
        ),
        title: const Center(child: Text('Lame To Do')),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever),
            onPressed: () async {
              AwesomeDialog(
                context: context,
                dialogType: DialogType.warning,
                animType: AnimType.topSlide,
                title: 'Delete All',
                desc: 'Are you sure you want to delete all items?',
                btnCancelOnPress: () {},
                btnOkOnPress: () async {
                  await _deleteAll();
                },
              ).show();

            },
          ),
        ],
    ),
    body: ListView.builder(
      itemCount: _todos.length,
      itemBuilder: (context, index) => Card(
        color: Colors.lightBlueAccent,
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal:15),
        child: ListTile(
          title: Text(_todos[index]['title']),
          subtitle: Text(_todos[index]['description']),
          trailing: SizedBox(
            width: 100,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showForm(_todos[index]['id']),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteItem(_todos[index]['id']),
                ),
              ],
            )
          ),
        )
      )
    ),
    floatingActionButton: FloatingActionButton(
      child: const Icon(Icons.add),
      onPressed: () => _showForm(null),
    ),
    );
  }
}

