class Product{
  String name;
  num price;
  int count;

  Product({this.name,this.price,this.count});

  Product.formJson(Map<String, dynamic> json)
  : name = json["Name"],
    price = json["Price"],
    count = json["Count"];
}
// To parse this JSON data, do
//
//     final productPost = productPostFromJson(jsonString);
