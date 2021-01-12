import 'dart:typed_data';

import 'package:TodosApp/Model/todo.dart';
import 'package:TodosApp/Util/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:TodosApp/Util/notificationmanager.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

DbHelper helper = DbHelper();
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

NotificationManager manager = NotificationManager();

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
  String _typeOfTask = "";
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  DateTime dateReference =
      DateTime.now(); // Reference of the actual date and time
  DateTime finalDate;

  bool scheduleCheck = false; // Checkbox value

  final List<Key> keys = [
    Key("Network"),
    Key("NetworkDialog"),
    Key("Flare"),
    Key("FlareDialog"),
    Key("Asset"),
    Key("AssetDialog")
  ];

  @override
  Widget build(BuildContext context) {
    titleController.text = todo.title;
    descriptionController.text = todo.description;
    timeController.text = "";

    return Scaffold(
      appBar:
          AppBar(automaticallyImplyLeading: false, title: Text('Create Todo')),
      body: formTodo(), // Returns todo's form
    );
  }

  void save(bool showDialog, DateTime dateAndTime) {
    if (todo.title.isNotEmpty &&
        todo.description.isNotEmpty &&
        timeController.text.isNotEmpty) {
      todo.typeTodo = "Prueba";
      todo.date = timeController.text;
      helper.insertTodo(todo).then((_) => cancelTodo());
      if (scheduleCheck)
        _scheduleNotification(todo.title, todo.description, finalDate);
      else
        showDialogMethod("Success!", "The todo was added successfully",
            "https://i.pinimg.com/originals/e8/06/52/e80652af2c77e3a73858e16b2ffe5f9a.gif");
    } else {
      showDialogMethod(
          "Information not valid!!",
          'There is a problem with the text fields, one or both text fields are empty. Dont be the cat of above :D',
          "https://media1.tenor.com/images/36bebe7fb9f5cc3fd3391e55f5c4c7f1/tenor.gif");
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

  void updateTypeOfTask(String value) {
    todo.typeTodo = value;
    setState(() {
      _typeOfTask = value;
    });
  }

  String retrievePriority(int value) {
    return _priorities[value - 1];
  }

  String retrieveTypeOfTask(String value) {
    return _tasks[findFirstMatchedIndex(value) - 1];
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

  void updateTitle() {
    todo.title = titleController.text;
  }

  void updateDescription() {
    todo.description = descriptionController.text;
  }

  void updateDate() {
    todo.date = new DateFormat.MMMMEEEEd().format(finalDate).toString();
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
              padding: EdgeInsets.only(top: 15.0),
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
          Padding(
              padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
              child: TextField(
                controller: timeController,
                style: textStyle,
                onTap: () => _showDateTimePicker(),
                onChanged: (value) => this.updateDate(),
                decoration: InputDecoration(
                    labelText: "Set time",
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
                style: textStyle,
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
          /*Container(
              // TASK
              width: 125,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5.0),
                border: Border.all(
                    color: Colors.grey, style: BorderStyle.solid, width: 1.0),
              ),
              child: ListTile(
                  title: DropdownButton<String>(
                style: textStyle,
                onChanged: (value) => updateTypeOfTask(value),
                items: _tasks.map<DropdownMenuItem<String>>((String value) {
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
              ))),
          Padding(
              padding: EdgeInsets.only(top: 15.0),
              child: Center(
                  child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Checkbox(
                    value: scheduleCheck,
                    onChanged: (bool value) {
                      setState(() {
                        scheduleCheck = value;
                      });
                    },
                  ),
                  Text("Set a reminder")
                ],
              ))),*/
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(right: 10.0),
                  child: RaisedButton(
                    onPressed: () => save(true, finalDate),
                    child: Text("Save Todo"),
                  )),
              RaisedButton(
                onPressed: () => cancelTodo(),
                child: Text("Cancel Todo"),
                color: Colors.red,
              ),
            ],
          )),
        ],
      ),
    );
  }

  void showDialogMethod(String title, String description, String urlGif) {
    showDialog(
        context: context,
        builder: (_) => NetworkGiffyDialog(
              key: keys[1],
              image: Image.network(
                urlGif,
                fit: BoxFit.cover,
              ),
              entryAnimation: EntryAnimation.TOP_LEFT,
              title: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w600),
              ),
              description: Text(
                description,
                textAlign: TextAlign.center,
              ),
              onOkButtonPressed: () =>
                  Navigator.of(context, rootNavigator: true).pop('dialog'),
            ));
  }

  void cancelTodo() {
    finalDate = DateTime.now();
    todo.title = "";
    todo.description = "";
    todo.date = getDateStringFormatted(DateTime.now());
    titleController.text = "";
    descriptionController.text = "";
    timeController.text = "";
  }

  Future<void> _scheduleNotification(
      String title, String description, DateTime dateNotificaction) async {
    var vibrationPattern = Int64List(4);
    vibrationPattern[0] = 0;
    vibrationPattern[1] = 1000;
    vibrationPattern[2] = 5000;
    vibrationPattern[3] = 2000;

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '1', 'Todos channel', 'Alternative Todos channel',
        vibrationPattern: vibrationPattern,
        enableLights: true,
        color: const Color.fromARGB(255, 85, 129, 255),
        ledColor: const Color.fromARGB(255, 85, 129, 255),
        ledOnMs: 1000,
        ledOffMs: 500);
    var iOSPlatformChannelSpecifics =
        IOSNotificationDetails(sound: 'slow_spring_board.aiff');
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(
      0,
      title,
      description,
      dateNotificaction,
      platformChannelSpecifics,
    );
    dateReference = dateNotificaction; // => 2020-12-03T03:00:00.000
    showDialogMethod(
        "Success!",
        "You'll be notificated ${getDateStringFormatted(finalDate)}. The todo has been saved",
        "https://1.bp.blogspot.com/-ng6yNqIKDJ4/VIIagImcDeI/AAAAAAAADlo/rjXhLx5Eyyc/s1600/c9bd7a16beae0bd10b56eb511434b73c.jpg");
    // save(false, dateNotificaction);
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
      }
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
}
