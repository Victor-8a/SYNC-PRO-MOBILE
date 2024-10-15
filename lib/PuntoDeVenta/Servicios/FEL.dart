import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Cliente.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:http/http.dart' as http;
import 'package:sync_pro_mobile/Pedidos/services/LoginToken.dart';

final TextEditingController _felNameController = TextEditingController();
final TextEditingController _felAddressController = TextEditingController();
Cliente _ClientePorDefecto() {
  return Cliente(
    codCliente: 0,
    nombre: 'CONSUMIDOR FINAL',
    cedula: '',
    direccion: 'CIUDAD',
    credito: false,
  );
}

// Función para mostrar el diálogo
Future<Cliente?> showFELDialog(BuildContext context,
    TextEditingController _nitController, Cliente clienteResponse) {
  return showDialog<Cliente?>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('FEL'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nitController,
              decoration: InputDecoration(
                labelText: 'NIT',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (value) async {
                await consultarNit(
                    _nitController, _nitController.text, context);
              },
            ),
            SizedBox(height: 10),
            TextField(
              controller: _felNameController,
              decoration: InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
              ),
              enabled: false, // Campo bloqueado
              maxLines: null,
              minLines: 1,
              textAlignVertical: TextAlignVertical.top,
            ),
            SizedBox(height: 10),
            TextField(
              controller: _felAddressController,
              decoration: InputDecoration(
                labelText: 'Dirección',
                border: OutlineInputBorder(),
              ),
              enabled: false, // Campo bloqueado
              maxLines: null,
              minLines: 1,
              textAlignVertical: TextAlignVertical.top,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Cliente clienteResponse = await guardarDatosCliente(
                _nitController.text,
                _felNameController.text,
                _felAddressController.text,
                context,
              );
              Navigator.of(context)
                  .pop(clienteResponse); // Pasar el cliente de vuelta
            },
            child: Text('Guardar'),
          ),
        ],
      );
    },
  );
}

// Función para consultar el NIT
Future<void> consultarNit(TextEditingController _nitController, String nit,
    BuildContext context) async {
  final url = ApiRoutes.buildUri('fel/consultaNit/$nit');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['success'] == true && jsonData['data'] != null) {
        final data = jsonData['data'];

        String nombre = data['nombre'] ?? 'CONSUMIDOR FINAL';
        nombre = nombre.replaceAll(RegExp(r',,'), ',').trim();

        String direccion = (data['direccion']?.trim().isEmpty ?? true)
            ? ''
            : data['direccion'];

        _felNameController.text = nombre;
        _felAddressController.text = direccion;
      } else {
        _showError('Datos no disponibles para el NIT ingresado', context);
        _nitController.text = "CF";
        _felNameController.text = 'CONSUMIDOR FINAL';
        _felAddressController.text = 'CIUDAD';
      }
    } else {
      _showError('Error al consultar NIT', context);
      _nitController.text = "CF";
      _felNameController.text = 'CONSUMIDOR FINAL';
      _felAddressController.text = 'CIUDAD';
    }
  } catch (e) {
    _showError('Error de conexión: $e', context);
    _felNameController.text = 'CONSUMIDOR FINAL';
    _felAddressController.text = 'CIUDAD';
  }
}

// Función para enviar los datos del cliente

Future<Cliente> guardarDatosCliente(
    String nit, String nombre, String direccion, BuildContext context) async {
  final url = ApiRoutes.buildUri('cliente/cedula');
  String? token = await login();
  final body = jsonEncode({
    'Cedula': nit,
    'Nombre': nombre,
    'Direccion': direccion,
  });

  try {
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: body,
    );

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      if (jsonData != null &&
          jsonData['cliente'] != null &&
          jsonData['cliente']['Cedula'] != null) {
        final cliente = Cliente.fromJson(jsonData['cliente']);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Datos guardados exitosamente')),
        );
        return cliente; // Retorna el cliente guardado
      } else {
        // Si la respuesta es inválida, devuelve el cliente por defecto
        _showError('Error: Datos inválidos en la respuesta', context);
        return _ClientePorDefecto();
      }
    } else {
      // En caso de error al guardar
      _showError('Error al guardar los datos. Código: ${response.statusCode}',
          context);
      return _ClientePorDefecto();
    }
  } catch (FormatException) {
    // Manejo de excepciones
    _showError('Error al decodificar los datos', context);
    return _ClientePorDefecto();
  }
}

// Función para mostrar errores
void _showError(String message, BuildContext context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
