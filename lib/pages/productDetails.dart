import 'package:cached_network_image/cached_network_image.dart';
import 'package:e_com/animations/fadeAnimation.dart';
import 'package:e_com/database/cart_store.dart';
import 'package:e_com/models/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_html/style.dart';
import 'package:hive/hive.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:toast/toast.dart';

class ProductDetails extends StatefulWidget {
  Product product;
  PaletteGenerator generator;
  ProductDetails({this.product, this.generator});
  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails>
    with TickerProviderStateMixin {
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
    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height,
              color: widget.generator.dominantColor.color.withOpacity(0.5),
              child: Container(
                margin: EdgeInsets.only(top: 70, left: 20),
                child: FadeAnimation(
                  1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Text(
                            widget.product.name,
                            style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: widget.generator.darkVibrantColor.color),
                            textAlign: TextAlign.left,
                          ),
                        ],
                      ),
                      Text(
                        "Rs." + widget.product.salePrice,
                        style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: widget.generator.darkVibrantColor.color
                                .withOpacity(0.5)),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 250,
            bottom: 0,
            child: BottomToUpAnimation(
              0.5,
              0,
              child: ClipRRect(
                borderRadius: BorderRadius.only(topRight: Radius.circular(80)),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            child: Container(
                              margin: EdgeInsets.only(top: 70),
                              padding: EdgeInsets.all(8),
                              child: FadeAnimation(
                                1,
                                child: Html(
                                  data: widget.product.description,
                                  blacklistedElements: ['br'],
                                  shrinkWrap: true,
                                  style: {
                                    "p": Style(
                                      lineHeight: 1.7,
                                      color: widget.generator.mutedColor.color,
                                    )
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                        RaisedButton(
                          color: widget.generator.vibrantColor.color,
                          onPressed: widget.product.stockStatus == "outofstock"
                              ? null
                              : () async {
                                  var cartBox =
                                      await Hive.openBox<Cart>('cart');
                                  Cart c = new Cart();
                                  c.count = 1;
                                  c.product = widget.product.toJson();
                                  cartBox.add(c).then((value) {
                                    Toast.show(
                                      "Item added to cart",
                                      context,
                                      gravity: Toast.CENTER,
                                      duration: Toast.LENGTH_LONG,
                                    );
                                  });
                                },
                          child: Container(
                              margin: EdgeInsets.all(9),
                              padding: EdgeInsets.all(12),
                              child: Text(
                                widget.product.stockStatus == "outofstock"
                                    ? "OUT OF STOCK"
                                    : "Add to Cart",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 18),
                              )),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          buildPositionedImage(),
        ],
      ),
    );
  }

  Positioned buildPositionedImage() {
    return Positioned(
      top: 100,
      right: 10,
      child: Hero(
        transitionOnUserGestures: true,
        tag: "t1" + widget.product.id.toString(),
        child: CachedNetworkImage(
          width: 250,
          height: 250,
          imageUrl: widget.product.images[0].src,
          placeholder: (context, url) => CircularProgressIndicator(),
          errorWidget: (context, url, error) => Icon(Icons.error),
        ),
      ),
    );
  }
}
