import 'package:TodosApp/Model/todo.dart';
import 'package:TodosApp/Screens/todomain.dart';
import 'package:TodosApp/Util/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

DbHelper helper = DbHelper();

/*final List<String> choices = const <String>[
  'Save Todo & Back',
  'Delete Todo',
  'Back to List'
];

const mnuSave = 'Save Todo & Back';
const mnuDelete = 'Delete Todo';
const mnuBack = 'Back to List';*/

class TodoDetail extends StatefulWidget {
  final Todo todo;
  TodoDetail(this.todo);

  @override
  State<StatefulWidget> createState() => TotoDetailState(todo);
}

class TotoDetailState extends State {
  Todo todo;
  TotoDetailState(this.todo);
  final _priorities = ["High", "Medium", "Low"];
  String _priority = "Low";
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController.text = todo.title;
    descriptionController.text = todo.description;
    return WillPopScope(
        // If user go back the todo wont update
        onWillPop: () {
          // If user try to go back app wont do nothing to avoid errors
        },
        child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: todo.title.isEmpty ? Text('Create Todo') : Text(todo.title),
            /*actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: select,
                itemBuilder: (BuildContext context) {
                  return choices.map((String choice) {
                    return PopupMenuItem<String>(
                      value: choice,
                      child: Text(choice),
                    );
                  }).toList();
                },
              )
            ],*/
          ),
          body: formTodo(), // Returns todo's form
        ));
  }

  /*void select(String value) async {
    int result;
    switch (value) {
      case mnuSave:
        save();
        break;
      case mnuBack:
        Navigator.pop(context, true);
        break;
      case mnuDelete:
        Navigator.pop(context, true);
        if (todo.id == null) {
          return;
        }
        result = await helper.deleteTodo(todo.id);
        if (result != 0) {
          AlertDialog alertDialog = AlertDialog(
            title: Text("Delete Todo"),
            content: Text("The Todo has been deleted"),
          );
          showDialog(context: context, builder: (_) => alertDialog);
        }
        break;
    }
  }*/

  void save() {
    TextStyle textStyle = Theme.of(context).textTheme.title;
    if (todo.title.isNotEmpty && todo.description.isNotEmpty) {
      todo.date = new DateFormat.yMd().format(DateTime.now());
      helper.insertTodo(todo);
    } else {
      AlertDialog alertDialog = AlertDialog(
        title: Text(
          "Look at the text boxes",
          style: textStyle,
        ),
        content: Text(
          "Maybe one or both are empty",
          style: DefaultTextStyle.of(context).style.apply(fontSizeFactor: 1.25),
        ),
        backgroundColor: Colors.grey[700],
      );
      showDialog(context: context, builder: (_) => alertDialog);
    }
  }

  void updatePriority(String value) {
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
    return _priorities[value - 1];
  }

  void updateTitle() {
    todo.title = titleController.text;
  }

  void updateDescription() {
    todo.description = descriptionController.text;
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
            onChanged: (value) => this.updateTitle(),
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
                onChanged: (value) => this.updateDescription(),
                decoration: InputDecoration(
                    labelText: "Description",
                    labelStyle: textStyle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
              )),
          Container(
              width: 125,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                    color: Colors.grey, style: BorderStyle.solid, width: 1.0),
              ),
              child: ListTile(
                  title: DropdownButton<String>(
                style: TextStyle(
                    //color: Colors.black,
                    fontSize: 18),
                underline: Container(
                  height: 2,
                  color: Colors.black,
                ),
                onChanged: (value) => updatePriority(value),
                items:
                    _priorities.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                value: retrievePriority(todo.priority),
                icon: Icon(Icons.arrow_drop_down),
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
                    onPressed: () => save(),
                    child: Text("Save Todo"),
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: RaisedButton(
                    onPressed: () => cancelTodo(),
                    child: Text("Cancel Todo"),
                    color: Colors.red,
                  ))
            ],
          ))
        ],
      ),
    );
  }

  void cancelTodo() {
    todo.title = "";
    todo.description = "";
    titleController.text = "";
    descriptionController.text = "";
  }
}
