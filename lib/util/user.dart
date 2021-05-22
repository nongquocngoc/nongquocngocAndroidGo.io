// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  User({
    this.id,
    this.username,
    this.fullname,
    this.email,
    this.token,
    this.createat,
    this.refreshtoken,
    this.userid,
    this.photo,
    this.lastlogin,
    this.profile,
    this.follower,
    this.following,
    this.post,
  });

  String id;
  String username;
  String fullname;
  String email;
  String token;
  DateTime createat;
  String refreshtoken;
  String userid;
  String photo;
  DateTime lastlogin;
  String profile;
  List<String> follower;
  List<String> following;
  List<String> post;

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    username: json["username"],
    fullname: json["fullname"],
    email: json["email"],
    token: json["token"],
    createat: DateTime.parse(json["createat"]),
    refreshtoken: json["refreshtoken"],
    userid: json["userid"],
    photo: json["photo"],
    lastlogin: DateTime.parse(json["lastlogin"]),
    profile: json["profile"],
    follower: List<String>.from(json["follower"].map((x) => x)),
    following: List<String>.from(json["following"].map((x) => x)),
    post: List<String>.from(json["post"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "username": username,
    "fullname": fullname,
    "email": email,
    "token": token,
    "createat": createat.toIso8601String(),
    "refreshtoken": refreshtoken,
    "userid": userid,
    "photo": photo,
    "lastlogin": lastlogin.toIso8601String(),
    "profile": profile,
    "follower": List<dynamic>.from(follower.map((x) => x)),
    "following": List<dynamic>.from(following.map((x) => x)),
    "post": List<dynamic>.from(post.map((x) => x)),
  };
}
