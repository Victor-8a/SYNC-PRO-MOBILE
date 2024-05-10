import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PaginaCliente extends StatefulWidget {
  const PaginaCliente({Key? key}) : super(key: key);

  @override
  _PaginaClienteState createState() => _PaginaClienteState();
}

class _PaginaClienteState extends State<PaginaCliente> {
  late Future<List<Map<String, dynamic>>?> _clientesData;

  @override
  void initState() {
    super.initState();
    _clientesData = _fetchClientesData();
  }

  Future<List<Map<String, dynamic>>?> _fetchClientesData() async {
    try {
      final response = await http.get(
        Uri.parse('http://192.168.1.212:3000/clientes'),
        headers: {
          'Authorization':
              'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6MywiaWF0IjoxNzE1MzU4NzY5LCJleHAiOjE3MTU0MzA3Njl9.s5r4TgiM14tFlPiQQy2PTGMype0Gs_TWLO3lGsx0DtU',
        },
      );
      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load data from API. Status Code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
      return null; // Retornar null en caso de error
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>?>(
      future: _clientesData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError || snapshot.data == null) { // Manejar el caso de datos nulos
          return Center(child: Text('Error: Failed to load data from API'));
        } else {
          final List<Map<String, dynamic>> clientesData = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text('Lista de Clientes'),
            ),
            body: ListView.builder(
              itemCount: clientesData.length,
              itemBuilder: (context, index) {
                final cliente = clientesData[index];
                return ListTile(
                  title: Text(cliente['Nombre'] ?? 'Nombre no disponible'),
                  subtitle: Text(cliente['Cedula'] ?? 'Cédula no disponible'),
                  onTap: () {
                    // Aquí puedes agregar la lógica para mostrar los detalles del cliente si es necesario
                  },
                );
              },
            ),
          );
        }
      },
    );
  }
}
