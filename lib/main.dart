import 'package:flutter/material.dart';
import 'package:golangproject/productPost.dart';
import 'package:http/http.dart' as http;
import 'package:golangproject/productModel.dart';
import 'productModel.dart';
import 'dart:convert' as convert;
import 'dart:async';

void main() {
  runApp(AppDemo());
}

class AppDemo extends StatefulWidget {
  AppDemo({Key key}) : super(key: key);

  @override
  _AppDemoState createState() => _AppDemoState();
}

class _AppDemoState extends State<AppDemo> {
  double fetchCountPercentage = 20.0;
  int ok(int price, int count){
    var _p = price;
    var _c = count;
    return _p+_c;
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.white,
            body: SizedBox.expand(
                child: Stack(
              children: [
                FutureBuilder<List<Product>>(
                  future: fetchFromServer(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(
                            "${snapshot.error}, style: TextStyle(color: Colors.red)"),
                      );
                    }
                    if (snapshot.hasData) {
                      return ListView.builder(
                        itemCount: snapshot.data.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                              child: ListTile(
                            title: Text(snapshot.data[index].name),
                            subtitle: Text(
                                "Count: ${snapshot.data[index].count} \t Price: ${snapshot.data[index].price}"),
                            onTap: () {
                              setState(() {
                                snapshot.data[index].count = 1;
                                snapshot.data[index].price = 2;
                              });
                            },
                          ));
                        },
                      );
                    }
                  },
                ),
                Positioned(
                    bottom: 5,
                    right: 5,
                    child: Slider(
                      value: fetchCountPercentage,
                      min: 0,
                      max: 100,
                      divisions: 10,
                      label: fetchCountPercentage.toString(),
                      onChanged: (double value) {
                        setState(() {
                          fetchCountPercentage = value;
                        });
                      },
                    ))
              ],
            ))));
  }

  Future<List<Product>> fetchFromServer() async {
    var url = "http://67b1530f32f2.ngrok.io/products/$fetchCountPercentage";
    var response = await http.get(Uri.parse(url));

    List<Product> productlist = [];
    if (response.statusCode == 200) {
      var productMap = convert.jsonDecode(response.body);
      for (final item in productMap) {
        productlist.add(Product.formJson(item));
      }
    }
    return productlist;
  }
}

class onchange extends StatefulWidget {
  onchange({Key key}) : super(key: key);

  @override
  _onchange createState() => _onchange();
}

Future<ProductPost> createUser(String name, int price) async {
  final String url = ("http://67b1530f32f2.ngrok.io/products/$price");
  final response =
      await http.post(Uri.parse(url), body: {"Name": name, "Price": price});

  if (response.statusCode == 201) {
    final String responString = response.body;
    return productPostFromJson(responString);
  } else {
    return null;
  }
}


class _onchange extends State<onchange> {
  ProductPost _user;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController JobController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Container(
        padding: EdgeInsets.all(32),
        child: Column(
          children: <Widget>[
            TextField(
              controller: nameController,
            ),
            TextField(
              controller: JobController,
            ),
            SizedBox(
              height: 32,
            ),
            _user == null ? Container() : Text("The user ${_user.price}")
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(

        onPressed: () async {
          final String name = nameController.text;
          final int price = JobController.hashCode;

          final ProductPost user = await createUser(name, price);
          setState(() {
            _user = user;
          });
        },
      ),
    );
  }
}
