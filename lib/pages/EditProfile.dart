import 'dart:developer';
import 'dart:convert';
import 'package:doanandroid/util/services.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:doanandroid/util/user.dart';
import 'package:doanandroid/util/server.dart';
import 'package:doanandroid/pages/login.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'dart:io';
import 'package:image/image.dart' as ImD;
import 'package:doanandroid/util/uploadimage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  bool _isLoaderVisible = false;
  User _user;
  bool loadings = false;
  String s = 'notok';
  File file = File('');
  Data _data;
  bool confirm = false;
  String base64Image;
  String status = '';
  String postId = Uuid().v4();
  TextEditingController fullnamecontroller = TextEditingController();
  TextEditingController profilecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  TextEditingController newpasswordcontroller = TextEditingController();
  TextEditingController confirmpasscontroller = TextEditingController();

  Column buildDisplayNameField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              " Username",
              style: TextStyle(color: Colors.grey),
            )),
        TextField(
          controller: fullnamecontroller,
          decoration: InputDecoration(
            hintText: _user.fullname,
            //errorText: _displayNameValid ? null : "Display Name too short",
          ),
        )
      ],
    );
  }

  Column buildBioField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(top: 12.0),
          child: Text(
            "Bio",
            style: TextStyle(color: Colors.grey),
          ),
        ),
        TextField(
          controller: profilecontroller,
          decoration: InputDecoration(
            hintText: _user.profile,
            //errorText: _bioValid ? null : "Bio too long",
          ),
        )
      ],
    );
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

  takeImage(mContext) {
    return showDialog(
      context: mContext,
      builder: (context) {
        return SimpleDialog(
          title: Text(
            "New Post",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
          ),
          children: <Widget>[
            SimpleDialogOption(
              child: Text(
                "Capture Image with Camera",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: captureImageWithCamera,
            ),
            SimpleDialogOption(
              child: Text(
                "Select Image from Gallery",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: pickImageFromGallery,
            ),
            SimpleDialogOption(
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        );
      },
    );
  }

  changePass(mContext) {
    return showDialog(
      context: mContext,
      builder: (context) {
        return SimpleDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    "Old Password",
                    style: TextStyle(color: Colors.green),
                  )),
              TextField(
                obscureText: true,
                controller: passwordcontroller,
                decoration: InputDecoration(
                  hintText: ("nhap mat khau cu"),
                  //errorText: _displayNameValid ? null : "Display Name too short",
                ),
              )
            ],
          ),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SimpleDialogOption(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    passwordcontroller.clear();
                    Navigator.pop(context);
                  },
                ),
                SimpleDialogOption(
                  child: Text(
                    "CONFIRM",
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                  onPressed: () async {
                    if (passwordcontroller.text.isEmpty) {
                      _showEmptyDialog("Type something");
                    } else {
                      confirmPass();
                    }
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  newPass(mContext) {
    return showDialog(
      context: mContext,
      builder: (context) {
        return SimpleDialog(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                  padding: EdgeInsets.only(top: 12.0),
                  child: Text(
                    "New Password",
                    style: TextStyle(color: Colors.green),
                  )),
              TextField(
                obscureText: true,
                controller: newpasswordcontroller,
                decoration: InputDecoration(
                  hintText: ("nhap mat khau moi"),
                  //errorText: _displayNameValid ? null : "Display Name too short",
                ),
              ),
              TextField(
                obscureText: true,
                controller: confirmpasscontroller,
                decoration: InputDecoration(
                  hintText: ("xac nhan mat khau"),
                  //errorText: _displayNameValid ? null : "Display Name too short",
                ),
              )
            ],
          ),
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SimpleDialogOption(
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.black,
                    ),
                  ),
                  onPressed: () {
                    passwordcontroller.clear();
                    newpasswordcontroller.clear();
                    confirmpasscontroller.clear();
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                ),
                SimpleDialogOption(
                  child: Text(
                    "CONFIRM",
                    style: TextStyle(
                      color: Colors.green,
                    ),
                  ),
                  onPressed: () {
                    if (newpasswordcontroller.text.isEmpty ||
                        confirmpasscontroller.text.isEmpty) {
                      _showEmptyDialog("Type something");
                    } else if (newpasswordcontroller.text !=
                        confirmpasscontroller.text) {
                      _showEmptyDialog("password not contrain");
                    } else {
                      updatePass();
                    }
                  },
                ),
              ],
            )
          ],
        );
      },
    );
  }

  updatePass() async {
    final password = confirmpasscontroller.text;
    var data = {'password': password};
    String sever = Server.changepass;
    String id = _user.userid;
    String url = '$sever/$id';
    print(url);
    final http.Response response = await http.put(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(data));
    print(response.body);
    var res = response.statusCode;
    print(res);
    if (res == 200) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => new CupertinoAlertDialog(
                content: new Text("doi mat khau thanh cong"),
                actions: <Widget>[
                  FlatButton(
                      onPressed: () {
                        passwordcontroller.clear();
                        newpasswordcontroller.clear();
                        confirmpasscontroller.clear();
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      },
                      child: new Text("OK"))
                ],
              ));
    } else {
      _showEmptyDialog("doi mat khau khong thanh cong or ");
    }
  }

  confirmPass() async {
    final password = passwordcontroller.text;
    final username = _user.username;
    var data = {'password': password, 'username': username};
    String sever = Server.setlogin;
    String url = '$sever';
    print(url);
    final http.Response response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(data));
    print(response.body);
    var res = response.statusCode;
    print(res);
    print("$username : $password");
    if (res == 200) {
      newPass(context);
    } else {
      _showEmptyDialog("wrong password or ");
    }
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

  captureImageWithCamera() async {
    Navigator.pop(context);
    File imagefile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 680,
      maxWidth: 970,
    );
    setState(() {
      s = 'ok';
      this.file = imagefile;
    });
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    File imagefile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      s = 'ok';
      this.file = imagefile;
    });
  }

  compressPhoto() async {
    final tDirectory = await getTemporaryDirectory();
    final path = tDirectory.path;
    ImD.Image mImageFile = ImD.decodeImage(file.readAsBytesSync());
    final compressedImageFile = File('$path/img_$postId.jpg')
      ..writeAsBytesSync(ImD.encodeJpg(mImageFile, quality: 60));
    setState(() {
      file = compressedImageFile;
    });
  }

  clearPostInfo() async {
    setState(() {
      file = File('');
    });
    Navigator.pop(context);
  }

  startUpload() {
    if (s == "ok") {
      String fileName = file.path.split('/').last;
      log(fileName);
      upload(fileName);
    } else {
      print(_data);
      update();
    }
  }

  upload(String fileName) async {
    List<int> imageBytes = file.readAsBytesSync();
    base64Image = base64.encode(imageBytes);
    log(fileName);
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(
          'https://api.imgbb.com/1/upload?key=65a52e41be0d263e2c5e13284c1da0af'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', file.path));
    var res = await request.send();
    final test = res.statusCode;
    final response = await http.Response.fromStream(res);
    log(test.toString());
    _data = dataFromJson(response.body);
    print(_data.data.url);
    update();
  }

  update() async {
    final fullname = fullnamecontroller.text == null
        ? _user.fullname
        : fullnamecontroller.text;
    final linkphoto = _data == null ? _user.photo : _data.data.url;
    final profile =
        profilecontroller.text == null ? _user.profile : profilecontroller.text;
    var data = {'fullname': fullname, 'profile': profile, 'photo': linkphoto};
    String sever = Server.setupdateuser;
    String id = _user.id;
    String url = '$sever/$id';
    print(url);
    print(fullname);
    print(profile);
    print(linkphoto);
    final http.Response response = await http.put(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(data));
    print(response.body);
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      _isLoaderVisible = context.loaderOverlay.visible;
    });
    if (_isLoaderVisible) {
      context.loaderOverlay.hide();
    }
    setState(() {
      _isLoaderVisible = context.loaderOverlay.visible;
    });
    return clearPostInfo();
  }

  @override
  Widget build(BuildContext context) {
    Profile.getUser().then((value) {
      setState(() {
        _user = value;
        loadings = true;
      });
    });
    return loadings == true
        ? LoaderOverlay(
            useDefaultLoading: false,
            overlayWidget: Center(
              child: SpinKitCircle(
                color: Colors.red,
                size: 50.0,
              ),
            ),
            overlayOpacity: 0.8,
            child: Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.white,
                iconTheme: IconThemeData(color: Colors.black),
                title: Text(
                  "Edit Profile",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                actions: <Widget>[
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.done,
                      size: 30.0,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              body: ListView(
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.only(
                            top: 16.0,
                            bottom: 8.0,
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  height: 100,
                                  width: 100,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          width: 1, color: Colors.red),
                                      image: DecorationImage(
                                          image: s != ('ok')
                                              ? NetworkImage(_user.photo)
                                              : FileImage(file),
                                          fit: BoxFit.cover))),
                              RaisedButton(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(9.0),
                                ),
                                child: Text(
                                  "Change avatar",
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 20.0),
                                ),
                                color: Colors.green,
                                onPressed: () => takeImage(context),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: <Widget>[
                              buildDisplayNameField(),
                              buildBioField(),
                            ],
                          ),
                        ),
                        RaisedButton(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9.0),
                          ),
                          child: Text(
                            "Change password",
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                          color: Colors.green,
                          onPressed: () => changePass(context),
                        ),
                        Divider(),
                        RaisedButton(
                          onPressed: () {
                            context.loaderOverlay.show();
                            startUpload();
                          },
                          child: Text(
                            "Update Profile",
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.0),
                          child: FlatButton.icon(
                            icon: Icon(Icons.cancel, color: Colors.red),
                            label: Text(
                              "Logout",
                              style:
                                  TextStyle(color: Colors.red, fontSize: 20.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ))
        : loading();
  }
}
