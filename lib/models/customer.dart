// To parse this JSON data, do
//
//     final customer = customerFromJson(jsonString);

import 'dart:convert';

Customer customerFromJson(String str) => Customer.fromJson(json.decode(str));

String customerToJson(Customer data) => json.encode(data.toJson());

class Customer {
  Customer({
    this.success,
    this.statusCode,
    this.code,
    this.message,
    this.data,
  });

  bool success;
  int statusCode;
  String code;
  String message;
  Data data;

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        success: json["success"],
        statusCode: json["statusCode"],
        code: json["code"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
        "success": success,
        "statusCode": statusCode,
        "code": code,
        "message": message,
        "data": data.toJson(),
      };
}

class Data {
  Data({
    this.token,
    this.id,
    this.email,
    this.nicename,
    this.firstName,
    this.lastName,
    this.displayName,
  });

  String token;
  int id;
  String email;
  String nicename;
  String firstName;
  String lastName;
  String displayName;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        token: json["token"],
        id: json["id"],
        email: json["email"],
        nicename: json["nicename"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        displayName: json["displayName"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "id": id,
        "email": email,
        "nicename": nicename,
        "firstName": firstName,
        "lastName": lastName,
        "displayName": displayName,
      };
}
