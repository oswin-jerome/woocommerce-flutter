import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:e_com/database/cart_store.dart';
import 'package:e_com/helpers/WooService.dart';
import 'package:e_com/models/order.dart';
import 'package:e_com/models/payment.dart';
import 'package:e_com/pages/homePage.dart';
import 'package:e_com/pages/paymentStatusPage.dart';
import 'package:e_com/provider/cartProvider.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:toast/toast.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class AddressPage extends StatefulWidget {
  @override
  _AddressPageState createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage>
    with TickerProviderStateMixin {
  String firstName;
  String lastName;
  String address;
  String city;
  String state;
  String country;
  String postalCode;
  String phone;
  String email;
  var checkoutBox = Hive.box('checkout');
  List<Payment> _payment = [];
  String tempPay = "";
  final _formKey = GlobalKey<FormState>();
  AnimationController _animationController;
  List<Cart> cartList = [];
  Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(seconds: 1));

    _getPaymentMethods();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment success");
    _onSubmit();
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment failed");
    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (c) => PaymentStatus(
                  msg: "Payment Failed",
                )));
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External waller");
  }

  _getPaymentMethods() {
    WooService()
        .dio
        .get("https://coderapps.xyz/wp-json/wc/v3/payment_gateways")
        .then(
      (value) {
        var temp = json.encode(value.data);
        _payment.clear();
        for (var pay in json.decode(temp)) {
          Payment payment = Payment.fromJson(pay);
          setState(() {
            _payment.add(payment);
          });
        }
        // print(value.data);
      },
    );
  }

  _onSubmit() async {
    List<LineItem> items = [];
    for (var cart in cartList) {
      LineItem lineItem =
          LineItem(quantity: cart.count, productId: cart.product['id']);
      // cart.delete();
      items.add(lineItem);
    }
    print("cart");
    // return;

    print(tempPay);
    var checkoutBox = await Hive.box('checkout');
    if (_formKey.currentState.validate() && tempPay != "") {
      _formKey.currentState.save();
      checkoutBox.putAll({
        "firstName": firstName,
        "lastName": lastName,
        "address": address,
        "city": city,
        "state": state,
        "country": country,
        "postalCode": postalCode,
        "phone": phone,
        "email": email,
      });
      var customerBox = Hive.box('customer');

      Order order = Order(
          billing: Ing(
            address1: address,
            city: city,
            country: country,
            email: email,
            phone: phone,
            firstName: firstName,
            lastName: lastName,
            postcode: postalCode,
            state: state,
          ),
          shipping: Ing(
            address1: address,
            city: city,
            country: country,
            email: email,
            phone: phone,
            firstName: firstName,
            lastName: lastName,
            postcode: postalCode,
            state: state,
          ),
          paymentMethod: tempPay,
          setPaid: tempPay == 'cod' ? false : true,
          lineItems: items,
          shippingLines: [
            // TODO: get shipping mwthods from server and add to total cost
            ShippingLine(
              methodId: "flat_rate",
              methodTitle: "Flat rate",
              total: "100",
            )
          ],
          paymentMethodTitle: "cash on delivery",
          customerId: customerBox.get('id'));

      print(jsonDecode(json.encode(order.toJson())));
      var authToken = base64
          .encode(utf8.encode(WooService().key + ":" + WooService().secret));
      // print('Basic $authToken');
      // return;
      FormData formData = FormData.fromMap(order.toJson());
      print(formData);
      // return;
      try {
        Dio()
            .post("https://coderapps.xyz/wp-json/wc/v3/orders",
                data: formData,
                options: Options(headers: {
                  "Authorization": 'Basic $authToken',
                  HttpHeaders.contentTypeHeader: 'application/json'
                }))
            .then((value) {
          print(value);
          // var customerBox = Hive.box('cart');
          // customerBox.clear();
          for (var cart in cartList) {
            cart.delete();
          }
          // Navigator.pushReplacement(
          //     context, MaterialPageRoute(builder: (c) => HomePage()));
          // Navigator.pop(context);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (c) => PaymentStatus(
                        msg: "Order placed with CASH ON DELIVERY",
                      )));
        }).catchError((onError) {
          print("error");
        });
      } catch (e) {
        print("Exception");
      }
    } else {
      Toast.show(
        "Please Fill all fields",
        context,
        duration: Toast.LENGTH_LONG,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartBox = Provider.of<CartProvider>(context);
    cartList = cartBox.cartList;
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: FlatButton(
          padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
          color: Colors.orange,
          child: Text("Pay " + cartBox.total.toString()),
          onPressed: () {
            // cartList.clear();
            if (tempPay == "razorpay") {
              var options = {
                'key': 'rzp_test_Vu8BUFHPAsq0lB',
                'amount': cartBox.total * 100,
                'name': 'Acme Corp.',
                'description': 'Fine T-Shirt',
                'timeout': 60, // in seconds
                'prefill': {
                  'contact': '8344441492',
                  'email': 'oswinjeromej@gmail.com'
                }
              };
              _razorpay.open(options);
            } else {
              _onSubmit();
            }

            cartBox.getTotal();
          },
        ),
      ),
      // bottomSheet: BottomSheet(
      //   elevation: 6,
      //   animationController: _animationController,
      //   onClosing: () {},
      //   builder: (context) {
      //     return Container(
      //       padding: EdgeInsets.only(bottom: 10),
      //       color: Colors.transparent,
      //       height: 70,
      //       child: Center(
      //         child: ClipRRect(
      //           borderRadius: BorderRadius.circular(40),
      //           child: FlatButton(
      //             padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
      //             color: Colors.orange,
      //             child: Text("Proceed"),
      //             onPressed: () {
      //               Navigator.push(context,
      //                   MaterialPageRoute(builder: (c) => AddressPage()));
      //             },
      //           ),
      //         ),
      //       ),
      //     );
      //   },
      // ),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                margin: EdgeInsets.only(top: 30, left: 15, bottom: 20),
                child: Text(
                  "Checkout",
                  textAlign: TextAlign.left,
                  style: TextStyle(
                    color: Colors.grey[800],
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 15, right: 15),
                padding: EdgeInsets.only(bottom: 100),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        "Shipping details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                initialValue: checkoutBox.get("firstName"),
                                decoration:
                                    inputdecorationBuilder("First Name"),
                                onSaved: (v) {
                                  firstName = v;
                                },
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "First Name is required";
                                  }

                                  return null;
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                initialValue: checkoutBox.get("firstName"),
                                decoration: inputdecorationBuilder("Last Name"),
                                onSaved: (v) => lastName = v,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Last Name is required";
                                  }

                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          initialValue: checkoutBox.get("address"),
                          maxLines: 5,
                          minLines: 1,
                          decoration: inputdecorationBuilder("Address"),
                          onSaved: (v) => address = v,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Address is required";
                            }

                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                initialValue: checkoutBox.get("city"),
                                decoration: inputdecorationBuilder("City"),
                                onSaved: (v) => city = v,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "City is required";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                initialValue: checkoutBox.get("state"),
                                decoration: inputdecorationBuilder("State"),
                                onSaved: (v) => state = v,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "State is required";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Flex(
                        direction: Axis.horizontal,
                        children: [
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                initialValue: checkoutBox.get("country"),
                                decoration: inputdecorationBuilder("Country"),
                                onSaved: (v) => country = v,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Country is required";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              margin: EdgeInsets.only(left: 10, right: 10),
                              child: TextFormField(
                                initialValue: checkoutBox.get("postalCode"),
                                decoration:
                                    inputdecorationBuilder("Postal Code"),
                                onSaved: (v) => postalCode = v,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return "Postal Code is required";
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        "Contact Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          maxLines: 5,
                          minLines: 1,
                          initialValue: checkoutBox.get("phone"),
                          decoration: inputdecorationBuilder("Phone"),
                          onSaved: (v) => phone = v,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Phone # is required";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10, right: 10),
                        child: TextFormField(
                          maxLines: 5,
                          minLines: 1,
                          initialValue: checkoutBox.get("email"),
                          decoration: inputdecorationBuilder("Email"),
                          onSaved: (v) => email = v,
                          validator: (value) {
                            if (value.isEmpty) {
                              return "Email is required";
                            }
                            return null;
                          },
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Text(
                        "Payment",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ListView(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        children: _payment.map<Widget>((e) {
                          if (e.enabled != true) {
                            return Container();
                          }
                          return ListTile(
                            leading: Radio(
                              groupValue: tempPay,
                              onChanged: (value) {
                                print(value);
                                setState(() {
                                  tempPay = e.id;
                                });
                              },
                              value: e.id,
                            ),
                            title: Text(e.title),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration inputdecorationBuilder(label) =>
      InputDecoration(labelText: label);
}
