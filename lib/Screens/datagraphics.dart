import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DataGraphics extends StatefulWidget {
  @override
  _DataGraphicsState createState() => _DataGraphicsState();
}

// ahqgdikghhweuirgh
class _DataGraphicsState extends State {
  bool state = false;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Switch(
        value: state,
        onChanged: (bool s) {
          setState(() {
            state = s;
          });
        },
      ),
    );
  }
}
