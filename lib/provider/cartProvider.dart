import 'dart:convert';

import 'package:e_com/database/cart_store.dart';
import 'package:e_com/models/product.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

class CartProvider with ChangeNotifier {
  double total = 0;
  List<Cart> cartList = [];
  CartProvider() {
    getTotal();
  }
  void getTotal() {
    var items = Hive.box<Cart>("cart").values;
    total = 0;
    cartList.clear();
    items.forEach((element) {
      Product p = Product.fromJson(
          json.decode(json.encode(element.product).toString()));
      total += element.count * double.parse(p.salePrice);
      cartList.add(element);
    });
    notifyListeners();
    // Hive.box('cart');
  }
}
