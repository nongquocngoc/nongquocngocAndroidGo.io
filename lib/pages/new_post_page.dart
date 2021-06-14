import 'dart:convert';
import 'dart:io';
import 'package:doanandroid/util/services.dart';
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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:image/image.dart' as ImD;
import 'package:flutter_spinkit/flutter_spinkit.dart';

class UploadPage extends StatefulWidget {
  @override
  _UploadPageState createState() => _UploadPageState();
}

class _UploadPageState extends State<UploadPage>
    with AutomaticKeepAliveClientMixin<UploadPage> {
  bool _isLoaderVisible = false;
  User _user;

  @override
  getuser() {
    Profile.getUser().then((user) {
      _user = user;
      return _user;
    });
  }
  File file;
  Data _data;
  bool uploading = false;
  String base64Image;
  String status = '';
  String postId = Uuid().v4();
  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  newpost() async {
    final description = descriptionTextEditingController.text;
    final location = locationTextEditingController.text;
    final username = _user.username;
    final linkphoto = _data.data.url;
    final photouser = _user.photo;
    final idpost = _user.id;
    var data = {
      'user': {"username": username, "photo": photouser},
      'linkphoto': linkphoto,
      'body': description,
      'location': location,
      'postid': idpost
    };
    final sever = Server.setcreatepost;
    String url = '$sever';
    print(url);
    final http.Response response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(data));
    print(response.body);
    return clearPostInfo();
  }

  captureImageWithCamera() async {
    Navigator.pop(context);
    File imagefile = await ImagePicker.pickImage(
      source: ImageSource.camera,
      maxHeight: 680,
      maxWidth: 970,
    );
    setState(() {
      this.file = imagefile;
    });
  }

  pickImageFromGallery() async {
    Navigator.pop(context);
    File imagefile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      this.file = imagefile;
    });
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

  displayUploadSrceen() {
    return Container(
      alignment: Alignment.center,
      color: Theme.of(context).accentColor.withOpacity(0.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.add_photo_alternate,
            color: Colors.grey,
            size: 200.0,
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: RaisedButton(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9.0),
              ),
              child: Text(
                "Upload Image",
                style: TextStyle(color: Colors.white, fontSize: 20.0),
              ),
              color: Colors.green,
              onPressed: () => takeImage(context),
            ),
          )
        ],
      ),
    );
  }

  clearPostInfo() async {
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    setState(() {
      file = null;
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

  startUpload() {
    String fileName = file.path.split('/').last;
    upload(fileName);
  }

  upload(String fileName) async {
    List<int> imageBytes = file.readAsBytesSync();
    base64Image = base64.encode(imageBytes);
    final request = http.MultipartRequest(
      "POST",
      Uri.parse(
          'https://api.imgbb.com/1/upload?key=65a52e41be0d263e2c5e13284c1da0af'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', file.path));
    var res = await request.send();
    final test = res.statusCode;
    final response = await http.Response.fromStream(res);
    _data = dataFromJson(response.body);
    print(_data.data.url);
    newpost();
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      _isLoaderVisible = context.loaderOverlay.visible;
    });
    if (_isLoaderVisible) {
      context.loaderOverlay.hide();
    }
    setState(() {
      _isLoaderVisible = context.loaderOverlay.visible;
    });
  }

  displayUploadFormScreen() {
    return LoaderOverlay(
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
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: clearPostInfo,
            ),
            title: Text(
              "New Post",
              style: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text(
                  "Share",
                  style: TextStyle(
                      color: Colors.lightGreenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.0),
                ),
              ),
            ],
          ),
          body: ListView(
            children: <Widget>[
              Container(
                height: 230.0,
                width: MediaQuery.of(context).size.width * 0.8,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                        image: FileImage(file),
                        fit: BoxFit.cover,
                      )),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(top: 12.0),
              ),
              ListTile(
                title: Container(
                  width: 250.0,
                  child: TextField(
                    style: TextStyle(color: Colors.black),
                    controller: descriptionTextEditingController,
                    decoration: InputDecoration(
                      hintText: "Say something about image.",
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.person_pin_circle,
                    color: Colors.black, size: 36.0),
                title: Container(
                  width: 250.0,
                  child: TextField(
                    style: TextStyle(color: Colors.black),
                    controller: locationTextEditingController,
                    decoration: InputDecoration(
                      hintText: "Write the location here.",
                      hintStyle: TextStyle(color: Colors.black),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              Container(
                width: 220.0,
                height: 110.0,
                alignment: Alignment.center,
                child: RaisedButton.icon(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35.0)),
                  color: Colors.green,
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.black,
                  ),
                  label: Text(
                    "Get my Current Location",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
              Container(
                width: 220.0,
                height: 110.0,
                alignment: Alignment.center,
                child: RaisedButton.icon(
                  onPressed: () {
                    context.loaderOverlay.show();
                    startUpload();
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35.0)),
                  color: Colors.green,
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.black,
                  ),
                  label: Text(
                    "UpLoad",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  bool get wantKeepAlive => true;

  @override
  // ignore: must_call_super
  Widget build(BuildContext context) {
    getuser();
    return file == null ? displayUploadSrceen() : displayUploadFormScreen();
  }
}
