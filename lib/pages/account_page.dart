import 'dart:developer';
import 'package:doanandroid/pages/EditProfile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:doanandroid/theme/colors.dart';
import 'package:doanandroid/util/user.dart';
import 'package:doanandroid/util/posts.dart';
import 'package:doanandroid/util/services.dart';
import 'package:doanandroid/pages/login.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Post> _posts;
User _user;

class AccountPage extends StatefulWidget {
  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  int selectedIndex = 0;
  bool loadings = false;

  void initState() {
    super.initState();
    Services.getPosts().then((posts) {
      setState(() {
        _posts = posts;
        loadings = true;
      });
    });
    Profile.getUser().then((user) {
      setState(() {
        _user = user;
        loadings = true;
      });
    });
  }


  getuser() {
    Profile.getUser().then((user) {
      _user = user;
      loadings = true;
      log(_user.id.toString());
    });
  }

  getpost(String username) {
    Services.getPostsbyusername(username).then((posts) {
      _posts = posts;
      loadings = true;
      print('reload in account page');
      return _posts;
    });
  }

  @override
  Widget build(BuildContext context) {
    getuser();
    getpost(_user.id);
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
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Feather.lock,
                    size: 18,
                  ),
                  SizedBox(width: 10),
                  Text(
                    _user.username,
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                ],
              ),
              Row(
                children: [
                  IconButton(
                    splashRadius: 15,
                    icon: Icon(AntDesign.plus),
                    onPressed: () {},
                  ),
                  IconButton(
                    splashRadius: 15,
                    icon: Icon(FontAwesome.bars),
                    onPressed: () async {
                      logOut(context);
                      final prefs = await SharedPreferences.getInstance();
                      prefs.setString("sessionuser", '');
                      print('day la fress logout: ' + prefs.getString("sessionuser"));
                      },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  logOut(mContext) {
    return showDialog(
        context: mContext,
        builder: (context) {
          return SimpleDialog(
            children: [
              SimpleDialogOption(
                child: Text(
                  "LogOut",
                  style: TextStyle(
                    color: Colors.black,
                  ),
                ),
                onPressed: () async {
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/login', ModalRoute.withName('/login'));
                },
              ),
            ],
          );
        });
  }

  Widget getBody(size) {
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: (size.width - 20) * 0.3,
                    child: Stack(
                      children: [
                        Container(
                          height: 100,
                          width: 100,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(width: 1, color: bgGrey),
                              image: DecorationImage(
                                  image: NetworkImage(_user.photo == null
                                      ? "err"
                                      : _user.photo),
                                  fit: BoxFit.cover)),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 25,
                          child: Container(
                            height: 25,
                            width: 25,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: primary,
                                border: Border.all(width: 1, color: bgWhite)),
                            child: Center(
                              child: Icon(Icons.add, color: bgWhite),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: (size.width - 20) * 0.7,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text(
                              (_user.post.length - 1).toString(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Posts",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                             (_user.follower.length - 1).toString(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Follwers",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            Text(
                             (_user.following.length - 1).toString(),
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Following",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  height: 1.5),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 15),
              Text(_user.fullname == null ? "errName" : _user.fullname),
              Text(_user.profile == null ? "errProfile" : _user.profile),
              SizedBox(height: 15),
              Container(
                height: 35,
                width: (size.width - 20),
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: bgGrey),
                  borderRadius: BorderRadius.circular(5),
                  color: bgLightGrey,
                ),
                child: RaisedButton(
                    color: Colors.white,
                    child: Text("Edit Profile"),
                    onPressed: () => Navigator.push(
                        context,
                        new MaterialPageRoute(
                            builder: (context) => new EditProfile()))),
              ),
              SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Story Highlights",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  Icon(FontAwesome.angle_down, size: 20)
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: 15),
        Container(
          height: 0.5,
          width: size.width,
          decoration: BoxDecoration(color: bgGrey.withOpacity(0.8)),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Container(
                width: (size.width * 0.5),
                child: IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    FontAwesome.th,
                    color: selectedIndex == 0
                        ? textBlack
                        : textBlack.withOpacity(0.5),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedIndex = 0;
                    });
                  },
                ),
              ),
              Container(
                width: (size.width * 0.5),
                child: IconButton(
                  splashRadius: 20,
                  icon: Icon(
                    FontAwesome.id_badge,
                    color: selectedIndex == 1
                        ? textBlack
                        : textBlack.withOpacity(0.5),
                  ),
                  onPressed: () {
                    setState(() {
                      selectedIndex = 1;
                    });
                  },
                ),
              ),
            ],
          ),
        ),
        Column(
          children: [
            Row(
              children: [
                Container(
                  height: 1,
                  width: (size.width * 0.5),
                  decoration: BoxDecoration(
                      color: selectedIndex == 0 ? bgDark : Colors.transparent),
                ),
                Container(
                  height: 1,
                  width: (size.width * 0.5),
                  decoration: BoxDecoration(
                      color: selectedIndex == 1 ? bgDark : Colors.transparent),
                ),
              ],
            ),
            Container(
              height: 0.5,
              width: size.width,
              decoration: BoxDecoration(color: bgGrey.withOpacity(0.8)),
            ),
          ],
        ),
        SizedBox(height: 3),
        IndexedStack(
          index: selectedIndex,
          children: [
            getImages(size),
            getImageWithTags(size),
          ],
        ),
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
          //controller: bioController,
          decoration: InputDecoration(
            hintText: "Update Bio",
            //errorText: _bioValid ? null : "Bio too long",
          ),
        )
      ],
    );
  }
}

Widget getImages(size) {
  return Wrap(
      direction: Axis.horizontal,
      spacing: 3,
      runSpacing: 3,
      children:
          List.generate(_posts.length, (index) {
        Post post = _posts[index];
        return Container(
          height: 150,
          width: (size.width - 6) / 3,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(post.linkphoto), fit: BoxFit.cover)),
        );
      }));
}

Widget getImageWithTags(size) {
  return Wrap(
      direction: Axis.horizontal,
      spacing: 3,
      runSpacing: 3,
      children:
          List.generate(_posts.length, (index) {
        Post post = _posts[index];
        return Container(
          height: 150,
          width: (size.width - 6) / 3,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(post.linkphoto), fit: BoxFit.cover)),
        );
      }));
}
