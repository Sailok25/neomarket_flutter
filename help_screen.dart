import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayuda'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              'Centro de Ayuda',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Bienvenido al Centro de Ayuda de NeoMarket. Aquí encontrarás respuestas a las preguntas más frecuentes y guías sobre cómo usar la aplicación.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 24),
            Text(
              'Preguntas Frecuentes',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            ExpansionTile(
              title: Text('¿Cómo puedo registrarme?'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Para registrarte, ve a la pantalla de inicio y selecciona "Registrarse". Sigue las instrucciones para completar tu registro.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text('¿Cómo puedo añadir un producto?'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Para añadir un producto, ve al menú y selecciona "Subir producto". Sigue las instrucciones para completar la subida de tu producto.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            ExpansionTile(
              title: Text('¿Cómo puedo realizar un pago?'),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Para realizar un pago, añade los productos a tu cesta y ve a la pantalla de pago. Selecciona el método de pago y sigue las instrucciones.',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Contacto',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Si necesitas más ayuda, puedes contactarnos a través de nuestro correo electrónico de soporte: soporte@neomarket.com',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
