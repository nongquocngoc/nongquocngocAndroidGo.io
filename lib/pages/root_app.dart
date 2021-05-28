import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:doanandroid/pages/account_page.dart';
import 'package:doanandroid/pages/home_page.dart';
import 'package:doanandroid/pages/new_post_page.dart';
import 'package:doanandroid/pages/activity_page.dart';
import 'package:doanandroid/pages/search_page.dart';
import 'package:doanandroid/pages/login.dart';
import 'package:doanandroid/theme/colors.dart';
import 'package:doanandroid/util/bottom_navigation_bar_json.dart';
import 'package:doanandroid/util/user.dart';


class RootApp extends StatefulWidget {
  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int indexPage = 0;
  User _user;
  bool loadings = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
      bottomNavigationBar: getBottomNavigationBar(),
    );
  }

  Widget getBody() {
    return IndexedStack(
      index: indexPage,
      children: [
        HomePage(),
        SearchPage(),
        UploadPage(),
        ActivityPage(),
        AccountPage(),
      ],
    );
  }

  Widget getBottomNavigationBar() {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: bgLightGrey,
        border: Border(top: BorderSide(width: 1, color: bgDark.withOpacity(0.3))),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(icons.length, (index) {
            return IconButton(
              onPressed: () {
                setState(() {
                  indexPage = index;
                });
              },
              icon: SvgPicture.asset(
                indexPage == index 
                ? icons[index]['active']
                : icons[index]['inactive'], 
                width: 25, 
                height: 25,
              ),
            );
          })
        ),
      ),
    );
  }
}