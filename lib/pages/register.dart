import 'package:flutter/material.dart';
import 'package:doanandroid/pages/login.dart';
import 'package:doanandroid/util/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreen createState() => _RegisterScreen();
}

class _RegisterScreen extends State<RegisterScreen> {
  bool _isLoaderVisible = false;
  final TextEditingController usernamecrl = new TextEditingController();
  final TextEditingController fullnamecrl = new TextEditingController();
  final TextEditingController emailcrl = new TextEditingController();
  final TextEditingController passwordcrl = new TextEditingController();
  final TextEditingController cfpasswordcrl = new TextEditingController();

  _register(String username, String fullname, String email, String password) async {
    return Register.register(fullname, email, username, password);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: getBody(size),
    );
  }

  Widget getBody(size) {
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  "REGISTER",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2661FA),
                      fontSize: 36),
                  textAlign: TextAlign.left,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: usernamecrl,
                  decoration: InputDecoration(labelText: "User name"),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: fullnamecrl,
                  decoration: InputDecoration(labelText: "Full name"),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: emailcrl,
                  decoration: InputDecoration(labelText: "Email"),
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: passwordcrl,
                  decoration: InputDecoration(labelText: "Password"),
                  obscureText: true,
                ),
              ),
              SizedBox(height: size.height * 0.03),
              Container(
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 40),
                child: TextField(
                  controller: cfpasswordcrl,
                  decoration: InputDecoration(labelText: "Confirm Password"),
                  obscureText: true,
                ),
              ),
              SizedBox(height: size.height * 0.05),
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: RaisedButton(
                  onPressed: () async{
                    _register(usernamecrl.text, fullnamecrl.text, emailcrl.text,
                        passwordcrl.text);
                    print(Register.ok);
                    if (usernamecrl.text.isEmpty ||
                        fullnamecrl.text.isEmpty ||
                        emailcrl.text.isEmpty ||
                        passwordcrl.text.isEmpty ||
                        cfpasswordcrl.text.isEmpty) {
                      _showEmptyDialog("Vui long nhap day du thong tin");
                    } else if (passwordcrl.text != cfpasswordcrl.text) {
                      _showEmptyDialog("Mat khau khong khop");
                    } else {
                      if (Register.ok == 1) {
                        usernamecrl.clear();
                        fullnamecrl.clear();
                        emailcrl.clear();
                        passwordcrl.clear();
                        _showEmptyDialog("dang ky thanh cong");
                        await Future.delayed(Duration(seconds: 3));
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new Login()));
                      } else if (Register.ok == 0) {
                        _showEmptyDialog("Co loi khi dang ky");
                      }
                    }
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(80.0)),
                  textColor: Colors.white,
                  padding: const EdgeInsets.all(0),
                  child: Container(
                    alignment: Alignment.center,
                    height: 50.0,
                    width: size.width * 0.5,
                    decoration: new BoxDecoration(
                        borderRadius: BorderRadius.circular(80.0),
                        gradient: new LinearGradient(colors: [
                          Color.fromARGB(255, 255, 136, 34),
                          Color.fromARGB(255, 255, 177, 41)
                        ])),
                    padding: const EdgeInsets.all(0),
                    child: Text(
                      "SIGN UP",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
              Container(
                alignment: Alignment.centerRight,
                margin: EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                child: GestureDetector(
                  onTap: () {},
                  child: Text(
                    "Already Have an Account? Sign in",
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2661FA)),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  _showEmptyDialog(String title) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => new CupertinoAlertDialog(
              content: new Text("$title"),
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
