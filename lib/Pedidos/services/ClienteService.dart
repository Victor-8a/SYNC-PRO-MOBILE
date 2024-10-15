import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/Pedidos/Models/Cliente.dart';
import 'package:sync_pro_mobile/Pedidos/services/LoginToken.dart';
import 'package:sync_pro_mobile/db/dbCliente.dart';
import 'package:sync_pro_mobile/db/dbConfiguraciones.dart';
import 'package:sync_pro_mobile/db/dbUsuario.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';

class ClienteService {
  Future<List<Cliente>> insertarCliente() async {
    try {
      DatabaseHelperUsuario dbHelperUsuario = DatabaseHelperUsuario();
      int? idVendedor = await dbHelperUsuario.getIdVendedor();

      if (idVendedor == null) {
        throw Exception('No se pudo obtener el id del vendedor');
      }
      // Verificar si se deben usar los clientes filtrados
      bool clientesFiltrados =
          await DatabaseHelperConfiguraciones().getClientesFiltrados();

      // Construir la URL en función de la configuración
      Uri url;
      if (clientesFiltrados) {
        url = ApiRoutes.buildUri('cliente/vendedor/$idVendedor');
      } else {
        url = ApiRoutes.buildUri(
            'cliente'); // Suponiendo que esta es la URL cuando no se usa idVendedor
      }

      var connectivityResult = await Connectivity()
          .checkConnectivity()
          .timeout(Duration(seconds: 5));
      if (connectivityResult == ConnectivityResult.none) {
        print(
            'No hay conexión a Internet, recuperando clientes de la base de datos local');
        return await _retrieveClientesFromLocalDatabase();
      }

      String? token = await login();
      if (token == null) {
        throw Exception('No se encontró el token');
      }

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      ).timeout(Duration(seconds: 5));

      if (response.statusCode == 200) {
        DatabaseHelperCliente().deleteAllClientes();
        final List<dynamic> jsonResponse = json.decode(response.body);
        final clientes =
            jsonResponse.map((json) => Cliente.fromJson(json)).toList();
        await _saveClientesToLocalDatabase(clientes);
        return clientes;
      } else {
        throw Exception('Fallo al cargar clientes');
      }
    } catch (error) {
      print('Error al obtener clientes: $error');
      return await _retrieveClientesFromLocalDatabase();
    }
  }

  Future<void> _saveClientesToLocalDatabase(List<Cliente> clientes) async {
    try {
      DatabaseHelperCliente databaseHelper = DatabaseHelperCliente();
      await databaseHelper.deleteAllClientes();
      for (var cliente in clientes) {
        await databaseHelper.insertCliente(cliente);
      }
    } catch (error) {
      print('Error al guardar clientes en la base de datos local: $error');
    }
  }

  Future<List<Cliente>> _retrieveClientesFromLocalDatabase() async {
    try {
      DatabaseHelperCliente databaseHelper = DatabaseHelperCliente();
      return await databaseHelper.getClientes();
    } catch (error) {
      print('Error al recuperar clientes de la base de datos local: $error');
      return [];
    }
  }
}
