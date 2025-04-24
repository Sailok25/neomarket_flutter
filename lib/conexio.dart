import 'package:mysql_client/mysql_client.dart';

class DatabaseConnection {
  static final DatabaseConnection _instance = DatabaseConnection._internal();
  factory DatabaseConnection() => _instance;

  DatabaseConnection._internal();

  MySQLConnection? _connection;

  Future<MySQLConnection?> get connection async {
    if (_connection == null || _connection?.connected != true) {
      await _connect();
    }
    return _connection;
  }

  Future<void> _connect() async {
    try {
      _connection = await MySQLConnection.createConnection(
        host: "51.91.56.13",
        port: 3306,
        userName: "dam2_24_omar",
        password: "7-09yai*P_vLGuFP",
        databaseName: "dam2_24_omar",
      );

      await _connection?.connect(); // Afegeix aquesta línia per iniciar la connexió real
      print("Connected to the database");
    } catch (e) {
      print("Error connecting to the database: $e");
      _connection = null;
    }
  }

  Future<IResultSet?> executeQuery(String query, [Map<String, dynamic>? params]) async {
    if (_connection == null || _connection?.connected != true) {
      await _connect();
    }

    try {
      return await _connection?.execute(query, params ?? {});
    } catch (e) {
      print("Error executing query: $e");
      return null;
    }
  }

  Future<void> close() async {
    await _connection?.close();
    _connection = null;
  }
}
