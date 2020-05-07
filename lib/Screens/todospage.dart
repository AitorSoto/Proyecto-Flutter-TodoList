import 'dart:async';

import 'package:TodosApp/Model/todo.dart';
import 'package:TodosApp/Util/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

class TodosPage extends StatefulWidget {
  @override
  _TodosPageState createState() => _TodosPageState();
}

class Debouncer {
  final int milliseconds;
  VoidCallback action;
  Timer _timer;

  Debouncer({this.milliseconds});

  run(VoidCallback action) {
    if (null != _timer) {
      _timer.cancel();
    }
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}

class _TodosPageState extends State<TodosPage> {
  final _debouncer = Debouncer(milliseconds: 500);
  List<Todo> todos = List();
  List<Todo> filteredtodos = List();
  DbHelper helper = DbHelper();
  Todo todo;
  int count = 0;
  final _priorities = ["High", "Medium", "Low"];
  String _priority = "Low";
  bool searchingTodos = false;
  var focusNode = new FocusNode();
  final choices = ["My Profile", "Sync with Google Cloud", "Log out"];

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return searchWindow();
  }

  @override
  void initState() {
    super.initState();
    {
      setState(() {
        todos = getData();
        filteredtodos = todos;
      });
    }
  }

  List<Todo> getData() {
    final dbFuture = helper.initializeDb();
    List<Todo> todoList = List<Todo>();
    dbFuture.then((result) {
      final todosFuture = helper.getTodos();
      todosFuture.then((result) {
        int count = result.length;
        for (int i = 0; i < count; i++) {
          todoList.add(Todo.fromObject(result[i]));
        }
        setState(() {
          todos = todoList;
          count = count;
        });
      });
    });
    return todoList;
  }

  Color getColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.red;
        break;
      case 2:
        return Colors.orange;
        break;
      case 3:
        return Colors.green;
        break;
      default:
        return Colors.greenAccent;
        break;
    }
  }

  void updatePriority(String value) {
    print(todo.priority);
    switch (value) {
      case "High":
        todo.priority = 1;
        break;
      case "Medium":
        todo.priority = 2;
        break;
      case "Low":
        todo.priority = 3;
        break;
    }
    setState(() {
      _priority = value;
    });
  }

  String retrievePriority(int value) {
    print(value.toString());
    return _priorities[value - 1];
  }

  void setStateLists() {
    setState(() {
      todos = getData();
      filteredtodos = todos;
    });
  }

  Scaffold searchWindow() {
    TextStyle textStyleTitle = Theme.of(context).textTheme.title;

    return Scaffold(
      appBar: AppBar(title: Text("Search a todo"), actions: <Widget>[
        PopupMenuButton<String>(
          onSelected: null,
          itemBuilder: (BuildContext context) {
            return choices.map((String choice) {
              return PopupMenuItem<String>(
                value: choice,
                child: Text(choice),
              );
            }).toList();
          },
        )
      ]),
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                  focusNode: focusNode,
                  onEditingComplete: () =>
                      FocusScope.of(context).requestFocus(focusNode),
                  decoration: InputDecoration(
                      labelText: "Search a todo by title or date",
                      labelStyle: textStyleTitle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                  onChanged: (string) {
                    _debouncer.run(() {
                      setState(() {
                        filteredtodos = todos
                            .where((u) => (u.title
                                    .toLowerCase()
                                    .contains(string.toLowerCase()) ||
                                u.date
                                    .toLowerCase()
                                    .contains(string.toLowerCase())))
                            .toList();
                      });
                    });
                  },
                  onTap: () => setStateLists)),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: filteredtodos.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                    elevation: 2.0,
                    child: GestureDetector(
                      onTap: () {
                        todo = this.filteredtodos[index];
                        titleController.text = todo.title;
                        descriptionController.text = todo.description;
                        showDialog();
                      },
                      child: ListTile(
                        leading: CircleAvatar(
                            backgroundColor:
                                getColor(this.filteredtodos[index].priority)),
                        title: Text(this.filteredtodos[index].title),
                        subtitle: Text(this.filteredtodos[index].date),
                      ),
                    ));
              },
            ),
          ),
        ],
      ),
    );
  }

  void showDialog() {
    final _formKey = GlobalKey<FormState>();
    TextStyle textStyle = Theme.of(context).textTheme.title;
    slideDialog.showSlideDialog(
      context: context,
      backgroundColor: Color(0xFF39A9DB),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                style: textStyle,
                controller: titleController,
                decoration: InputDecoration(
                    labelText: "Title",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: TextField(
                controller: descriptionController,
                style: textStyle,
                decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              ),
            ),
            Container(
                width: 125,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5.0),
                  border: Border.all(
                      color: Colors.black,
                      style: BorderStyle.solid,
                      width: 1.0),
                ),
                child: ListTile(
                    title: DropdownButton<String>(
                  style: TextStyle(color: Colors.black, fontSize: 16.0),
                  onChanged: (value) => updatePriority(value),
                  items:
                      _priorities.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  value: retrievePriority(todo.priority),
                  icon: Icon(
                    Icons.arrow_drop_down,
                    size: 25.0,
                    color: Colors.white,
                  ),
                  iconSize: 24,
                  elevation: 16,
                ))),
            Center(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Padding(
                    padding: EdgeInsets.only(top: 30.0, right: 10.0),
                    child: RaisedButton(
                      onPressed: () async {
                        int result;
                        if (todo.id != null) {
                          todo.title = titleController.text;
                          todo.description = descriptionController.text;
                          result = await helper.updateTodo(todo);
                          setState(() {
                            todos = getData();
                            filteredtodos = todos;
                          });
                          Navigator.of(context, rootNavigator: true)
                              .pop('dialog');
                        }
                      },
                      child: Text("Update Todo"),
                      color: Colors.blue,
                    )),
                Padding(
                    padding: EdgeInsets.only(top: 30.0),
                    child: RaisedButton(
                      onPressed: () async {
                        int result;
                        if (todo.id == null) {
                          return;
                        }
                        result = await helper.deleteTodo(todo.id);
                        setState(() {
                          todos = getData();
                          filteredtodos = todos;
                        });
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      },
                      child: Text("Delete Todo"),
                      color: Colors.red,
                    ))
              ],
            ))
          ],
        ),
      ),
    );
  }
}
