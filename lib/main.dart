import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'upload_product_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'payment_screen.dart';

void main() {
  runApp(NeoMarketApp());
}

class NeoMarketApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NeoMarket',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/upload': (context) => UploadProductScreen(),
        '/productDetail': (context) => ProductDetailScreen(),
        '/cart': (context) => CartScreen(),
        '/payment': (context) => PaymentScreen(),
      },
    );
  }
}
