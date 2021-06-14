import 'package:doanandroid/util/comment.dart';
import 'package:http/http.dart' as http;
import 'package:doanandroid/util/posts.dart';
import 'package:doanandroid/util/server.dart';
import 'package:doanandroid/util/user.dart';
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Services {
  static const String url = Server.setpost;
  static Future<List<Post>> getPosts() async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<Post> posts = postFromJson(response.body);
        return posts;
      } else {
        return List<Post>();
      }
    } catch (e) {
      return List<Post>();
    }
  }
  static Future<List<Post>> getPostsbyusername(String username) async {
    try {
      final response = await http.get(Uri.parse('$url/$username'));
      if (response.statusCode == 200) {
        final List<Post> posts = postFromJson(response.body);
        return posts;
      } else {
        return List<Post>();
      }
    } catch (e) {
      return List<Post>();
    }
  }
}

class svComments {
  static Future<List<Comment>> getComment(String postid) async {
    String id = postid;
    String url = '${Server.getcomment}/$id';
    print(url);
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final List<Comment> comment = commentFromJson(response.body);
        return comment;
      } else {
        return List<Comment>();
      }
    } catch (e) {
      return List<Comment>();
    }
  }
}


class Register {
  static String url = Server.setregister;
  static var ok;
  static register(String fullname, String email, String username,
      String password) async {
    print(url);
    final _fullname = fullname.toString();
    final _email = email.toString();
    final _username = username.toString();
    final _password = password.toString();
    var data = {
      'username': _username,
      'email': _email,
      'fullname': _fullname,
      'password': _password,
      'post': [""],
      'follower': [""],
      'following': [""]
    };
    final http.Response response = await http.post(Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: json.encode(data));
    if (response.statusCode == 200) {
      ok = 1;
      print(1);
      return ok;
    } else if (response.statusCode == 401) {
      ok = 0;
      print(0);
      return ok;
    }
  }
}

class Profile{
  static Future<User> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.getString("sessionuser");
    var s = Server.setuser;
    var url = '$s/${prefs.getString("sessionuser")}';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final User users = userFromJson(response.body);
        return users;
      } else {
        return User();
      }
    } catch (e) {
      return User();
    }
  }
}


// class Slogin {
//   //
//   static const String url = 'http://b10803edd97b.ngrok.io/login';
//   static Future<User> getUser(String username, String password) async {
//     var _username = username;
//     var _password = password;
//     try {
//       var data = {'username': _username, 'password': _password};
//       final response = await http.post(Uri.parse(url),
//           headers: <String, String>{
//             'Content-Type': 'application/json',
//           },
//           body: json.encode(data));
//       if (response.statusCode == 200) {
//         final User users = userFromJson(response.body.toString());
//         return users;
//       } else {
//         return null;
//       }
//     } catch (e) {
//       return null;
//     }
//   }
// }