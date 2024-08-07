import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:to_do_list_app1/add_page.dart';

class TodoListPage extends StatefulWidget {
  const TodoListPage({Key? key}) : super(key: key);

  @override
  State<TodoListPage> createState() => TodoListPageState();
}

class TodoListPageState extends State<TodoListPage> {
  bool isLoading = true;
  List items = [];

  @override
  void initState() {
    super.initState();
    fetchToDo();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("To Do List"),
        foregroundColor: Colors.white,
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: fetchToDo,
        child: ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            final id = item['_id'];

            return Dismissible(
              key: Key(id),
              background: Container(
                color: Colors.red,
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.delete, color: Colors.white),
              ),
              secondaryBackground: Container(
                color: Colors.green,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Icon(Icons.check, color: Colors.white),
              ),
              confirmDismiss: (direction) {
                if (direction == DismissDirection.startToEnd) {
                  return showDeleteConfirmationDialog(context, id);
                } else if (direction == DismissDirection.endToStart) {
                  markTaskAsCompleted(item);
                  return Future.value(false);
                }
                return Future.value(false);
              },
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 4, horizontal: 16),
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blueAccent, Colors.blueAccent],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text('${index + 1}'),
                  ),
                  title: Text(
                    item['title'] ?? '',
                    style: TextStyle(
                      decoration: item['is_completed']
                          ? TextDecoration.lineThrough
                          : null,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['description'] ?? '',
                        style: TextStyle(color: Colors.white70),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Category: ${item['category'] ?? 'None'}',
                        style: TextStyle(
                          color: Colors.white54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton(
                    onSelected: (value) {
                      if (value == 'Edit') {
                        navigateToEditPage(item);
                      } else if (value == 'Delete') {
                        deleteById(id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: Text('Edit'),
                        value: 'Edit',
                      ),
                      PopupMenuItem(
                        child: Text('Delete'),
                        value: 'Delete',
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black, Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: FloatingActionButton.extended(
          onPressed: navigateToAddPage,
          label: Row(
            children: [
              const Icon(Icons.add, color: Colors.white, size: 24),
              const SizedBox(width: 8),
            ],
          ),
          backgroundColor: Colors.transparent,
          splashColor: Colors.deepPurpleAccent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  Future<bool> showDeleteConfirmationDialog(BuildContext context, String id) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Confirmation'),
          content: Text('Are you sure you want to delete this task?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteById(id);
                Navigator.of(context).pop(true);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    ).then((value) => value ?? false);
  }

  void navigateToEditPage(Map item) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddToDoPage(todo: item)),
    ).then((_) => fetchToDo()); // Refresh list after editing
  }

  void navigateToAddPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddToDoPage()),
    ).then((_) => fetchToDo()); // Refresh list after adding a new item
  }

  Future<void> deleteById(String id) async {
    final url = 'https://api.nstack.in/v1/todos/$id';
    try {
      final response = await http.delete(Uri.parse(url));
      if (response.statusCode == 200) {
        final filteredItems = items.where((element) => element['_id'] != id).toList();
        setState(() {
          items = filteredItems;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Item deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete item')),
        );
      }
    } catch (error) {
      print('Error deleting item: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting item')),
      );
    }
  }

  Future<void> markTaskAsCompleted(Map item) async {
    final id = item['_id'];
    final url = 'https://api.nstack.in/v1/todos/$id';
    final body = jsonEncode({'is_completed': true});

    try {
      final response = await http.put(
        Uri.parse(url),
        body: body,
        headers: {'Content-Type': 'application/json'},
      );
      if (response.statusCode == 200) {
        fetchToDo(); // Refresh the list to show updated task
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Task marked as completed')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to mark task as completed')),
        );
      }
    } catch (error) {
      print('Error marking task as completed: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error marking task as completed')),
      );
    }
  }

  Future<void> fetchToDo() async {
    setState(() {
      isLoading = true;
    });

    final url = 'https://api.nstack.in/v1/todos?page=1&limit=10';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        // Debugging: Print the response to verify category field
        print('Fetched data: ${jsonData}');
        setState(() {
          items = jsonData['items'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to fetch data')),
        );
      }
    } catch (error) {
      print('Error fetching data: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching data')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
}
