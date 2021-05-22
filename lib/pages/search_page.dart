
import 'package:flutter/material.dart';
class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  AppBar searchPageHeader(){
    return AppBar(
      backgroundColor: Colors.white,
      title:  TextFormField(
        style: TextStyle(
          fontSize: 18.0,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: "Search here...",
          hintStyle: TextStyle(color: Colors.black),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          filled: true,
          prefixIcon: Icon(Icons.person_pin, color: Colors.black, size: 30.0,),
          suffixIcon: IconButton(icon: Icon(Icons.clear,color: Colors.black,),)
        ),

      ),
    );
  }
  Container displayNoSearchResultsScreen(){
    // final Orientation orientation = MediaQuery.of(context).orientation;
    return Container(
      child: Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            Icon(Icons.group,color: Colors.grey,size: 200.0,),
            Text(
              "Search Users",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500, fontSize: 65.0),
            )
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: searchPageHeader(),
      body: displayNoSearchResultsScreen(),
    );
  }
}

