import 'package:flutter/material.dart';
import 'package:doanandroid/pages/login.dart';
import 'package:doanandroid/pages/root_app.dart';
import 'package:doanandroid/pages/EditProfile.dart';
import 'package:doanandroid/pages/comment.dart';
void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Login(),
        routes: <String, WidgetBuilder>{
          '/login' :(BuildContext context) => new Login(),
          '/RootApp': (BuildContext context) => new RootApp(),
          '/comment': (BuildContext context) => new comment(),
          '/Editprofile': (BuildContext context) => new EditProfile()
        },
      )
  );
}