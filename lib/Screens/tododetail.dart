import 'dart:ffi';
import 'dart:typed_data';

import 'package:TodosApp/Model/todo.dart';
import 'package:TodosApp/Util/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
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
  String _priority = "Low";
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  DateTime date = DateTime.now(); // For datepicker
  TimeOfDay time = TimeOfDay.now(); // For hourpicker

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

    return Scaffold(
      appBar:
          AppBar(automaticallyImplyLeading: false, title: Text('Create Todo')),
      body: formTodo(), // Returns todo's form
    );
  }

  void save(bool showDialog) {
    if (todo.title.isNotEmpty && todo.description.isNotEmpty) {
      todo.date = new DateFormat.yMd().format(DateTime.now());
      helper.insertTodo(todo).then((_) => cancelTodo());
      if (showDialog)
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
          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 30.0, right: 10.0),
                  child: RaisedButton(
                    onPressed: () => save(true),
                    child: Text("Save Todo"),
                  )),
              Padding(
                  padding: EdgeInsets.only(top: 30.0),
                  child: RaisedButton(
                    onPressed: () => cancelTodo(),
                    child: Text("Cancel Todo"),
                    color: Colors.red,
                  )),
            ],
          )),
          Center(
              child: RaisedButton(
            onPressed: () {
              if (titleController.text.isNotEmpty &&
                  titleController.text.isNotEmpty)
                _showDateTimePicker();
              else
                showDialogMethod(
                    "This man is looking where the money went, and like him, we are looking for what you want to be notified about.",
                    "Tell us about you want to be notified by filling in the fields of title and description",
                    "https://media1.tenor.com/images/859f1642b89fb829d2ff6a08d708b437/tenor.gif?itemid=13868803");
            },
            child: Text("Set a notification and save"),
            color: Colors.purple,
          ))
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
    todo.title = "";
    todo.description = "";
    titleController.text = "";
    descriptionController.text = "";
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
    showDialogMethod(
        "Success!",
        "Youll be notificated the day ${dateNotificaction.day}/${dateNotificaction.month}/${dateNotificaction.year} at " +
            "${dateNotificaction.hour}:${dateNotificaction.minute}. The todo has been saved",
        "https://1.bp.blogspot.com/-ng6yNqIKDJ4/VIIagImcDeI/AAAAAAAADlo/rjXhLx5Eyyc/s1600/c9bd7a16beae0bd10b56eb511434b73c.jpg");
    save(false);
  }

  Future<void> _showDateTimePicker() async {
    DatePicker.showDateTimePicker(context,
        showTitleActions: true,
        minTime: DateTime.now(),
        maxTime: DateTime(date.year + 2, date.month, date.day),
        onConfirm: (date) {
      print("Confirmado $date");
      _scheduleNotification(todo.title, todo.description, date);
    }, locale: LocaleType.en);
  }
}
