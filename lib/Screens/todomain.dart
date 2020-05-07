import 'package:TodosApp/Screens/todospage.dart';
import 'package:flutter/material.dart';

import 'loginpage.dart';

class TodoMain extends StatelessWidget {
  // This widget is the root of your application
  UserDetails detailsUser;
  TodoMain({this.detailsUser});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(),
      darkTheme: ThemeData.dark(),
      home: MyHomePage(title: 'Todos'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({this.title});

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  UserDetails detailsUsers;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: TodosPage(),
    );
  }
}
