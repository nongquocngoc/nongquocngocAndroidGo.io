import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import 'package:doanandroid/pages/root_app.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:doanandroid/util/user.dart';
import 'package:doanandroid/pages/register.dart';
import 'package:doanandroid/util/server.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';



class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  static getuserid () {
    log('get userid ' + _userid);
    return _userid;
  }

  static User user;
  static String _userid;
  bool _isLoaderVisible = false;
  static final TextEditingController userId = new TextEditingController();
  static final TextEditingController password = new TextEditingController();
  var _textStyleBlack = new TextStyle(fontSize: 12.0, color: Colors.black);
  var _textStyleGrey = new TextStyle(fontSize: 12.0, color: Colors.grey);
  var _textStyleBlueGrey =
      new TextStyle(fontSize: 12.0, color: Colors.blueGrey);

  @override
  void initState(){
    super.initState();
    setState(() {
      _userid = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: getBody(),
    );
  }

  Widget _userIDEditContainer() {
    return new Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: userId,
        decoration: InputDecoration(labelText: "Username"),
      ),
    );
  }

  Widget _passwordEditContainer() {
    return new Container(
      alignment: Alignment.center,
      margin: EdgeInsets.symmetric(horizontal: 40),
      child: TextField(
        controller: password,
        decoration: InputDecoration(labelText: "Password"),
        obscureText: true,
      ),
    );
  }

  Widget _loginContainer() {
    return new GestureDetector(
        onTap: () async {
          context.loaderOverlay.show();
          _login();
          await Future.delayed(Duration(seconds: 5));
          setState((){
            _isLoaderVisible = context.loaderOverlay.visible;
          });
          if (_isLoaderVisible) {
            context.loaderOverlay.hide();
          }
        },
        child: new Container(
          alignment: Alignment.center,
          height: 50.0,
          width: MediaQuery.of(context).size.width * 0.5,
          decoration: new BoxDecoration(
              borderRadius: BorderRadius.circular(80.0),
              gradient: new LinearGradient(colors: [
                Color.fromARGB(255, 255, 136, 34),
                Color.fromARGB(255, 255, 177, 41)
              ])),
          padding: const EdgeInsets.all(0),
          child: Text(
            "LOGIN",
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ));
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
    return LoaderOverlay(
        useDefaultLoading: false,
        overlayWidget: Center(
          child: SpinKitCircle(
            color: Colors.red,
            size: 50.0,
          ),
        ),
        overlayOpacity: 0.8,
        child: Container(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.symmetric(horizontal: 40),
          child: new Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new Padding(
                padding: const EdgeInsets.only(top: 25.0, bottom: 15.0),
                child: new Text(
                  'margratsni',
                  style: new TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2661FA),
                      fontSize: 36),
                ),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              _userIDEditContainer(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              _passwordEditContainer(),
              SizedBox(height: MediaQuery.of(context).size.height * 0.03),
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: Text(
                  "Forgot your password?",
                  style: TextStyle(
                      fontSize: 12,
                      color: Color(0XFF2661FA)
                  ),
                ),
              ),
              _loginContainer(),
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: GestureDetector(
                  onTap: () => {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterScreen()))
                  },
                  child: Text(
                    "Don't Have an Account? Sign up",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2661FA)
                    ),
                  ),
                ),
              )
              // new Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     new Text(
              //       'Forgot your login details?',
              //       style: _textStyleGrey,
              //     ),
              //     new FlatButton(
              //       onPressed: () {},
              //       child: new Text(
              //         'Get help signing in.',
              //         style: _textStyleBlueGrey,
              //       ),
              //     )
              //   ],
              // ),
              // new Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: <Widget>[
              //     new Container(
              //       height: 1.0,
              //       width: MediaQuery.of(context).size.width / 2.7,
              //       color: Colors.grey,
              //       child: new ListTile(),
              //     ),
              //     new Text(
              //       ' OR ',
              //       style: new TextStyle(color: Colors.blueGrey),
              //     ),
              //     new Container(
              //       height: 1.0,
              //       width: MediaQuery.of(context).size.width / 2.7,
              //       color: Colors.grey,
              //     ),
              //   ],
              // ),
              // _facebookContainer()
            ],
          ),

        ));
  }

  _login() async {
    // setState(() {
    //   _isLoaderVisible = context.loaderOverlay.visible;
    // });
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
      final prefs = await SharedPreferences.getInstance();
      await Future.delayed(Duration(seconds: 4));
      setState((){
        _isLoaderVisible = context.loaderOverlay.visible;
        user = userFromJson(response.body);
        _userid = user.id;
      });
      if (_isLoaderVisible) {
        context.loaderOverlay.hide();
      }
      // _saveAndRedirectToHome();
      Navigator.pushNamedAndRemoveUntil(
          context, '/RootApp', ModalRoute.withName('/RootApp'),
          arguments: (_userid));
      // Navigator.push(
      //     context, new MaterialPageRoute(builder: (context) => new RootApp()));
      prefs.setString('sessionuser', _userid);
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
  // Future<void> _saveAndRedirectToHome() async {
  //   Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  //   final SharedPreferences prefs = await _prefs;
  //   await prefs.setString("userId", _userid);
  // }

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
