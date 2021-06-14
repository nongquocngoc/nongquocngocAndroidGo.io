// To parse this JSON data, do
//
//     final comment = commentFromJson(jsonString);

import 'dart:convert';

List<Comment> commentFromJson(String str) => List<Comment>.from(json.decode(str).map((x) => Comment.fromJson(x)));

String commentToJson(List<Comment> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Comment {
  Comment({
    this.postid,
    this.user,
    this.detail,
    this.time,
  });

  String postid;
  Usercmt user;
  String detail;
  DateTime time;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
    postid: json["postid"],
    user: Usercmt.fromJson(json["user"]),
    detail: json["detail"],
    time: DateTime.parse(json["time"]),
  );

  Map<String, dynamic> toJson() => {
    "postid": postid,
    "user": user.toJson(),
    "detail": detail,
    "time": time.toIso8601String(),
  };
}

class Usercmt {
  Usercmt({
    this.username,
    this.photo,
  });

  String username;
  String photo;

  factory Usercmt.fromJson(Map<String, dynamic> json) => Usercmt(
    username: json["username"],
    photo: json["photo"],
  );

  Map<String, dynamic> toJson() => {
    "username": username,
    "photo": photo,
  };
}
