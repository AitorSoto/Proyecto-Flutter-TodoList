import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TodoSettings extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => TodoSettingsState();
}

class TodoSettingsState extends State {
  bool state = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Switch(
        value: state,
        onChanged: (bool s) {
          setState(() {
            state = s;
            debugPrint(state.toString());
          });
        },
      ),
    );
  }
}
