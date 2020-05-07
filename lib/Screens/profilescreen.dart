import 'dart:ui' as prefix0;
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'loginpage.dart';

class ProfileScreen extends StatefulWidget {
  final UserDetails detailsUser;

  ProfileScreen({this.detailsUser});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  GoogleSignIn _gSignIn;

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
                    onPressed: () {},
                  ),
                  RaisedButton(
                    child: Text(
                      "Log out",
                    ),
                    color: Colors.blue,
                    onPressed: () {
                      _gSignIn.signOut();
                      navigateToLoginPage(context);
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
}
