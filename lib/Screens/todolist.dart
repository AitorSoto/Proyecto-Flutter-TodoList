import 'package:TodosApp/Model/todo.dart';
import 'package:TodosApp/Util/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;

class TodoList extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodoListState();
}

class TodoListState extends State {
  DbHelper helper = DbHelper();
  List<Todo> todos;
  Todo todo;
  int count = 0;
  final _priorities = ["High", "Medium", "Low"];
  String _priority = "Low";

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    if (todos == null) {
      todos = List<Todo>();
      getData();
    }
    return Scaffold(
      body: todoListItems(),
    );
  }

  ListView todoListItems() {
    return ListView.builder(
      itemCount: count,
      itemBuilder: (BuildContext context, int position) {
        return Card(
            elevation: 2.0,
            child: GestureDetector(
              onTap: () {
                todo = this.todos[position];
                titleController.text = todo.title;
                descriptionController.text = todo.description;
                showDialog();
              },
              child: ListTile(
                leading: CircleAvatar(
                    backgroundColor: getColor(this.todos[position].priority)),
                title: Text(this.todos[position].title),
                subtitle: Text(this.todos[position].date),
              ),
            ));
      },
    );
  }

  void getData() {
    final dbFuture = helper.initializeDb();
    dbFuture.then((result) {
      final todosFuture = helper.getTodos();
      todosFuture.then((result) {
        List<Todo> todoList = List<Todo>();
        count = result.length;
        for (int i = 0; i < count; i++) {
          todoList.add(Todo.fromObject(result[i]));
        }
        setState(() {
          todos = todoList;
          count = count;
        });
      });
    });
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

  Padding formTodo() {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    return Padding(
      padding: EdgeInsets.only(top: 35.0, left: 10, right: 10),
      child: Column(
        children: <Widget>[
          TextField(
            controller: titleController,
            style: textStyle,
            decoration: InputDecoration(
                labelText: "Title",
                labelStyle: textStyle,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5.0))),
          ),
          Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: descriptionController,
                style: textStyle,
                decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              )),
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
                          getData();
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
                        getData();
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
