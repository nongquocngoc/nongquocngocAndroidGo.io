import 'package:http/http.dart' as http;
import 'package:doanandroid/util/posts.dart';
import 'package:doanandroid/util/server.dart';

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