import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio_http_cache/dio_http_cache.dart';
import 'package:e_com/helpers/WooService.dart';
import 'package:e_com/models/product.dart';
import 'package:e_com/pages/productDetails.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:palette_generator/palette_generator.dart';
// import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ProductsGrid extends StatefulWidget {
  int cateID;
  ProductsGrid({this.cateID});
  @override
  _ProductsGridState createState() => _ProductsGridState(cateID: cateID);
}

class _ProductsGridState extends State<ProductsGrid> {
  int cateID;
  _ProductsGridState({this.cateID});
  List<Product> _products = [];
  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getProductsPerCategory();
  }

  _getProductsPerCategory() {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }
    WooService()
        .dio
        .get('https://coderapps.xyz/wp-json/wc/v3/products?category=${cateID}',
            options:
                buildCacheOptions(Duration(minutes: 2), forceRefresh: false))
        .then((value) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      var d = json.encode(value.data);
      for (var prod in json.decode(d)) {
        Product p = Product.fromJson(prod);

        if (mounted) {
          setState(() {
            _products.add(p);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: PageStorageKey(cateID),
      child: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: _products.isEmpty
                  ? Center(
                      child: Text("No Products"),
                    )
                  : GridView.builder(
                      itemCount: _products.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1 / 1.3,
                          mainAxisSpacing: 20,
                          crossAxisSpacing: 20),
                      itemBuilder: (context, index) {
                        return ProductTile(
                          product: _products[index],
                        );
                      },
                    ),
            ),
    );
  }
}

class ProductTile extends StatefulWidget {
  Product product;
  ProductTile({this.product});

  @override
  _ProductTileState createState() => _ProductTileState(product: product);
}

class _ProductTileState extends State<ProductTile> {
  Product product;
  _ProductTileState({this.product});
  PaletteGenerator _palet;
  Color bgc = Colors.grey[200];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getColor();
    _palet = PaletteGenerator.fromColors([
      PaletteColor(Colors.grey[50], 3),
      PaletteColor(Colors.red, 3),
    ]);
  }

  _getColor() async {
    // PaletteGenerator d = await PaletteGenerator.fromImageProvider(
    //     NetworkImage(product.images[0].src),
    //     size: Size(10, 10));
    var file = await DefaultCacheManager().getSingleFile(product.images[0].src);
    // print(file);
    if (file != null) {
      print("Palette from file");
      PaletteGenerator d = await PaletteGenerator.fromImageProvider(
          FileImage(file),
          size: Size(10, 10));
      if (mounted) {
        setState(() {
          bgc = d.mutedColor.color;
          _palet = d;
        });
      }
    } else {
      print("Palette from network");

      PaletteGenerator d = await PaletteGenerator.fromImageProvider(
          NetworkImage(product.images[0].src),
          size: Size(10, 10));
      if (mounted) {
        setState(() {
          bgc = d.mutedColor.color;
          _palet = d;
        });
      }
    }
  }

  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (c) => ProductDetails(
                product: product,
                generator: _palet,
              ),
            ),
          );
        },
        child: Container(
          color: _palet != null
              ? _palet.dominantColor.color.withOpacity(0.5)
              : Colors.grey,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  decoration: BoxDecoration(
                      color: _palet != null
                          ? _palet.dominantColor.color
                          : Colors.red,
                      // color: bgc,
                      borderRadius: BorderRadius.circular(20)),
                  child: Text('Rs.${widget.product.salePrice}'),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    margin: EdgeInsets.all(10),
                    height: 100,
                    child: Hero(
                      tag: "t1" + product.id.toString(),
                      child: CachedNetworkImage(
                        imageUrl: widget.product.images[0].src,
                        cacheKey: widget.product.images[0].id.toString(),
                        placeholder: (context, url) =>
                            Center(child: CircularProgressIndicator()),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                      ),
                    ),
                  ),
                  Text(
                    widget.product.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  // Text(
                  //   widget.product.shortDescription,
                  //   textAlign: TextAlign.center,
                  // ),
                  Html(
                    data: widget.product.shortDescription,
                    blacklistedElements: [
                      'br',
                    ],
                    shrinkWrap: true,
                    style: {
                      "p": Style(
                        lineHeight: 1,
                        textAlign: TextAlign.center,
                        padding: EdgeInsets.all(0),
                        margin: EdgeInsets.all(0),
                      )
                    },
                  ),
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
              product.stockStatus == "outofstock"
                  ? Positioned(
                      top: 0,
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                          color: Colors.black.withOpacity(0.5),
                          child: Center(
                              child: Text(
                            "Out of Stock",
                            style: TextStyle(
                                color: Colors.red,
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ))),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
