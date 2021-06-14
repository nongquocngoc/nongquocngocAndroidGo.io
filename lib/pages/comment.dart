import 'package:doanandroid/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:flutter_svg/svg.dart';
import 'package:doanandroid/pages/chat_page.dart';
import 'package:doanandroid/theme/colors.dart';
import 'package:doanandroid/util/story_json.dart';
import 'package:doanandroid/util/posts.dart';
import 'package:doanandroid/util/server.dart';
import 'package:doanandroid/util/services.dart';
import 'package:doanandroid/util/comment.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:doanandroid/pages/login.dart';
import 'package:doanandroid/util/uploadimage.dart';
import 'package:doanandroid/util/server.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:path_provider/path_provider.dart';
import 'package:doanandroid/util/user.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:doanandroid/util/user.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get/get.dart';

class comment extends StatefulWidget {
  @override
  _comment createState() => _comment();
}

class _comment extends State<comment> {
  final TextEditingController _commentController = TextEditingController();
  bool _isLoaderVisible = false;
  List<Comment> _comments;
  bool loadcomment = false;
  User _user;

  void initState() {
    super.initState();
    Profile.getUser().then((user) {
      setState(() {
        _user = user;
        print('reload comment');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final postid = ModalRoute.of(context).settings.arguments;
    print('id post in comment page: $postid');
    getComment(postid);
    var size = MediaQuery.of(context).size;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          iconTheme: IconThemeData(color: Colors.black),
          title: Text(
            "Comments",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.grey,
        ),
        body: loadcomment == false ? loading() : buildPage(postid));
  }

  Widget loading() {
    return SafeArea(
      child: Scaffold(
        body: Center(child: SpinKitFadingCircle(
          itemBuilder: (BuildContext context, int index) {
            return DecoratedBox(
              decoration: BoxDecoration(
                color: index.isEven ? Colors.red : Colors.green,
              ),
            );
          },
        )),
      ),
    );
  }

  getComment(String idpost) {
    svComments.getComment(idpost).then((comments) async {
      await Future.delayed(Duration(seconds: 5));
      log('dang load comment nek');
      if (comments != null) {
        setState(() {
          _comments = comments;
          loadcomment = true;
        });
        log('dang load xong comment roi  nek');
        log('loadcoment : $loadcomment  ');
      }
      return loadcomment;
    });
  }

  Widget buildPage(String postid) {
    return LoaderOverlay(
      useDefaultLoading: false,
      overlayWidget: Center(
        child: SpinKitCircle(
          color: Colors.red,
          size: 50.0,
        ),
      ),
      overlayOpacity: 0.8,
      child: Column(
        children: [
          Expanded(
            child: buildComments(postid),
          ),
          Divider(),
          ListTile(
            title: TextFormField(
              controller: _commentController,
              decoration: InputDecoration(labelText: 'Write a comment...'),
              // onFieldSubmitted: comment(),
            ),
            trailing: OutlineButton(
              onPressed: () {
                context.loaderOverlay.show();
                log('full name in comment: ' + _user.fullname);
                if(_commentController.text.isEmpty){
                  _showEmptyDialog('comment');
                }else{
                  comment(postid, _user.fullname, _user.photo,
                      _commentController.text);
                  _commentController.clear();
                }
              },
              borderSide: BorderSide.none,
              child: Text("Post"),
            ),
          ),
        ],
      ),
    );
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

  Widget buildComments(String idpost) {
    return Column(
      children: List.generate(_comments.length, (index) {
        Comment comment = _comments[index];
        return LoaderOverlay(
          overlayColor: Colors.black.withOpacity(0),
          useDefaultLoading: false,
          overlayWidget: Center(
            child: SpinKitCircle(
              color: Colors.red,
              size: 50.0,
            ),
          ),
          overlayOpacity: 0.8,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 30, 20),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // gradient: LinearGradient(colors: bgStoryColors),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(1.3),
                    child: Container(
                      height: 30,
                      width: 30,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 1, color: Colors.grey),
                          image: DecorationImage(
                              image: NetworkImage(comment.user.photo),
                              fit: BoxFit.cover)),
                    ),
                  ),
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Text(
                      '${comment.user == null ? 0 : comment.user.username} : ${comment.detail}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      }),
    );
  }

  comment(String postid, String username, String photo, String detail) async {
    log('dang them comment ne');
    String isdetail = detail;
    var data = {
      'postid': postid,
      'user': {'username': username, 'photo': photo},
      'detail': isdetail
    };
    String url = '${Server.setcomment}';
    print(url);
    final http.Response response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(data));
    print(response.body);
    setState(() {
      _isLoaderVisible = context.loaderOverlay.visible;
    });
    if (_isLoaderVisible) {
      context.loaderOverlay.hide();
    }
    getComment(postid);
  }
}
