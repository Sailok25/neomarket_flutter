import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inicio'),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: Text(
                'Menú',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Perfil'),
              onTap: () {
                // Navegar a la pantalla de perfil
                Navigator.pushNamed(context, '/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.shopping_cart),
              title: Text('Cesta'),
              onTap: () {
                // Navegar a la pantalla de cesta
                Navigator.pushNamed(context, '/cart');
              },
            ),
            ListTile(
              leading: Icon(Icons.upload_file),
              title: Text('Subir producto'),
              onTap: () {
                // Navegar a la pantalla de subir producto
                Navigator.pushNamed(context, '/upload');
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite),
              title: Text('Favoritos'),
              onTap: () {
                // Navegar a la pantalla de favoritos
                Navigator.pushNamed(context, '/favoritos');
              },
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Notificaciones'),
              onTap: () {
                // Navegar a la pantalla de notificaciones
                Navigator.pushNamed(context, '/notifications');
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Ayuda'),
              onTap: () {
                // Navegar a la pantalla de ayuda
                Navigator.pushNamed(context, '/help');
              },
            ),
            Divider(
              height: 20,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: Colors.grey,
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Cerrar sesión'),
              onTap: () {
                // Navegar a la pantalla de inicio
                Navigator.pushNamedAndRemoveUntil(context, '/start', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Bienvenido a NeoMarket'),
      ),
    );
  }
}
