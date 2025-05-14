import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'upload_product_screen.dart';
import 'product_detail_screen.dart';
import 'cart_screen.dart';
import 'payment_screen.dart';
import 'start_screen.dart';
import 'favorites_screen.dart';
import 'card_input_screen.dart';
import 'result_payment_screen.dart';
import 'help_screen.dart';
import 'notifications_screen.dart';

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
      initialRoute: '/start',
      onGenerateRoute: (settings) {
        if (settings.name == '/cart') {
          final userId = settings.arguments as int?; // Obtener el userId de los argumentos
          if (userId != null) {
            return MaterialPageRoute(
              builder: (context) => CartScreen(userId: userId),
            );
          } else {
            // Manejar el caso en el que userId es null, por ejemplo, redirigir a una pantalla de error o mostrar un mensaje
            return MaterialPageRoute(
              builder: (context) => Scaffold(
                body: Center(
                  child: Text('Error: No se proporcionó un ID de usuario válido.'),
                ),
              ),
            );
          }
        }
        // Añadir más rutas personalizadas aquí si es necesario
        return null;
      },
      routes: {
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegisterScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/upload': (context) => UploadProductScreen(),
        '/productDetail': (context) => ProductDetailScreen(),
        '/payment': (context) => PaymentScreen(),
        '/start': (context) => StartScreen(),
        '/favoritos': (context) => FavoritesScreen(),
        '/cardInput': (context) => CardInputScreen(),
        '/resultPayment': (context) => ResultPaymentScreen(),
        '/help': (context) => HelpScreen(),
        '/notifications': (context) => NotificationsScreen(),
      },
    );
  }
}
