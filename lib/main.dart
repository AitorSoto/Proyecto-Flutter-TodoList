import 'package:TodosApp/Screens/todolist.dart';
import 'package:TodosApp/Screens/todosettings.dart';
import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/services.Dart';
import 'Model/todo.dart';
import 'Screens/tododetail.dart';
import 'Screens/todomain.dart';
import 'Screens/todospage.dart';

void main() => runApp(MaterialApp(home: BottomNavBar()));

class BottomNavBar extends StatefulWidget {
  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int pageIndex = 0;
  GlobalKey _bottomNavigationKey = GlobalKey();
  TodoMain todoMain = TodoMain();
  final TodoDetail todoDetail = TodoDetail(Todo('', 3, ''));
  final TodoSettings todoSettings = TodoSettings();
  final DataGraphic dataGraphic = DataGraphic();
  final TodosPage todosPage = TodosPage();

  Widget _showPage = new TodoMain();
  Widget _pageChooser(int page) {
    switch (page) {
      case 0:
        return todosPage;
        break;
      case 1:
        return todoDetail;
        break;
      case 2:
        return dataGraphic;
        break;
      case 3:
        return todoSettings;
        break;
      default:
        return Container(
            child: new Center(
                child: Text(
          "No page found by chooser",
          style: TextStyle(fontSize: 20.0),
        )));
    }
  }

  @override
  Widget build(BuildContext context) {
    _portraitModeOnly();
    return MaterialApp(
        // Should be surrounded by a MaterialApp to work fine
        theme: ThemeData(),
        darkTheme: ThemeData.dark(), // To convert all the app to Dark mode :D
        home: Scaffold(
            bottomNavigationBar: CurvedNavigationBar(
              key: _bottomNavigationKey,
              index: pageIndex,
              height: 50.0,
              items: <Widget>[
                Icon(Icons.list, size: 30),
                Icon(Icons.add, size: 30),
                Icon(Icons.graphic_eq, size: 30),
                Icon(Icons.account_circle, size: 30),
                //Icon(Icons.account_box, size: 30),
              ],
              color: Color(0xFF39A9DB),
              buttonBackgroundColor: Color(0xFF323BFF),
              backgroundColor: Color(0xFF39A9DB),
              animationCurve: Curves.easeInOut,
              animationDuration: Duration(milliseconds: 400),
              onTap: (int tappedIndex) {
                setState(() {
                  _showPage = _pageChooser(tappedIndex);
                });
              },
            ),
            body: Container(
              child: Center(child: _showPage),
            )));
  }

  void _portraitModeOnly() {
    // Disable the option of rotate the screen
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }
}
