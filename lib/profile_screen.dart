import 'package:flutter/material.dart';
import 'package:neomarket_flutter/conexio.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final DatabaseConnection _dbConnection = DatabaseConnection();
  Map<String, dynamic>? userData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve the user ID from the arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map?;
    if (args != null) {
      int? userId = args['userId'];
      if (userId != null) {
        _fetchUserData(userId);
      }
    }
  }

  Future<void> _fetchUserData(int userId) async {
    try {
      var result = await _dbConnection.executeQuery(
        'SELECT nombre, apellido, email FROM nm_usuarios WHERE id_usuario = :userId',
        {'userId': userId},
      );

      if (result != null && result.rows.isNotEmpty) {
        setState(() {
          userData = result.rows.first.assoc();
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Perfil'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Image and Name
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    userData != null ? '${userData!['nombre']} ${userData!['apellido']}' : 'Nombre Usuario',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    userData != null ? userData!['email'] : 'user@example.com',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),

            SizedBox(height: 20),

            // User Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('0', 'Productos'),
                _buildStatColumn('0/0', 'Valoraciones'),
                _buildStatColumn('0', 'Guardados'),
              ],
            ),

            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ],
    );
  }
}
