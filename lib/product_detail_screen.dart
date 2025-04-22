import 'package:flutter/material.dart';

class ProductDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detalle del producto')),
      body: Center(
        child: Text('Información del producto'),
      ),
    );
  }
}