// import 'dart:ffi';

import 'package:e_com/database/cart_store.dart';
import 'package:e_com/pages/homePage.dart';
import 'package:e_com/provider/cartProvider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  await Hive.initFlutter();
  Hive.registerAdapter(CartAdapter());
  await Hive.openBox<Cart>("cart");
  await Hive.openBox("checkout");
  await Hive.openBox("customer");
  runApp(
    // ignore: missing_required_param
    ChangeNotifierProvider<CartProvider>(
        create: (context) => CartProvider(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(primaryColor: Colors.orange),
      home: HomePage(),
    );
  }
}
