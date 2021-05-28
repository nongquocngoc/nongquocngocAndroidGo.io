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
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Post> _posts;
  bool loadings = false;

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

   getpost() {
    Services.getPosts().then((posts) {
        _posts = posts;
        loadings = true;
        print('reload homepage');
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

  islike(String postid, int like, String username, String photo,
      int islike) async {
    int islikes = (islike == 1 ? 2 : 1);
    if (like > 0) {
      if (islikes == 1) {
        like = like - 1;
      } else {
        like = like + 1;
      }
    }
    print(islikes);
    var data = {
      'user': {'username': username, 'photo': photo},
      'islike': islikes,
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

  Widget getBody(size) {
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
                      Icon(FontAwesome.ellipsis_v, size: 15),
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
                            onPressed: ()  {
                              setState(() {
                                islike(post.id, post.like, post.user.username,
                                    post.user.photo, post.islike);
                                post.islike = post.islike ==  2 ? 1 : 2;
                              });
                            },
                          ),
                          IconButton(
                            splashRadius: 15,
                            icon: Icon(FontAwesome.comment_o, size: 25),
                            onPressed: () {},
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
                        '${post.like} likes',
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
                      // Text(
                      //   post.comment[1],
                      //   style: TextStyle(color: textGrey),
                      // ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            width: (size.width - 30) * 0.7,
                            child: Row(
                              children: [
                                Container(
                                  height: 28,
                                  width: 28,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border:
                                          Border.all(width: 1, color: bgGrey),
                                      image: DecorationImage(
                                          image: NetworkImage(post.user.photo),
                                          fit: BoxFit.cover)),
                                ),
                                Container(
                                  height: 25,
                                  width: (size.width - 70) * 0.7,
                                  child: Padding(
                                    padding: EdgeInsets.only(
                                        top: 10, left: 10, right: 10),
                                    child: TextField(
                                      cursorColor: textBlack.withOpacity(0.5),
                                      decoration: InputDecoration(
                                          border: InputBorder.none,
                                          hintText: "Add a comment",
                                          hintStyle: TextStyle(
                                              fontSize: 14,
                                              color:
                                                  textBlack.withOpacity(0.5))),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: (size.width - 30) * 0.3,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text("🥰"),
                                SizedBox(width: 8),
                                Text("😎"),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.add_circle_outline,
                                  size: 20,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
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