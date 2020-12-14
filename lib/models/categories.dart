// To parse this JSON data, do
//
//     final categories = categoriesFromJson(jsonString);

import 'dart:convert';

List<Categories> categoriesFromJson(String str) =>
    List<Categories>.from(json.decode(str).map((x) => Categories.fromJson(x)));

String categoriesToJson(List<Categories> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Categories {
  Categories({
    this.id,
    this.name,
    this.slug,
    this.parent,
    this.description,
    this.display,
    this.image,
    this.menuOrder,
    this.count,
    this.links,
  });

  int id;
  String name;
  String slug;
  int parent;
  String description;
  String display;
  dynamic image;
  int menuOrder;
  int count;
  Links links;

  factory Categories.fromJson(Map<String, dynamic> json) => Categories(
        id: json["id"],
        name: json["name"],
        slug: json["slug"],
        parent: json["parent"],
        description: json["description"],
        display: json["display"],
        image: json["image"],
        menuOrder: json["menu_order"],
        count: json["count"],
        links: Links.fromJson(json["_links"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "slug": slug,
        "parent": parent,
        "description": description,
        "display": display,
        "image": image,
        "menu_order": menuOrder,
        "count": count,
        "_links": links.toJson(),
      };
}

class Links {
  Links({
    this.self,
    this.collection,
  });

  List<Collection> self;
  List<Collection> collection;

  factory Links.fromJson(Map<String, dynamic> json) => Links(
        self: List<Collection>.from(
            json["self"].map((x) => Collection.fromJson(x))),
        collection: List<Collection>.from(
            json["collection"].map((x) => Collection.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "self": List<dynamic>.from(self.map((x) => x.toJson())),
        "collection": List<dynamic>.from(collection.map((x) => x.toJson())),
      };
}

class Collection {
  Collection({
    this.href,
  });

  String href;

  factory Collection.fromJson(Map<String, dynamic> json) => Collection(
        href: json["href"],
      );

  Map<String, dynamic> toJson() => {
        "href": href,
      };
}
