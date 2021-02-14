class Categories {
  String _category;
  int _repetitions;

  String get category => _category;
  int get repetitions => _repetitions;

  set category(String newCategory) {
    _category = newCategory;
  }

  set repetitions(int newRepetition) {
    _repetitions = newRepetition;
  }

  Map<String, dynamic> toMap() {
    var map = Map<String, dynamic>();
    map["category"] = _category;
    map["repetitions"] = _repetitions;
    return map;
  }

  Categories.fromObject(dynamic o) {
    this._category = o["category"];
    this._repetitions = o["repetitions"];
  }
}
