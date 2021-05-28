import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:doanandroid/pages/root_app.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:doanandroid/util/user.dart';
import 'package:doanandroid/util/server.dart';

User user;
class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

 static final TextEditingController userId = new TextEditingController();
 static final TextEditingController password = new TextEditingController();
  var _textStyleBlack = new TextStyle(fontSize: 12.0, color: Colors.black);
  var _textStyleGrey = new TextStyle(fontSize: 12.0, color: Colors.grey);
  var _textStyleBlueGrey =
      new TextStyle(fontSize: 12.0, color: Colors.blueGrey);

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      body: getBody(),
    );
  }

  Widget _userIDEditContainer() {
    return new Container(
      child: new TextField(
        controller: userId,
        decoration: new InputDecoration(
            hintText: 'Phone number,email or username',
            border: new OutlineInputBorder(
              borderSide: new BorderSide(color: Colors.black),
            ),
            isDense: true),
        style: _textStyleBlack
      ),
    );
  }

  Widget _passwordEditContainer() {
    return new Container(
      padding: const EdgeInsets.only(top: 5.0),
      child: new TextField(
        controller: password,
        obscureText: true,
        decoration: new InputDecoration(
            hintText: 'Password',
            border: new OutlineInputBorder(
              borderSide: new BorderSide(color: Colors.black),
            ),
            isDense: true),
        style: _textStyleBlack,
      ),
    );
  }

  Widget _loginContainer() {
    return new GestureDetector(
      onTap: _login,

      child: new Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.only(top: 10.0),
        width: 500.0,
        height: 40.0,
        child: new Text(
          "Log In",
          style: new TextStyle(color: Colors.white),
        ),
        color: Colors.blue,
      ),
    );
  }

  Widget _facebookContainer() {
    return new Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.only(top: 10.0),
      width: 500.0,
      height: 40.0,
      color: Colors.blue,
      child: new GestureDetector(
        onTap: null,
        child: new Text(
          "Log in with facebook",
          style:
              new TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _bottomBar() {
    return new Container(
        alignment: Alignment.center,
        height: 50.0,
        child: new Column(
          children: <Widget>[
            new Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                new Container(
                  height: 1.0,
                  color: Colors.grey.withOpacity(0.7),
                ),
                new Padding(
                  padding: new EdgeInsets.only(top: 17.5),
                  child: new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new Text('Dont have an account?', style: _textStyleGrey),
                      new Text('Sign up.', style: _textStyleBlueGrey),
                    ],
                  ),
                )
              ],
            )
          ],
        ));
  }

  Widget getBody() {
    return new Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.all(25.0),
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Padding(
            padding: const EdgeInsets.only(top: 25.0, bottom: 15.0),
            child: new Text(
              'Instagram',
              style: new TextStyle(fontFamily: 'Billabong', fontSize: 50.0),
            ),
          ),
          _userIDEditContainer(),
          _passwordEditContainer(),
          _loginContainer(),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Text(
                'Forgot your login details?',
                style: _textStyleGrey,
              ),
              new FlatButton(
                onPressed: () {},
                child: new Text(
                  'Get help signing in.',
                  style: _textStyleBlueGrey,
                ),
              )
            ],
          ),
          new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Container(
                height: 1.0,
                width: MediaQuery.of(context).size.width / 2.7,
                color: Colors.grey,
                child: new ListTile(),
              ),
              new Text(
                ' OR ',
                style: new TextStyle(color: Colors.blueGrey),
              ),
              new Container(
                height: 1.0,
                width: MediaQuery.of(context).size.width / 2.7,
                color: Colors.grey,
              ),
            ],
          ),
          _facebookContainer()
        ],
      ),
    );
  }

   _login() async{
    final strUserName = userId.text;
    final strPassWord = password.text;
    var data = {'username': strUserName, 'password': strPassWord};
    String url = Server.setlogin;
    final http.Response response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(data));
    if (userId.text.isEmpty) {
      _showEmptyDialog("Type something");
    } else if (password.text.isEmpty) {
      _showEmptyDialog("Type something");
    } else if (response.statusCode == 200) {
      user = userFromJson(response.body);
      Navigator.push(
          context, new MaterialPageRoute(builder: (context) => new RootApp()));
      return getuserid();
    } else {
      return showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Warning'),
              content: Text('Username or password is not correct.'),
              actions: [
                TextButton(
                  onPressed: () {
                    return Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          });
    }
  }
  
 static getuserid(){
    String getuserid = user.userid;
    print(getuserid);
    return getuserid;
  }
  
  _showEmptyDialog(String title) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => new CupertinoAlertDialog(
              content: new Text("$title can't be empty"),
              actions: <Widget>[
                FlatButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: new Text("OK"))
              ],
            ));
  }
}


class Profile {
  static String server = _LoginState.getuserid();
  static String s = Server.setuser;
  static String url = '$s/$server';
  static Future<User> getUser() async {
    try {
          final response = await http.get(Uri.parse(url));
          if (response.statusCode == 200) {
            final User users = userFromJson(response.body);
            return users;
          } else {
            return User();
          }
        } catch (e) {
          return User();
        }
  }
  // static Future<User> getUser() async {
  //   var username = _LoginState.userId.text;
  //   var password = _LoginState.password.text;
  //   try {
  //     var data = {'username': "test1", 'password': "1"};
  //     final response = await http.post(Uri.parse(url),
  //         headers: <String, String>{
  //           'Content-Type': 'application/json',
  //         },
  //         body: json.encode(data));
  //     if (response.statusCode == 200) {
  //       final User users = userFromJson(response.body);
  //       return users;
  //     } else {
  //       return null;
  //     }
  //   } catch (e) {
  //     return null;
  //   }
  // }
}
