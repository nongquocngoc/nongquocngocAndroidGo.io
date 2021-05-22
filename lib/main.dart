import 'package:flutter/material.dart';
import 'package:doanandroid/pages/login.dart';
import 'package:doanandroid/pages/root_app.dart';
void main() {
  runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Login(),
        routes: <String, WidgetBuilder>{
          '/RootApp': (BuildContext context) => new RootApp()
        },
      )
  );
}