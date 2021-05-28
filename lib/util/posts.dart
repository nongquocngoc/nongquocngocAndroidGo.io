// To parse this JSON data, do
//
//     final post = postFromJson(jsonString);

import 'dart:convert';

List<Post> postFromJson(String str) => List<Post>.from(json.decode(str).map((x) => Post.fromJson(x)));

String postToJson(List<Post> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Post {
  Post({
    this.id,
    this.user,
    this.body,
    this.linkphoto,
    this.islike,
    this.like,
    this.datetime,
    this.location,
    this.postid,
  });

  String id;
  Userpost user;
  String body;
  String linkphoto;
  int islike;
  int like;
  DateTime datetime;
  String location;
  String postid;

  factory Post.fromJson(Map<String, dynamic> json) => Post(
    id: json["_id"],
    user: Userpost.fromJson(json["user"]),
    body: json["body"],
    linkphoto: json["linkphoto"],
    islike: json["islike"],
    like: json["like"],
    datetime: DateTime.parse(json["datetime"]),
    location: json["location"],
    postid: json["postid"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "user": user.toJson(),
    "body": body,
    "linkphoto": linkphoto,
    "islike": islike,
    "like": like,
    "datetime": datetime.toIso8601String(),
    "location": location,
    "postid": postid,
  };
}

class Userpost {
  Userpost({
    this.username,
    this.photo,
  });

  String username;
  String photo;

  factory Userpost.fromJson(Map<String, dynamic> json) => Userpost(
    username: json["username"],
    photo: json["photo"],
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "photo": photo,
  };
}
