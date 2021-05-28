import 'dart:developer';
import 'dart:convert';
import "package:flutter/material.dart";
import 'package:doanandroid/util/user.dart';
import 'package:doanandroid/util/server.dart';
import 'package:doanandroid/pages/login.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'dart:io';
import 'package:image/image.dart' as ImD;
import 'package:doanandroid/util/uploadimage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class EditProfile extends StatefulWidget {
  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {
  User _user;
  bool loadings = false;
  String s = 'notok';
  File file = File('');
  Data _data;
  bool uploading = false;
  String base64Image;
  String status = '';
  String postId = Uuid().v4();
  TextEditingController fullnamecontroller = TextEditingController();
  TextEditingController profilecontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();


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
    String fileName = file.path.split('/').last;
    // debugPrint(fileName);
    upload(fileName);
  }
  upload(String fileName) async {
    List<int> imageBytes = file.readAsBytesSync();
    base64Image = base64.encode(imageBytes);
    log(fileName);
    final request =  http.MultipartRequest(
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
    final fullname = fullnamecontroller.text == null ? _user.fullname : fullnamecontroller.text;
    final linkphoto = _data.data.url == null ? _user.photo :_data.data.url;
    final profile = profilecontroller.text == null ? _user.profile : profilecontroller.text;
    var data = {
      'fullname': fullname,
      'profile': profile,
      'photo' : linkphoto
    };
    String sever = Server.setupdateuser;
    String id = _user.userid;
    String url = '$sever/$id';
    print(url);
    print (fullname);
    print (profile);
    print (linkphoto);
    final http.Response response = await http.put(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(data));
    print(response.body);
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
        ? Scaffold(
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
                                    border:
                                        Border.all(width: 1, color: Colors.red),
                                    image: DecorationImage(
                                        image: s != ('ok')? NetworkImage(_user.photo): FileImage(file),
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
                        onPressed: startUpload,
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
                            style: TextStyle(color: Colors.red, fontSize: 20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        : loading();

  }
}
