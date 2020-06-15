import 'dart:io';
import 'package:TodosApp/Util/dbhelper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_social_media_plugin/share_social_media_plugin.dart';
import 'loginpage.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  final UserDetails detailsUser;
  DbHelper helper;

  ProfileScreen({this.detailsUser, this.helper});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GoogleSignIn _gSignIn;
  DbHelper helper;

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
                      uploadFile(widget.detailsUser.userEmail);
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
                  FloatingActionButton(
                    tooltip: "Share the app with Instagram",
                    backgroundColor: Colors.pink,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Icon(
                          FontAwesomeIcons.instagram,
                          color: Colors.white,
                        ),
                      ],
                    ),
                    onPressed: () async {
                      await ShareSocialMediaPlugin.shareInstagram(
                          "hello", "flutter_assets/finger.jpeg");
                    },
                  )
                ],
              )),
          Padding(
              padding: EdgeInsets.only(top: 20.0),
              child: Row(
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
}
