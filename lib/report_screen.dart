import 'package:flutter/material.dart';
import 'package:neomarket_flutter/conexio.dart';

class ReportScreen extends StatefulWidget {
  final int userId;
  final int productId;

  ReportScreen({required this.userId, required this.productId});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  final DatabaseConnection _dbConnection = DatabaseConnection();
  final _formKey = GlobalKey<FormState>();
  String _motivo = '';
  String _titulo = '';
  bool _alreadyReported = false;

  @override
  void initState() {
    super.initState();
    _checkIfAlreadyReported();
  }

  Future<void> _checkIfAlreadyReported() async {
    try {
      var result = await _dbConnection.executeQuery(
        'SELECT COUNT(*) as count FROM nm_reportes WHERE id_usuario = :userId AND id_producto = :productId',
        {'userId': widget.userId, 'productId': widget.productId},
      );

      if (result != null && result.rows.isNotEmpty) {
        var count = result.rows.first.assoc()['count'];
        setState(() {
          _alreadyReported = count != null && int.parse(count.toString()) > 0;
        });
      }
    } catch (e) {
      print('Error checking if already reported: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reportar Producto'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Título del reporte'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el título del reporte';
                  }
                  return null;
                },
                onSaved: (value) {
                  _titulo = value!;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Motivo del reporte'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, ingresa el motivo del reporte';
                  }
                  return null;
                },
                onSaved: (value) {
                  _motivo = value!;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _alreadyReported ? null : _submitReport,
                child: Text(_alreadyReported ? 'Ya reportado' : 'Enviar Reporte'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<int> countReports(int productId) async {
    try {
      var result = await _dbConnection.executeQuery(
        'SELECT COUNT(*) as count FROM nm_reportes WHERE id_producto = :productId',
        {'productId': productId},
      );

      if (result != null && result.rows.isNotEmpty) {
        var count = result.rows.first.assoc()['count'];
        return count != null ? int.parse(count.toString()) : 0;
      }
    } catch (e) {
      print('Error counting reports: $e');
    }
    return 0;
  }

  Future<void> deactivateProductIfNecessary(int productId) async {
    int reportCount = await countReports(productId);
    if (reportCount >= 4) {
      try {
        await _dbConnection.executeQuery(
          'UPDATE nm_productos SET estado_anuncio = "inactivo" WHERE id_producto = :productId',
          {'productId': productId},
        );
      } catch (e) {
        print('Error deactivating product: $e');
      }
    }
  }

  Future<void> _submitReport() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      try {
        await _dbConnection.executeQuery(
          'INSERT INTO nm_reportes (id_usuario, id_producto, titulo, `desc`) VALUES (:userId, :productId, :titulo, :desc)',
          {
            'userId': widget.userId,
            'productId': widget.productId,
            'titulo': _titulo,
            'desc': _motivo,
          },
        );

        await deactivateProductIfNecessary(widget.productId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Reporte enviado con éxito')),
        );
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/home',
          (route) => false,
        );
      } catch (e) {
        print('Error submitting report: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al enviar el reporte')),
        );
      }
    }
  }
}
