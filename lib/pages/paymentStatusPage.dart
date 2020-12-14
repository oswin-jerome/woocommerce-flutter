import 'package:e_com/provider/cartProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PaymentStatus extends StatelessWidget {
  String msg;
  PaymentStatus({msg}) {
    this.msg = msg;
  }

  @override
  Widget build(BuildContext context) {
    final cartBox = Provider.of<CartProvider>(context);
    Future.delayed(Duration(seconds: 2))
        .then((value) => {Navigator.pop(context)});
    cartBox.getTotal();
    return Scaffold(
      body: Center(
        child: Text(msg),
      ),
    );
  }
}
