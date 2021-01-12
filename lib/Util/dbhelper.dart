import 'package:TodosApp/Model/todo.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class DbHelper {
  static final DbHelper _dbTodosHelper = DbHelper._internal();
  String tblTodo = "todo";
  String colId = "id";
  String colTitle = "title";
  String colDescription = "description";
  String colPriority = "priority";
  String colDate = "date";
  String colTypeTodo = "typeTodo";

  String tblCategories = "categories";
  String colCategory = "category";
  String colRepetitions = "repetitions";

  DbHelper._internal();

  factory DbHelper() {
    return _dbTodosHelper;
  }

  static Database _dbTodos;

  Future<Database> get db async {
    if (_dbTodos == null) _dbTodos = await initializeDb();
    return _dbTodos;
  }

  Future<Database> initializeDb() async {
    String path =
        "/data/user/0/com.example.todo_app/app_flutter/database/app_fluttertodos.db";
    print(path);
    var dbTodos = await openDatabase(path, version: 1, onCreate: _createDb);
    return dbTodos;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(
        "CREATE TABLE $tblTodo($colId INTEGER PRIMARY KEY, $colTitle TEXT, " +
            "$colDescription TEXT, $colPriority INTEGER, $colDate TEXT, $colTypeTodo TEXT);" +
            "CREATE TABLE $tblCategories($colCategory VARCHAR(50) PRIMARY KEY," +
            "$colRepetitions INTEGER NOT NULL);");
  }

  Future<int> insertTodo(Todo todo) async {
    Database db = await this.db;
    var result = await db.insert(tblTodo, todo.toMap());
    return result;
  }

  Future<List> getTodos() async {
    Database db = await this.db;
    var result =
        await db.rawQuery("SELECT * FROM $tblTodo ORDER BY $colPriority");
    return result;
  }

  Future<List> getCategories() async {
    Database db = await this.db;
    var result = await db.rawQuery("SELECT * FROM $tblCategories");
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.db;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $tblTodo"));
    return result;
  }

  Future<int> getCategoriesCount() async {
    Database db = await this.db;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $tblCategories"));
    return result;
  }

  // FALTA ACTUALIZAR LOS CAMPOS DE CATEGORIAS

  Future<int> updateTodo(Todo todo) async {
    var db = await this.db;
    var result = await db.rawUpdate("UPDATE $tblTodo SET $colTitle = '" +
        todo.title +
        "', " +
        "$colDescription = '" +
        todo.description +
        "', $colPriority = '" +
        todo.priority.toString() +
        "', $colDate = '" +
        todo.date +
        "' "
            "WHERE $colId = '" +
        todo.id.toString() +
        "'");
    return result;
  }

  Future<int> deleteTodo(int id) async {
    int result;
    var db = await this.db;
    result = await db.rawDelete("DELETE FROM $tblTodo WHERE $colId = $id");
    return result;
  }

  Future<int> deleteTodos() async {
    int result;
    var db = await this.db;
    result = await db.rawDelete("DELETE FROM $tblTodo");
    return result;
  }
}
