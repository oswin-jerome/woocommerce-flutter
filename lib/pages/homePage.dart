import 'dart:convert';

import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:e_com/database/cart_store.dart';
import 'package:e_com/helpers/WooService.dart';
import 'package:e_com/models/categories.dart';
import 'package:e_com/models/category.dart';
import 'package:e_com/pages/cartPage.dart';
import 'package:e_com/pages/loginPage.dart';
import 'package:e_com/provider/cartProvider.dart';
import 'package:e_com/widgets/ProductsGrid.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Category> _category = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCategories();
  }

  _getCategories() {
    WooService()
        .dio
        .get("https://coderapps.xyz/wp-json/wc/v3/products/categories",
            options:
                buildCacheOptions(Duration(minutes: 2), forceRefresh: false))
        .then((value) {
      var d = json.encode(value.data);
      for (var cat in json.decode(d)) {
        Category c = Category.fromJson(cat);
        print(c);
        setState(() {
          _category.add(c);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = Provider.of<CartProvider>(context);

    return DefaultTabController(
      initialIndex: 0,
      length: _category.length,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(260),
          child: AppBar(
            elevation: 0,
            backgroundColor: Colors.white,
            flexibleSpace: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: Icon(Icons.menu),
                          onPressed: () => null,
                        ),
                        Row(
                          children: [
                            Stack(
                              children: [
                                IconButton(
                                  icon: Icon(Icons.shopping_bag),
                                  onPressed: () {
                                    cartTotal.getTotal();
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CartPage(),
                                        ));
                                  },
                                  iconSize: 32,
                                ),
                                Positioned(
                                  bottom: 5,
                                  right: 10,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.pink,
                                    ),
                                    width: 20,
                                    height: 20,
                                    // padding: EdgeInsets.all(5),
                                    child: Center(
                                        child: ValueListenableBuilder(
                                      valueListenable:
                                          Hive.box<Cart>("cart").listenable(),
                                      builder: (context, value, child) {
                                        return Text(
                                          value.length.toString(),
                                          style: TextStyle(fontSize: 10),
                                        );
                                      },
                                    )),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (c) => LoginPage(),
                                    ));
                              },
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(
                                    'https://th.bing.com/th/id/OIP.wRtvON_8JKRQghdROw5QvQHaHa?w=170&h=180&c=7&o=5&dpr=1.15&pid=1.7'),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: RichText(
                      textAlign: TextAlign.start,
                      text: TextSpan(style: TextStyle(height: 1.3), children: [
                        TextSpan(
                          text: "Let's",
                          style: TextStyle(
                            color: Colors.orange.withOpacity(0.7),
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextSpan(
                          text: "\nGet Started !",
                          style: TextStyle(
                            color: Colors.orange,
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Center(
                    child: TabBar(
                      isScrollable: true,
                      indicatorColor: Colors.transparent,
                      labelColor: Colors.grey[800],
                      labelStyle: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      unselectedLabelColor: Colors.grey,
                      tabs: _category
                          .map((e) => Tab(
                                child: Text(e.name),
                              ))
                          .toList(),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: _category
              .map((e) => ProductsGrid(
                    cateID: e.id,
                  ))
              .toList(),
        ),
      ),
    );
  }
}
