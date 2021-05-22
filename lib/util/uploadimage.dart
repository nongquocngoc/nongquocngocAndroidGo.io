// To parse this JSON data, do
//
//     final data = dataFromJson(jsonString);

import 'dart:convert';

Data dataFromJson(String str) => Data.fromJson(json.decode(str));

String dataToJson(Data data) => json.encode(data.toJson());

class Data {
  Data({
    this.data,
    this.success,
    this.status,
  });

  DataClass data;
  bool success;
  int status;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    data: DataClass.fromJson(json["data"]),
    success: json["success"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "data": data.toJson(),
    "success": success,
    "status": status,
  };
}

class DataClass {
  DataClass({
    this.id,
    this.title,
    this.urlViewer,
    this.url,
    this.displayUrl,
    this.size,
    this.time,
    this.expiration,
    this.image,
    this.thumb,
    this.deleteUrl,
  });

  String id;
  String title;
  String urlViewer;
  String url;
  String displayUrl;
  int size;
  String time;
  String expiration;
  Image image;
  Image thumb;
  String deleteUrl;

  factory DataClass.fromJson(Map<String, dynamic> json) => DataClass(
    id: json["id"],
    title: json["title"],
    urlViewer: json["url_viewer"],
    url: json["url"],
    displayUrl: json["display_url"],
    size: json["size"],
    time: json["time"],
    expiration: json["expiration"],
    image: Image.fromJson(json["image"]),
    thumb: Image.fromJson(json["thumb"]),
    deleteUrl: json["delete_url"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "url_viewer": urlViewer,
    "url": url,
    "display_url": displayUrl,
    "size": size,
    "time": time,
    "expiration": expiration,
    "image": image.toJson(),
    "thumb": thumb.toJson(),
    "delete_url": deleteUrl,
  };
}

class Image {
  Image({
    this.filename,
    this.name,
    this.mime,
    this.extension,
    this.url,
  });

  String filename;
  String name;
  String mime;
  String extension;
  String url;

  factory Image.fromJson(Map<String, dynamic> json) => Image(
    filename: json["filename"],
    name: json["name"],
    mime: json["mime"],
    extension: json["extension"],
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "filename": filename,
    "name": name,
    "mime": mime,
    "extension": extension,
    "url": url,
  };
}
