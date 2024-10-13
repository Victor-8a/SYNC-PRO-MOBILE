// Función para mostrar el diálogo
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/services/ApiRoutes.dart';
import 'package:http/http.dart' as http;

// final TextEditingController _nitController = TextEditingController();
final TextEditingController _felNameController = TextEditingController();
final TextEditingController _felAddressController = TextEditingController();
// Función para mostrar el diálogo
void showFELDialog(BuildContext context, TextEditingController _nitController) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Datos FEL'),
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
                await consultarNit(_nitController.text, context);
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
            onPressed: () {
              // Aquí puedes guardar los datos si es necesario
              Navigator.of(context).pop();
            },
            child: Text('Guardar'),
          ),
        ],
      );
    },
  );
}

Future<void> consultarNit(String nit, BuildContext context) async {
  // Recibir context
  final url = ApiRoutes.buildUri('fel/consultaNit/$nit');

  try {
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);

      if (jsonData['success'] == true && jsonData['data'] != null) {
        final data = jsonData['data'];

        String nombre = data['nombre'] ?? 'No disponible';
        nombre = nombre.replaceAll(RegExp(r',,'), ',').trim();

        String direccion = (data['direccion']?.trim().isEmpty ?? true)
            ? ''
            : data['direccion'];

        _felNameController.text = nombre;
        _felAddressController.text = direccion;
      } else {
        _showError('Datos no disponibles para el NIT ingresado',
            context); // Pasar context aquí
        _felNameController.text = 'No disponible';
        _felAddressController.text = 'No disponible';
      }
    } else {
      _showError('Error al consultar NIT', context); // Pasar context aquí
      _felNameController.text = 'No disponible';
      _felAddressController.text = 'No disponible';
    }
  } catch (e) {
    _showError('Error de conexión: $e', context); // Pasar context aquí
    _felNameController.text = 'No disponible';
    _felAddressController.text = 'No disponible';
  }
}

void _showError(String message, BuildContext context) {
  // Recibir context aquí
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
