import 'package:dcdg/dcdg.dart';
class Reminders {
  int _id;
  String _reminderName;
  String _reminderHour;

  Reminders([this._id, this._reminderHour, this._reminderName]);

  int get id => _id;
  String get reminderName => _reminderName;
  String get reminderHour => _reminderHour;

  set reminderName(String newReminderName) {
    _reminderName = newReminderName;
  }

  set reminderHour(String newReminderHour) {
    _reminderHour = newReminderHour;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["id"] = _id;
    map["reminderHour"] = _reminderHour;
    map["reminderName"] = _reminderName;
    return map;
  }

  Reminders.fromObject(dynamic o) {
    this._id = o["id"];
    this._reminderHour = o["reminderHour"];
    this._reminderName = o["reminderName"];
  }
}
