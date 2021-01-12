class Todo {
  int _id;
  String _title;
  String _description;
  String _date;
  int _priority;
  String _typeTodo;

  Todo(this._title, this._priority, this._date, this._description,
      this._typeTodo);
  Todo.withId(this._id, this._title, this._priority, this._date,
      this._description, this._typeTodo);

  int get id => _id;
  String get title => _title;
  String get description => _description;
  String get date => _date;
  int get priority => _priority;
  String get typeTodo => _typeTodo;

  set title(String newTitle) {
    if (newTitle.length < 255) _title = newTitle;
  }

  set description(String newDescription) {
    if (newDescription.length < 255) _description = newDescription;
  }

  set priority(int newPriority) {
    if (newPriority >= 0 && newPriority <= 3) _priority = newPriority;
  }

  set date(String newDate) {
    _date = newDate;
  }

  set typeTodo(String newType) {
    _typeTodo = newType;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["title"] = _title;
    map["description"] = _description;
    map["priority"] = _priority;
    map["date"] = _date;
    map["typeTodo"] = _typeTodo;
    if (_id != null) map["id"] = _title;

    return map;
  }

  Todo.fromObject(dynamic o) {
    this._id = o["id"];
    this._title = o["title"];
    this._description = o["description"];
    this._priority = o["priority"];
    this._date = o["date"];
    this._typeTodo = o["typeTodo"];
  }
}
