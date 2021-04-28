import 'dart:async';

import 'package:TodosApp/Model/todo.dart';
import 'package:TodosApp/Util/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:slide_popup_dialog/slide_popup_dialog.dart' as slideDialog;
import 'package:intl/intl.dart';

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
  String _typeOfTask = "";
  final _priorities = ["High", "Medium", "Low"];
  final _tasks = [
    "Leisure",
    "Sports",
    "Hang Out",
    "Study",
    "Vacations",
    "Work",
    "Others"
  ];
  String _priority = "Low";
  bool searchingTodos = false;
  var focusNode = new FocusNode();
  DateTime dateReference = DateTime.now();

  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController timeController = TextEditingController();

  GlobalKey<RefreshIndicatorState> refreshKey;

  @override
  Widget build(BuildContext context) {
    return searchWindow();
  }

  @override
  void initState() {
    super.initState();
    refreshKey = GlobalKey<RefreshIndicatorState>();
    {
      setState(() {
        todos = getData();
        filteredtodos = todos;
      });
    }
  }

  Future<void> refreshList() async {
    todos = getData();
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

  String getDateStringFormatted(DateTime date) {
    // Instead of return for example 2020-12-05T02:02:00.000 this method will return Saturday, 5 of December at 02:02 of 2020
    String onlyDate = "";
    String onlyTime = "";
    String dateString = date.toString();
    dateString.split(' ');
    onlyDate = dateString[0];
    onlyTime = dateString[1];
    onlyTime.split(':');
    String result = new DateFormat.MMMMEEEEd().format(date).toString() +
        " of " +
        date.year.toString() +
        " at " +
        date.toUtc().toIso8601String().split('T')[1].substring(0,
            5); // With that 2020-12-05T02:02:00.000 turns to 02:02, here I just want to get the hour
    return result;
  }

  _showDateTimePicker() async {
    DateTime finalDateTime;
    DateTime datePicked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        initialDatePickerMode: DatePickerMode.day,
        firstDate: DateTime(DateTime.now().year),
        lastDate: DateTime(DateTime.now().year + 5));
    if (datePicked != null) {
      final TimeOfDay timePicked = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay(hour: DateTime.now().hour, minute: DateTime.now().minute),
      );
      if (timePicked != null) {
        finalDateTime = new DateTime(
            datePicked.year,
            datePicked.month,
            datePicked.day,
            timePicked.hour + 1,
            timePicked.minute); // For some reason I get 1h less than selected
        timeController.text = getDateStringFormatted(finalDateTime);
        todo.date = timeController.text;
      }
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

  void updateTypeOfTask(String value) {
    setState(() {
      _typeOfTask = value;
      todo.typeTodo = value;
    });
  }

  String retrieveTypeOfTask(String value) {
    return _tasks[findFirstMatchedIndex(value)];
  }

  int findFirstMatchedIndex(String value) {
    int index = 0;
    for (int i = 0; i <= _tasks.length; i++) {
      if (_tasks[i] == value) {
        index = i;
        break;
      }
    }
    return index;
  }

  Scaffold searchWindow() {
    TextStyle textStyleTitle = Theme.of(context).textTheme.title;

    return Scaffold(
        appBar: AppBar(title: Text("Search a todo")),
        body: RefreshIndicator(
          key: refreshKey,
          onRefresh: () async {
            await refreshList();
          },
          child: Column(
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
                            timeController.text = todo.date;
                            showDialog();
                          },
                          child: ListTile(
                            leading: CircleAvatar(
                                backgroundColor: getColor(
                                    this.filteredtodos[index].priority)),
                            title: Text(this.filteredtodos[index].title),
                            subtitle: Text(this.filteredtodos[index].date),
                          ),
                        ));
                  },
                ),
              ),
            ],
          ),
        ));
  }

  void showDialog() {
    final _formKey = GlobalKey<FormState>();
    TextStyle textStyle = Theme.of(context).textTheme.title;
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return Container(
              height: MediaQuery.of(context).size.height,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: 8, top: 20, right: 8, bottom: 8),
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
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                          controller: timeController,
                          style: textStyle,
                          decoration: InputDecoration(
                              labelText: "Date",
                              labelStyle: textStyle,
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                          onTap: () => _showDateTimePicker()),
                    ),
                    Padding(
                        padding: EdgeInsets.only(top: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                                padding: EdgeInsets.only(right: 10),
                                child: Container(
                                    width: 125,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                          width: 1.0, color: textStyle.color),
                                    ),
                                    child: ListTile(
                                        title: DropdownButton<String>(
                                      style: textStyle,
                                      onChanged: (value) =>
                                          updatePriority(value),
                                      items: _priorities
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      value: retrievePriority(todo.priority),
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        size: 25.0,
                                        color: textStyle.color,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                    )))),
                            Padding(
                                padding:
                                    EdgeInsets.only(top: 10.0, bottom: 10.0),
                                child: Container(
                                    // TASK
                                    width: 125,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(
                                          color: Colors.grey,
                                          style: BorderStyle.solid,
                                          width: 1.0),
                                    ),
                                    child: ListTile(
                                        title: DropdownButton<String>(
                                      style: textStyle,
                                      onChanged: (value) =>
                                          updateTypeOfTask(value),
                                      items: _tasks
                                          .map<DropdownMenuItem<String>>(
                                              (String value) {
                                        return DropdownMenuItem<String>(
                                          value: value,
                                          child: Text(value),
                                        );
                                      }).toList(),
                                      value: retrieveTypeOfTask(todo.typeTodo),
                                      icon: Icon(
                                        Icons.arrow_drop_down,
                                        size: 25.0,
                                        color: Colors.white,
                                      ),
                                      iconSize: 24,
                                      elevation: 16,
                                    ))))
                          ],
                        )),
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
                                  todo.date = timeController.text;
                                  result = await helper.updateTodo(todo);
                                  setState(() {
                                    todos = getData();
                                    filteredtodos = todos;
                                  });
                                  Navigator.of(context).pop(context);
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
                                Navigator.of(context).pop(context);
                              },
                              child: Text("Delete Todo"),
                              color: Colors.red,
                            ))
                      ],
                    ))
                  ],
                ),
              ));
        });
  }
}
