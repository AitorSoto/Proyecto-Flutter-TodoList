import 'dart:async';

import 'package:TodosApp/Model/todo.dart';
import 'package:TodosApp/Util/dbhelper.dart';
import 'package:flutter/material.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
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

class _SearchPageState extends State<SearchPage> {
  final _debouncer = Debouncer(milliseconds: 500);
  List<Todo> users = List();
  List<Todo> filteredUsers = List();
  DbHelper helper = DbHelper();

  @override
  void initState() {
    super.initState();
    {
      setState(() {
        users = getData();
        filteredUsers = users;
      });
    }
    ;
  }

  @override
  Widget build(BuildContext context) {
    return searchWindow();
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
          users = todoList;
          count = count;
        });
      });
    });
    return todoList;
  }

  Scaffold searchWindow() {
    TextStyle textStyleTitle = Theme.of(context).textTheme.title;
    TextStyle textStyleDescription = Theme.of(context).textTheme.caption;

    return Scaffold(
      appBar: AppBar(
        title: Text("Search a todo"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
              padding: EdgeInsets.all(10.0),
              child: TextField(
                decoration: InputDecoration(
                    labelText: "Search a todo by title or date",
                    labelStyle: textStyleTitle,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(5.0))),
                onChanged: (string) {
                  _debouncer.run(() {
                    setState(() {
                      filteredUsers = users
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
              )),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(10.0),
              itemCount: filteredUsers.length,
              itemBuilder: (BuildContext context, int index) {
                return Card(
                  child: Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(filteredUsers[index].title, style: textStyleTitle),
                        SizedBox(
                          height: 5.0,
                        ),
                        Text(
                          filteredUsers[index].date.toLowerCase(),
                          style: textStyleDescription,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
