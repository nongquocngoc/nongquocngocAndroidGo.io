import 'dart:developer';
import 'package:doanandroid/util/posts.dart';
import 'package:flutter/material.dart';
import 'package:doanandroid/util/server.dart';
import 'package:doanandroid/util/services.dart';
import 'package:doanandroid/util/user.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:doanandroid/theme/colors.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Post> _posts;
  User _user;
  bool isloading = false;
  int selectedIndex = 0;
  bool _isLoaderVisible = false;
  TextEditingController findcontrolelr = TextEditingController();
  var find = 'notok';

  findservice(String name) async {
    String url = '${Server.finduser}/$name';
    log(url);
    log('find truoc if $find');
    final response = await http.post(Uri.parse(url));
    if (response.statusCode == 200) {
      await Future.delayed(Duration(seconds: 1));
      User user = userFromJson(response.body);
      setState(() {
        _isLoaderVisible = context.loaderOverlay.visible;
        _user = user;
        find = 'ok';
      });
      if (_isLoaderVisible) {
        context.loaderOverlay.hide();
      }
      return _user;
    } else {
      setState(() {
        _isLoaderVisible = context.loaderOverlay.visible;
        find = 'notok';
      });
      if (_isLoaderVisible) {
        context.loaderOverlay.hide();
      }
    }
    log('find sau if $find');
    log('status code ${response.statusCode}');
    return _user;
  }

  getpost(String username) {
    Services.getPostsbyusername(username).then((posts) {
      setState(() {
        _posts = posts;
        isloading = true;
      });
      print('dang reload account ben search ne, loading = $isloading');
    });
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

  showUser() {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: getAppBaruser(),
      body: getBodyuser(size),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: getBody(),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;
    return SingleChildScrollView(
        child: Column(
      children: <Widget>[
        SafeArea(
          child: Row(
            children: <Widget>[
              Divider(
                height: 75,
              ),
              SizedBox(
                width: 15,
              ),
              Container(
                // padding:,
                width: size.width - 30,
                height: 45,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey),
                child: TextField(
                  controller: findcontrolelr,
                  onChanged: (text) {
                    context.loaderOverlay.show();
                    setState(() {
                      findservice(text);
                    });
                  },
                  decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: findcontrolelr.clear,
                        icon: Icon(
                          Icons.clear,
                          color: Colors.black,
                        ),
                      ),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black.withOpacity(0.9),
                      )),
                  style: TextStyle(color: Colors.black.withOpacity(0.9)),
                  cursorColor: Colors.black.withOpacity(1),
                ),
              )
            ],
          ),
        ),
        find != 'ok' ? noresult() : ikwel(),
      ],
    ));
  }

  Widget ikwel() {
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
        child: InkWell(
          onTap: () async{
            getpost(_user.id);
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => loading() ));
            await Future.delayed(Duration(seconds: 3));
            Navigator.pop(context);
            Navigator.push(
                context, MaterialPageRoute(builder: (_) => showUser()));
          },
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
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(width: 1, color: Colors.grey),
                          image: DecorationImage(
                              image: NetworkImage(_user.photo),
                              fit: BoxFit.cover)),
                    ),
                  ),
                ),
              ),
              Container(
                child: Column(
                  children: [
                    Text(
                      '${_user.username == null ? 0 : _user.username}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                      ),
                    ),
                    Text(
                      '${_user.fullname == null ? 0 : _user.fullname}',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      'Co ${_user.follower == null ? 0 : _user.follower.length} nguoi theo doi',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }

  Widget noresult() {
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
        child: Container(
          child: Text('NO Result'),
        ));
  }

  Widget getAppBaruser() {
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
                    _user.username == null ? "err" : _user.username,
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
                    onPressed: () {},
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getBodyuser(size) {
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
                              _user.post.length == null
                                  ? 1
                                  : (_user.post.length - 1).toString(),
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
                              _user.follower.length.toString() == null
                                  ? 1
                                  : _user.follower.length.toString(),
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
                              _user.following.length.toString() == null
                                  ? 1
                                  : _user.following.length.toString(),
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

  Widget getImages(size) {
    return Wrap(
        direction: Axis.horizontal,
        spacing: 3,
        runSpacing: 3,
        children:
            List.generate(_posts.length == null ? 1 : _posts.length, (index) {
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
            List.generate(_posts.length == null ? 1 : _posts.length, (index) {
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
}
