import 'dart:convert';
import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_com/database/cart_store.dart';
import 'package:e_com/models/product.dart';
import 'package:e_com/pages/addressPage.dart';
import 'package:e_com/provider/cartProvider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

class CartPage extends StatefulWidget {
  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> with TickerProviderStateMixin {
  double total = 0;

  AnimationController _animationController;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));
  }

  @override
  Widget build(BuildContext context) {
    final cartTotal = Provider.of<CartProvider>(context);
    // cartTotal.getTotal();
    return Scaffold(
      backgroundColor: Colors.white,
      bottomSheet: BottomSheet(
        animationController: _animationController,
        onClosing: () {},
        builder: (context) {
          return Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 8)
              ],
              color: Colors.white,
            ),
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  padding: EdgeInsets.only(left: 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Total",
                        style:
                            TextStyle(color: Colors.orange[700], fontSize: 16),
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      ValueListenableBuilder(
                        valueListenable: Hive.box<Cart>("cart").listenable(),
                        builder: (context, value, child) {
                          return Text(
                            "Rs." + cartTotal.total.toString(),
                            style: TextStyle(
                                color: Colors.orange[700],
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          );
                        },
                      )
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: FlatButton(
                    padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                    color: Colors.orange,
                    child: Text("Proceed"),
                    onPressed: cartTotal.cartList.length == 0.0
                        ? null
                        : () {
                            cartTotal.getTotal();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (c) => AddressPage()));
                          },
                  ),
                )
              ],
            ),
          );
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.only(top: 30, left: 15, bottom: 20),
                child: Row(
                  children: [
                    BackButton(),
                    Text(
                      "My Cart",
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Container(
                  child: ValueListenableBuilder(
                    valueListenable: Hive.box<Cart>("cart").listenable(),
                    builder: (context, value, child) {
                      // print(value.values);
                      value.values.forEach((e) => print(e.count));
                      return value.length == 0
                          ? Container(
                              margin: EdgeInsets.only(top: 100),
                              child: Center(
                                child: Text("No items added"),
                              ),
                            )
                          : Container(
                              padding: EdgeInsets.only(bottom: 100),
                              child: Column(
                                children: value.values.map<Widget>((e) {
                                  Product prod = Product.fromJson(json.decode(
                                      json.encode(e.product).toString()));
                                  return Container(
                                    padding:
                                        EdgeInsets.only(left: 15, right: 10),
                                    margin: EdgeInsets.symmetric(vertical: 15),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () {},
                                          child: CachedNetworkImage(
                                            height: 130,
                                            width: 130,
                                            imageUrl: prod.images[0].src,
                                            placeholder: (context, url) =>
                                                CircularProgressIndicator(),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.error),
                                          ),
                                        ),
                                        SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(
                                                prod.name,
                                                style: TextStyle(
                                                    fontSize: 18,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 10),
                                              child: Text(
                                                "Rs." + prod.salePrice,
                                                style: TextStyle(
                                                    color: Colors.orange[700],
                                                    fontSize: 24,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              children: [
                                                IconButton(
                                                  color: Colors.blue,
                                                  onPressed: () {
                                                    e.count -= 1;
                                                    if (e.count == 0) {
                                                      e.delete();
                                                    } else {
                                                      e.save();
                                                    }
                                                    cartTotal.getTotal();
                                                  },
                                                  iconSize: 32,
                                                  icon: Icon(Icons.remove),
                                                ),
                                                Text(e.count.toString()),
                                                IconButton(
                                                  color: Colors.blue,
                                                  iconSize: 26,
                                                  onPressed: () {
                                                    e.count += 1;
                                                    e.save();
                                                    cartTotal.getTotal();
                                                  },
                                                  icon: Icon(Icons.add),
                                                ),
                                              ],
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                              // child: ListView.builder(
                              //   shrinkWrap: true,
                              //   physics: NeverScrollableScrollPhysics(),
                              //   itemCount: value.length,
                              //   itemBuilder: (context, index) {
                              //     if (value.get(index) == null) {
                              //       return Container();
                              //     }
                              //     Product prod = Product.fromJson(json.decode(json
                              //         .encode(value.get(index).product)
                              //         .toString()));
                              //     double itemtotal = (double.parse(prod.salePrice) *
                              //         value.get(index).count);
                              //     total = total + itemtotal;
                              //     return Container(
                              //       padding: EdgeInsets.only(left: 15, right: 10),
                              //       margin: EdgeInsets.symmetric(vertical: 15),
                              //       child: Row(
                              //         crossAxisAlignment: CrossAxisAlignment.start,
                              //         children: [
                              //           CachedNetworkImage(
                              //             height: 130,
                              //             width: 130,
                              //             imageUrl: prod.images[0].src,
                              //             placeholder: (context, url) =>
                              //                 CircularProgressIndicator(),
                              //             errorWidget: (context, url, error) =>
                              //                 Icon(Icons.error),
                              //           ),
                              //           SizedBox(
                              //             width: 10,
                              //           ),
                              //           Column(
                              //             crossAxisAlignment:
                              //                 CrossAxisAlignment.start,
                              //             children: [
                              //               SizedBox(
                              //                 height: 20,
                              //               ),
                              //               Padding(
                              //                 padding:
                              //                     const EdgeInsets.only(left: 10),
                              //                 child: Text(
                              //                   prod.name,
                              //                   style: TextStyle(
                              //                       fontSize: 18,
                              //                       fontWeight: FontWeight.bold),
                              //                 ),
                              //               ),
                              //               SizedBox(
                              //                 height: 10,
                              //               ),
                              //               Padding(
                              //                 padding:
                              //                     const EdgeInsets.only(left: 10),
                              //                 child: Text(
                              //                   "Rs." + prod.salePrice,
                              //                   style: TextStyle(
                              //                       color: Colors.orange[700],
                              //                       fontSize: 24,
                              //                       fontWeight: FontWeight.bold),
                              //                 ),
                              //               ),
                              //               SizedBox(
                              //                 height: 10,
                              //               ),
                              //               Row(
                              //                 children: [
                              //                   IconButton(
                              //                     color: Colors.blue,
                              //                     onPressed: () {},
                              //                     iconSize: 32,
                              //                     icon: Icon(Icons.remove),
                              //                   ),
                              //                   Text("1"),
                              //                   IconButton(
                              //                     color: Colors.blue,
                              //                     iconSize: 26,
                              //                     onPressed: () {},
                              //                     icon: Icon(Icons.add),
                              //                   ),
                              //                 ],
                              //               )
                              //             ],
                              //           )
                              //         ],
                              //       ),
                              //     );
                              //   },
                              // ),
                            );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  ValueListenableBuilder<Box<Cart>> buildValueListenableBuilder() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Cart>("cart").listenable(),
      builder: (context, value, child) {
        print(json.encode(value.get(0).product));
        total = 0;
        return cartList(value);
      },
    );
  }

  ListView cartList(value) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: value.length,
      itemBuilder: (context, index) {
        Product prod = Product.fromJson(
            json.decode(json.encode(value.get(index).product).toString()));
        double itemtotal =
            (double.parse(prod.salePrice) * value.get(index).count);
        total = total + itemtotal;

        return Container(
          // color: Colors.red[50],
          margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  children: [
                    CachedNetworkImage(
                      height: 100,
                      width: 100,
                      imageUrl: prod.images[0].src,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(Icons.error),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          prod.name,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          itemtotal.toString(),
                          textAlign: TextAlign.left,
                          style:
                              TextStyle(fontSize: 18, color: Colors.amber[700]),
                        )
                      ],
                    )
                  ],
                ),
              ),
              Text(
                itemtotal.toString(),
                style: TextStyle(fontSize: 18, color: Colors.amber[700]),
              )
            ],
          ),
        );
      },
    );
  }
}
