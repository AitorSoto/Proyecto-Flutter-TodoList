import 'dart:io';

import 'package:TodosApp/Model/todo.dart';
import 'package:TodosApp/Screens/dailyNotifications.dart';
import 'package:TodosApp/Screens/profilescreen.dart';
import 'package:TodosApp/Screens/tododetail.dart';
import 'package:TodosApp/Screens/todospage.dart';
import 'package:TodosApp/Util/dbhelper.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.Dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dcdg/dcdg.dart';

import 'graphicspage.dart';
import 'loginpage.dart';

UserDetails details;
//DbHelper helper;
void main() => runApp(MaterialApp(
        home: BottomNavBar(
      detailsUser: details,
    )));

class BottomNavBar extends StatefulWidget {
  final UserDetails detailsUser;
  BottomNavBar({this.detailsUser});
  @override
  _BottomNavBarState createState() => _BottomNavBarState(detailsUser);
}

class _BottomNavBarState extends State<BottomNavBar> {
  final UserDetails detailsUserState;
  static ProfileScreen profileScreen;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  @override
  void initState() {
    super.initState();
    try {
      helper = DbHelper();
      String usuarioLogueado;
      StorageReference storageReference = FirebaseStorage.instance
          .ref()
          .getRoot()
          .child(detailsUserState.userEmail)
          .child("app_fluttertodos.db");
      helper.initializeDb();
      checkEmail(this.detailsUserState.userEmail, storageReference);
      profileScreen = ProfileScreen(this.detailsUserState);
    } catch (PlatformException) {
      // When a new user logs into the app
      helper.deleteTodos();
      helper.deleteCategories();
    }
  }

  _BottomNavBarState(this.detailsUserState);
  int pageIndex = 1;
  GlobalKey _bottomNavigationKey = GlobalKey();

  static final TodoDetail todoDetail =
      TodoDetail(Todo('', 3, DateTime.now().toIso8601String(), '', 'Leisure'));
  final DataGraphic dataGraphic = DataGraphic();
  final TodosPage todosPage = TodosPage();
  final DailyNotification dailyNotificationPage = DailyNotification();

  Widget _showPage = todoDetail;
  Widget _pageChooser(int page) {
    switch (page) {
      case 0:
        return todosPage;
        break;
      case 1:
        return todoDetail;
        break;
      case 2:
        return dailyNotificationPage;
        break;
      case 3:
        return dataGraphic;
        break;
      case 4:
        return profileScreen;
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
                Icon(
                  Icons.calendar_today_outlined,
                  size: 30,
                ),
                Icon(Icons.graphic_eq, size: 30),
                Icon(Icons.account_circle, size: 30),
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

  UserDetails getUserDetails() {
    var userDetail = detailsUserState;
    return userDetail;
  }

  Future downloadFile(StorageReference reference) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File("${dir.path}/database/app_fluttertodos.db");
    print("---------> " + file.path);
    String url;
    try {
      url = await reference.getDownloadURL();
    } catch (PlattformException) {
      await helper.deleteTodos();
      await helper.deleteCategories();
      return;
    }
    final http.Response downloadData = await http.get(url);
    StorageFileDownloadTask task = reference.writeToFile(file);
  }

  Future<void> checkEmail(
      String emailLogued, StorageReference reference) async {
    final SharedPreferences preferences = await _prefs;
    if (!preferences.containsKey("email"))
      preferences.setString("email", emailLogued);
    if (preferences.getString("email") != emailLogued) {
      downloadFile(reference);
      preferences.setString("email", emailLogued);
    }
  }
}
