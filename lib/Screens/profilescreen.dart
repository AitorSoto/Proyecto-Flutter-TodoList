import 'dart:io';
import 'package:TodosApp/Screens/webExplorer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'loginpage.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:achievement_view/achievement_view.dart';
import 'package:dcdg/dcdg.dart';

class ProfileScreen extends StatefulWidget {
  final UserDetails detailsUser;
  ProfileScreen(this.detailsUser);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GoogleSignIn _gSignIn;
  WebViewContainer webViewContainer;
  @override
  Widget build(BuildContext context) {
    _gSignIn = GoogleSignIn();
    print(widget.detailsUser.userName);
    return buildPage(context);
  }

  Scaffold buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("User's profile"),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Container(
            height: 190,
            padding: EdgeInsets.only(bottom: 10.0),
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: new NetworkImage(
                        "https://s1.1zoom.me/big0/149/Norway_Sky_Aurora_Night_442507.jpg"),
                    fit: BoxFit.cover)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                      image: new DecorationImage(
                          image: new NetworkImage(widget.detailsUser.photoUrl),
                          fit: BoxFit.cover),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4)),
                  margin: EdgeInsets.only(bottom: 5.0),
                ),
                Text(
                  widget.detailsUser.userName,
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
                Text(
                  widget.detailsUser.userEmail,
                  style: TextStyle(color: Colors.white, fontSize: 17),
                ),
              ],
            ),
          ),
          Padding(
              padding: EdgeInsets.only(top: 20),
              child: Column(
                children: <Widget>[
                  RaisedButton(
                    child: Text(
                      "Sync todos at Google Cloud ",
                    ),
                    color: Colors.blue,
                    onPressed: () {
                      uploadFile(widget.detailsUser.userEmail)
                          .then((_) => show(context));
                    },
                  ),
                  RaisedButton(
                    child: Text(
                      "Log out",
                    ),
                    color: Colors.blue,
                    onPressed: () {
                      uploadFile(widget.detailsUser.userEmail).then((_) =>
                          _gSignIn
                              .signOut()
                              .then((_) => navigateToLoginPage(context)));
                    },
                  ),
                ],
              )),
          Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.info),
                  SizedBox(
                    width: 5.0,
                  ),
                  Text(
                    "We highly recommend to sync tasks regularly with Google Cloud",
                    style: TextStyle(fontSize: 11),
                  )
                ],
              ))
        ],
      ),
      floatingActionButton: SpeedDial(
          animatedIcon: AnimatedIcons.menu_arrow,
          tooltip: "Our social networks",
          backgroundColor: Colors.blue,
          children: [
            SpeedDialChild(
                child: Icon(
                  FontAwesomeIcons.instagram,
                  color: Colors.white,
                ),
                labelBackgroundColor: Colors.pink,
                backgroundColor: Colors.pink,
                label: "Follow us on Instagram",
                onTap: () => handleURLButtonPress(
                    context, "https://www.instagram.com/aitor_soto99/")),
            SpeedDialChild(
                child: Icon(
                  FontAwesomeIcons.twitter,
                  color: Colors.white,
                ),
                labelBackgroundColor: Colors.blueAccent,
                backgroundColor: Colors.blueAccent,
                label: "Follow us on Twitter",
                onTap: () => handleURLButtonPress(
                    context, "https://twitter.com/aitorsotojimnez?lang=es"))
          ]),
    );
  }

  Future navigateToLoginPage(context) async {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future uploadFile(String emailUser) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final File file = File("${dir.path}/database/app_fluttertodos.db");
    StorageReference storageReference =
        FirebaseStorage.instance.ref().getRoot().child(emailUser);
    StorageUploadTask uploadTask =
        storageReference.child("app_fluttertodos.db").putFile(file);
    await uploadTask.onComplete;
    print('File Uploaded');
  }

  void handleURLButtonPress(BuildContext context, String url) {
    webViewContainer = WebViewContainer(url);
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => WebViewContainer(url)));
  }

  void show(BuildContext context) {
    AchievementView(
      context,
      icon: Icon(
        FontAwesomeIcons.upload,
        color: Colors.white,
      ),
      title: "Synchronized with cloud",
      subTitle: "Nothing to see here ",
      isCircle: true,
      color: Colors.blue,
      listener: (status) {
        print(status);
      },
    )..show();
  }
}
