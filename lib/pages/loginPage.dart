import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_com/models/customer.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:toast/toast.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  _doLogin() {
    print("Hello");
    Dio()
        .post(
      'https://coderapps.xyz/wp-json/jwt-auth/v1/token',
      data: {
        'username': "oswinjeromej@gmail.com",
        'password': 'ennadapasswordpoda'
      },
      options: Options(
        headers: {
          HttpHeaders.contentTypeHeader: "application/x-www-form-urlencoded"
        },
      ),
    )
        .then((value) {
      // TODO: Handle Server error
      if (value.data['statusCode'] == 200) {
        Customer customer = Customer.fromJson(value.data);
        print(customer.code);
        var customerBox = Hive.box('customer');
        customerBox.put("data", customer.toJson());
        customerBox.put("name", customer.data.displayName);
        customerBox.put("email", customer.data.email);
        customerBox.put("token", customer.data.token);
        customerBox.put("id", customer.data.id);

        Navigator.pop(context);
      } else {
        Toast.show("Login Failed", context);
      }
    }).catchError((onError) {
      print('error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            _doLogin();
          },
          child: Text("PErform login"),
        ),
      ),
    );
  }
}
