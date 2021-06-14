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

User _user;

class HomePage extends StatefulWidget {
  final String text;

  HomePage({Key key, @required this.text}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loadcomment = false;
  bool didFetchComments = false;
  bool _isLoaderVisible = false;
  List<Post> _posts;
  bool loadings = false;
  File file = File('');
  String s = 'notok';
  Data _data;
  bool uploading = false;
  String base64Image;
  String status = '';
  String postId = Uuid().v4();
  TextEditingController descriptionTextEditingController =
      TextEditingController();
  TextEditingController locationTextEditingController = TextEditingController();

  final TextEditingController _commentController = TextEditingController();

  void initState() {
    super.initState();
    Services.getPosts().then((posts) {
      setState(() {
        _posts = posts;
        loadings = true;
        print('reload initstate');
      });
    });
  }

  void initState1() {
    super.initState();
    Profile.getUser().then((user) {
      setState(() {
        _user = user;
        print('reload initstate');
      });
    });
  }

  getpost() {
    Services.getPosts().then((posts) {
      _posts = posts.obs;
      loadings = true;
      print('reload homepage');
      return _posts;
    });
  }

  getuser() {
    Profile.getUser().then((user) {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    getpost();
    var size = MediaQuery.of(context).size;
    return loadings == true
        ? Scaffold(
            appBar: getAppBar(),
            body: getBody(size),
          )
        : loading();
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

  Widget getAppBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(55),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SvgPicture.asset("assets/images/logo.svg", width: 90),
              IconButton(
                  splashRadius: 15,
                  icon: Icon(FontAwesome5Brands.facebook_messenger),
                  onPressed: () {
                    Navigator.push(
                        context, MaterialPageRoute(builder: (_) => ChatPage()));
                  })
            ],
          ),
        ),
      ),
    );
  }

  deletepost(String idpost) async {
    String url = '${Server.deletepost}/$idpost';
    final response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      log('xoa post xong roi nek');
    }
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

  takepost(mContext, String id, String des, String local, String username,
      String photo, String idpost) {
    print(id);
    print(des);
    print(local);
    print(photo);
    print(idpost);
    descriptionTextEditingController.text = des;
    locationTextEditingController.text = local;
    return showDialog(
      context: mContext,
      builder: (context) {
        return SimpleDialog(
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => displayUploadFormScreen(
                            id, des, local, username, photo, idpost)));
              },
              child: Text(
                "Edit",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context);
                deletepost(idpost);
              },
              child: Text(
                "Delete",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  displayUploadFormScreen(String id, String des, String local, String username,
      String photo, String idpost) {
    print('s in display: $s');
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
              "Back",
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
                        image: s != 'ok' ? NetworkImage(id) : FileImage(file),
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
                  onPressed: () {
                    takeImage(context);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35.0)),
                  color: Colors.green,
                  icon: Icon(
                    Icons.photo,
                    color: Colors.black,
                  ),
                  label: Text(
                    "Change picture",
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
                    startUpdate(username, photo, idpost, id);
                  },
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(35.0)),
                  color: Colors.green,
                  icon: Icon(
                    Icons.location_on,
                    color: Colors.black,
                  ),
                  label: Text(
                    "UPDATE",
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              )
            ],
          ),
        ));
  }

  startUpdate(String username, String photo, String idpost, String id) {
    if (s == 'ok') {
      String fileName = file.path.split('/').last;
      upload(fileName, username, photo, idpost);
    } else {
      updatePost(username, photo, idpost, id);
    }
  }

  upload(String fileName, String username, String photo, String idpost) async {
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
    updatePost(username, photo, idpost, _data.data.url);
    await Future.delayed(Duration(seconds: 5));
    setState(() {
      _isLoaderVisible = context.loaderOverlay.visible;
    });
    if (_isLoaderVisible) {
      context.loaderOverlay.hide();
    }
  }

  updatePost(String username, String photo, String idpost, String id) async {
    final description = descriptionTextEditingController.text;
    final location = locationTextEditingController.text;
    final linkphoto = _data == null ? id : _data.data.url;
    var data = {
      'user': {"username": username, "photo": photo},
      'linkphoto': linkphoto,
      'body': description,
      'location': location,
    };
    final sever = '${Server.setupdatepost}/$idpost';
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

  clearPostInfo() async {
    locationTextEditingController.clear();
    descriptionTextEditingController.clear();
    Navigator.pop(context);
    setState(() {
      file = File('');
      s = 'notok';
    });
  }

  Widget Commentpage(String postid) {
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
            leading: IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: Colors.black,
              ),
              onPressed: () {
                setState(() {
                  loadcomment = false;
                });
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
          body: buildPage(postid),
        ));
  }

  Widget buildPage(String postid) {
    return Column(
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
              log('full name in comment: ' + _user.fullname);
              comment(
                  postid, _user.fullname, _user.photo, _commentController.text);
              _commentController.clear();
            },
            borderSide: BorderSide.none,
            child: Text("Post"),
          ),
        ),
      ],
    );
  }

  Widget buildComments(String idpost) {
    getComment(idpost);
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

  islike(String postid, int like, String username, String photo,
      int islike) async {
    int islikes = (islike == 1 ? 2 : 1);
    if (like > 0) {
      if (islikes == 1) {
        like = like - 1;
      } else {
        like = like + 1;
      }
    } else {
      if (islikes == 2) {
        like = like + 1;
      }
    }
    print(islike);
    var data = {
      'user': {'username': username, 'photo': photo},
      'islike': islike == 1 ? 2 : 1,
      'like': like
    };
    final id = postid;
    final sever = Server.setupdatepost;
    String url = '$sever/$id';
    print(url);
    final http.Response response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(data));
    print(response.body);
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
  }

  List<Comment> _comments;

  getComment(String idpost) {
    svComments.getComment(idpost).then((comments) async {
      await Future.delayed(Duration(seconds: 5));
      log('dang load comment nek');
      if (comments != null) {
        setState(() {
          _comments = comments;
          loadcomment = true;
          _isLoaderVisible = context.loaderOverlay.visible;
        });
        if (_isLoaderVisible) {
          context.loaderOverlay.hide();
        }
        log('dang load xong comment roi  nek');
        log('loadcoment : $loadcomment  ');
      }
      return loadcomment;
    });
  }

  Widget getBody(size) {
    getpost();
    return ListView(
      children: [
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.only(top: 5, left: 5, right: 5),
          child: Row(
              children: List.generate(stories.length, (index) {
            return Padding(
              padding: const EdgeInsets.all(3.0),
              child: Container(
                width: 80,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        stories[index]['isStory']
                            ? Container(
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient:
                                        LinearGradient(colors: bgStoryColors)),
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Container(
                                    height: 70,
                                    width: 70,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            width: 2, color: bgWhite),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                stories[index]['imageUrl']),
                                            fit: BoxFit.cover)),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Container(
                                  height: 70,
                                  width: 70,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(width: 1, color: bgGrey),
                                      image: DecorationImage(
                                          image: NetworkImage(
                                              stories[index]['imageUrl']),
                                          fit: BoxFit.cover)),
                                ),
                              ),
                        stories[index]['isAdd']
                            ? Positioned(
                                right: 5,
                                bottom: 0,
                                child: Container(
                                  height: 20,
                                  width: 20,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle, color: primary),
                                  child: Center(
                                    child: Icon(
                                      Icons.add,
                                      color: bgWhite,
                                      size: 20,
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                      ],
                    ),
                    SizedBox(height: 5),
                    Text(
                      stories[index]['username'],
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            );
          })),
        ),
        Divider(),
        Column(
            children: List.generate(_posts.length, (index) {
          Post post = _posts[index];
          // print(_comments.length);
          TextEditingController commentcontroller = new TextEditingController();
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 15, right: 15, bottom: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(colors: bgStoryColors),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(1.3),
                              child: Container(
                                height: 35,
                                width: 35,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border:
                                        Border.all(width: 1, color: bgWhite),
                                    image: DecorationImage(
                                        image: NetworkImage(post.user.photo),
                                        fit: BoxFit.cover)),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            post.user.username,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(
                          FontAwesome.ellipsis_v,
                          size: 15,
                          color: Colors.black,
                        ),
                        onPressed: () => takepost(
                            context,
                            post.linkphoto,
                            post.body,
                            post.location,
                            post.user.username,
                            post.user.photo,
                            post.id),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 400,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: NetworkImage(post.linkphoto),
                          fit: BoxFit.cover)),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 8, right: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            splashRadius: 15,
                            icon: post.islike == 2
                                ? SvgPicture.asset(
                                    "assets/images/heart_red.svg",
                                    width: 25,
                                    height: 25,
                                  )
                                : SvgPicture.asset(
                                    "assets/images/heart.svg",
                                    width: 25,
                                    height: 25,
                                  ),
                            // icon: post.islike == 2
                            //     ? SvgPicture.asset(
                            //         "assets/images/heart_red.svg",
                            //         width: 25,
                            //         height: 25,
                            //       )
                            //     : SvgPicture.asset(
                            //         "assets/images/heart.svg",
                            //         width: 25,
                            //         height: 25,
                            //       ),
                            onPressed: () {
                              setState(() {
                                islike(post.id, post.like, post.user.username,
                                    post.user.photo, post.islike);
                                post.islike = post.islike == 2 ? 1 : 2;
                              });
                            },
                          ),
                          IconButton(
                            splashRadius: 15,
                            icon: Icon(FontAwesome.comment_o, size: 25),
                            onPressed: () {
                              print('loadcomment trong inpress $loadcomment');
                              getComment(post.postid);
                              Navigator.pushNamed(
                                  context, '/comment',
                                  arguments: (post.postid));
                            },
                          ),
                          IconButton(
                            splashRadius: 15,
                            icon: SvgPicture.asset(
                              "assets/images/share.svg",
                              width: 20,
                              height: 20,
                            ),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      IconButton(icon: Icon(Feather.bookmark), onPressed: () {})
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 15, right: 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${post.like - 1} likes',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 5),
                      Text.rich(TextSpan(
                        children: [
                          TextSpan(
                              text: post.user.username,
                              style: TextStyle(fontWeight: FontWeight.bold)),
                          TextSpan(
                              text: post.body, style: TextStyle(height: 1.5))
                        ],
                      )),
                      SizedBox(height: 8),
                      SizedBox(height: 8),
                      SizedBox(height: 5),
                      Text(
                        post.datetime.toString(),
                        style: TextStyle(fontSize: 12, color: textGrey),
                      )
                    ],
                  ),
                )
              ],
            ),
          );
        })),
      ],
    );
  }
}
