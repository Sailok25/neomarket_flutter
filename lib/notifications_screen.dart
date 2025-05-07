import 'package:flutter/material.dart';

class NotificationsScreen extends StatelessWidget {
  // Sample data for notifications
  final List<Map<String, dynamic>> notifications = [
    {
      'type': 'comment',
      'icon': Icons.comment,
      'message': '@nick ha dejado un comentario en tu producto @nombreproducto',
      'time': '9:56 AM',
    },
    {
      'type': 'purchase',
      'icon': Icons.shopping_cart,
      'message': '@nick ha comprado tu producto @nombreproducto',
      'time': '9:56 AM',
    },
    {
      'type': 'saved',
      'icon': Icons.favorite,
      'message': '@nick ha guardado tu producto @nombreproducto',
      'time': '9:56 AM',
    },
    {
      'type': 'delivery',
      'icon': Icons.delivery_dining,
      'message': 'Tu pedido @numpedido está en reparto',
      'time': '9:56 AM',
    },
    {
      'type': 'discount',
      'icon': Icons.local_fire_department,
      'message': 'El producto @nombreproducto que tienes guardado, ha bajado de precio',
      'time': '9:56 AM',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notificaciones')),
      body: ListView.builder(
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Card(
            margin: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            child: ListTile(
              leading: Icon(notification['icon'], color: Colors.blue),
              title: Text(notification['message']),
              trailing: Text(notification['time']),
            ),
          );
        },
      ),
    );
  }
}
