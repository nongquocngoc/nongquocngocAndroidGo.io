// To parse this JSON data, do
//
//     final productPost = productPostFromJson(jsonString);

import 'dart:convert';

ProductPost productPostFromJson(String str) => ProductPost.fromJson(json.decode(str));

String productPostToJson(ProductPost data) => json.encode(data.toJson());

class ProductPost {
  ProductPost({
    this.name,
    this.price,
    this.count,
  });

  String name;
  int price;
  int count;

  factory ProductPost.fromJson(Map<String, dynamic> json) => ProductPost(
    name: json["Name"],
    price: json["Price"],
    count: json["Count"],
  );

  Map<String, dynamic> toJson() => {
    "Name": name,
    "Price": price,
    "Count": count,
  };
}