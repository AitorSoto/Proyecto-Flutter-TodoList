import 'package:TodosApp/Model/reminders.dart';
import 'package:TodosApp/Util/dbhelper.dart';
import 'package:TodosApp/Util/notificationmanager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:giffy_dialog/giffy_dialog.dart';

class DailyNotificationMain extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(theme: ThemeData(), home: DailyNotification());
  }
}

class DailyNotification extends StatefulWidget {
  @override
  _DailyNotificationState createState() => _DailyNotificationState();
}

class _DailyNotificationState extends State<DailyNotification> {
  TextEditingController controllerNameTask = new TextEditingController();
  TextEditingController controllerNameTaskDialog = new TextEditingController();
  TextEditingController controllerHourTaskDialog = new TextEditingController();
  TimeOfDay timeNewNotification = new TimeOfDay();
  Reminders reminder = new Reminders();
  List<Reminders> reminders = new List();
  List<Reminders> filteredReminders = List();
  DbHelper helper = DbHelper();
  NotificationManager manager = NotificationManager();

  @override
  void initState() {
    super.initState();
    {
      setState(() {
        reminders = getData();
        filteredReminders = reminders;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyleTitle = Theme.of(context).textTheme.title;

    return new Scaffold(
        appBar: AppBar(
          title: Text("Daily reminders"),
        ),
        body: Column(
          children: [
            Padding(
                padding: EdgeInsets.all(10.0),
                child: TextField(
                  decoration: InputDecoration(
                      labelText: "Name the daily reminder",
                      labelStyle: textStyleTitle,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                  controller: controllerNameTask,
                )),
            Column(children: <Widget>[
              RaisedButton(
                child: Text(
                  "Schedule the reminder",
                ),
                color: Colors.blue,
                onPressed: () {
                  pickTime();
                },
              ),
            ]),
            Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(children: <Widget>[
                  RaisedButton(
                    child: Text(
                      "Add reminder",
                    ),
                    color: Colors.blue,
                    onPressed: () async {
                      if (!checkHourAndNameCompleted()) {
                        showDialogMethod(
                            "Something is not fine",
                            "You have to declare an hour and a title for your reminder, we'd like to be fortune-teller, but we are not",
                            "https://media.tenor.com/images/3913923a4af61672e4be57ee67977fdb/tenor.gif");
                      } else {
                        int newId = await helper.getLastReminderId();
                        int hour =
                            int.parse(reminder.reminderHour.split(":")[0]);
                        int minute =
                            int.parse(reminder.reminderHour.split(":")[1]);
                        Reminders insertRemider = Reminders(
                            newId,
                            hour.toString() + ":" + minute.toString(),
                            controllerNameTask.text);
                        await helper.insertReminder(insertRemider);
                        manager.showNotificationDaily(
                            insertRemider.id,
                            insertRemider.reminderName,
                            insertRemider.reminderName,
                            hour,
                            minute);
                        setState(() {
                          reminders = getData();
                          filteredReminders = reminders;
                        });
                        eraseContent();
                        showDialogMethod(
                            "Clue, look up!",
                            "Exactly, everithing went right. The reminder was saved and you will be notificated everyday by now",
                            "https://media1.tenor.com/images/3b76a7f4cc2271c641369ad2bfb300a5/tenor.gif?itemid=10340659");
                      }
                    },
                  ),
                ])),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.all(10.0),
                itemCount: filteredReminders.length,
                itemBuilder: (BuildContext context, int index) {
                  return Card(
                      elevation: 2.0,
                      child: GestureDetector(
                        onTap: () {
                          reminder = this.filteredReminders[index];
                          controllerNameTaskDialog.text =
                              reminders[index].reminderName;
                          controllerHourTaskDialog.text =
                              reminders[index].reminderHour;
                          showEditingDialog();
                        },
                        child: ListTile(
                          title:
                              Text(this.filteredReminders[index].reminderName),
                          subtitle:
                              Text(this.filteredReminders[index].reminderHour),
                        ),
                      ));
                },
              ),
            )
          ],
        ));
  }

  void showDialogMethod(String title, String description, String urlGif) {
    showDialog(
        context: context,
        builder: (_) => NetworkGiffyDialog(
              key: Key("Network"),
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

  List<Reminders> getData() {
    final dbFuture = helper.initializeDb();
    List<Reminders> dataReminders = List<Reminders>();
    dbFuture.then((result) {
      final remindersFuture = helper.getReminders();
      remindersFuture.then((result) {
        int count = result.length;
        for (int i = 0; i < count; i++) {
          dataReminders.add(Reminders.fromObject(result[i]));
        }
        setState(() {
          reminders = dataReminders;
          count = count;
        });
      });
    });
    return dataReminders;
  }

  bool checkHourAndNameCompleted() {
    return reminder.reminderHour != null && controllerNameTask.text != "";
  }

  pickTime() async {
    TimeOfDay t =
        await showTimePicker(context: context, initialTime: TimeOfDay.now());
    if (t != null)
      setState(() {
        reminder.reminderHour = t.hour.toString() + ":" + t.minute.toString();
      });
  }

  void eraseContent() {
    controllerHourTaskDialog.text = "";
    controllerNameTask.text = "";
    controllerNameTaskDialog.text = "";
    reminder = new Reminders();
  }

  void showEditingDialog() {
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
                        controller: controllerNameTaskDialog,
                        decoration: InputDecoration(
                            labelText: "Notification name",
                            labelStyle: textStyle,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5.0))),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 10.0),
                      child: RaisedButton(
                        onPressed: () => pickTime(),
                        child: Text("Set an hour"),
                        color: Colors.purple,
                      ),
                    ),
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
                                if (reminder.id == null) {
                                  return;
                                }
                                reminder.reminderName =
                                    controllerNameTaskDialog.text;
                                reminder.reminderHour =
                                    controllerHourTaskDialog.text;
                                result = await helper.updateReminder(reminder);
                                setState(() {
                                  reminders = getData();
                                  filteredReminders = reminders;
                                });
                                manager.removeReminder(reminder.id);
                                int hour = int.parse(
                                    reminder.reminderHour.split(":")[0]);
                                int minute = int.parse(
                                    reminder.reminderHour.split(":")[1]);
                                manager.showNotificationDaily(
                                    reminder.id,
                                    reminder.reminderName,
                                    reminder.reminderName,
                                    hour,
                                    minute);
                                Navigator.of(context).pop(context);
                              },
                              child: Text("Update Reminder"),
                              color: Colors.blue,
                            )),
                        Padding(
                            padding: EdgeInsets.only(top: 30.0),
                            child: RaisedButton(
                              onPressed: () async {
                                int result;
                                if (reminder.id == null) {
                                  return;
                                }
                                result =
                                    await helper.deleteReminder(reminder.id);
                                setState(() {
                                  reminders = getData();
                                  filteredReminders = reminders;
                                });
                                manager.removeReminder(reminder.id);
                                Navigator.of(context).pop(context);
                              },
                              child: Text("Delete Reminder"),
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
