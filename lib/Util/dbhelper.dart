import 'package:TodosApp/Model/reminders.dart';
import 'package:TodosApp/Model/todo.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:async';
import 'package:dcdg/dcdg.dart';

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

  String tblReminders = "reminders";
  String colHour = "reminderHour";
  String colNameNotification = "reminderName";

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
    String todosCreationQuery =
        "CREATE TABLE $tblTodo($colId INTEGER PRIMARY KEY, $colTitle TEXT, " +
            "$colDescription TEXT, $colPriority INTEGER, $colDate TEXT, $colTypeTodo TEXT);" +
            "CREATE TABLE $tblCategories($colCategory VARCHAR(50) PRIMARY KEY," +
            "$colRepetitions INTEGER NOT NULL);";
    String categoriesCreationQuery =
        "CREATE TABLE $tblCategories($colCategory VARCHAR(50) PRIMARY KEY NOT NULL," +
            "$colRepetitions INTEGER NOT NULL);";
    String remindersQuery =
        "CREATE TABLE $tblReminders(id INTEGER NOT NULL PRIMARY KEY, $colNameNotification VARCHAR(50) NOT NULL," +
            "$colHour VARCHAR(5) NOT NULL);";
    var queries = [todosCreationQuery, categoriesCreationQuery, remindersQuery];
    for (String query in queries) {
      db.execute(query);
    }
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

  Future<int> getLastIdFromTodos() async {
    var db = await this.db;
    int result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT MAX(ID) FROM $tblTodo"));
    return result == null ? 0 : result;
  }

  Future<List> getCategories() async {
    Database db = await this.db;
    var result = await db.rawQuery("SELECT * FROM $tblCategories");
    return result;
  }

  Future<List> getReminders() async {
    Database db = await this.db;
    var result = await db.rawQuery("SELECT * FROM $tblReminders");
    return result;
  }

  Future<int> getCount() async {
    Database db = await this.db;
    var result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT COUNT(*) FROM $tblTodo"));
    return result;
  }

  Future<int> updateTodo(Todo todo) async {
    var db = await this.db;
    var queryCategory = await db.rawQuery(
        "SELECT $colTypeTodo FROM $tblTodo WHERE id = '" +
            todo.id.toString() +
            "'");
    String actualCategory = queryCategory.first.toString();

    if (actualCategory != todo.typeTodo) {
      // If the todo category changes to another one the category DB also changes adding and substracting a repetition
      await addRepetition(todo.typeTodo);
      await subtractRepetition(actualCategory);
    }

    var result = await db.rawUpdate("UPDATE $tblTodo SET $colTitle = '" +
        todo.title +
        "', " +
        "$colDescription = '" +
        todo.description +
        "', $colPriority = '" +
        todo.priority.toString() +
        "', $colDate = '" +
        todo.date +
        "', $colTypeTodo = '" +
        todo.typeTodo +
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

  Future<int> deleteCategories() async {
    int result;
    var db = await this.db;
    result = await db.rawDelete("DELETE FROM $tblCategories");
    return result;
  }

  Future<int> deleteTodos() async {
    int result;
    var db = await this.db;
    result = await db.rawDelete("DELETE FROM $tblTodo");
    return result;
  }

  Future<int> addRepetition(String category) async {
    var db = await this.db;
    int result;
    int countCategory = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM $tblCategories WHERE category = '$category'"));
    if (countCategory == 0 || countCategory == null)
      result = await db
          .rawInsert("INSERT INTO $tblCategories VALUES ('$category', 1)");
    else
      result = await db.rawUpdate(
          "UPDATE $tblCategories SET repetitions = repetitions +1 WHERE category = '" +
              category +
              "'");
    return result;
  }

  Future<int> subtractRepetition(String category) async {
    var db = await this.db;
    int result;
    int countCategory = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM $tblCategories WHERE category = '$category'"));
    if (countCategory == 1) //Last item on DB
      await db.rawDelete(
          "DELETE FROM $tblCategories WHERE categoria = '$category'");
    else
      result = await db.rawUpdate(
          "UPDATE $tblCategories SET repetitions = repetitions -1 WHERE category = '" +
              category +
              "'");

    return result;
  }

  Future<int> insertReminder(Reminders reminder) async {
    Database db = await this.db;
    var result = await db.insert(tblReminders, reminder.toMap());
    return result;
  }

  Future<int> getLastReminderId() async {
    var db = await this.db;
    int result = Sqflite.firstIntValue(
        await db.rawQuery("SELECT MAX(ID) FROM $tblReminders"));
    return result == null ? 0 : result + 1;
  }

  Future<int> updateReminder(Reminders reminder) async {
    var db = await this.db;
    var result =
        await db.rawUpdate("UPDATE $tblReminders SET $colNameNotification = '" +
            reminder.reminderName +
            "', " +
            "$colHour = '" +
            reminder.reminderHour +
            "' "
                "WHERE id = " +
            reminder.id.toString());
    return result;
  }

  Future<int> deleteReminder(int id) async {
    int result;
    var db = await this.db;
    result = await db.rawDelete("DELETE FROM $tblReminders WHERE id = $id");
    return result;
  }
}
