import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Models/Cliente.dart';
import 'package:sync_pro_mobile/Models/Localidad.dart';
import 'package:sync_pro_mobile/db/dbCliente.dart';
import 'package:sync_pro_mobile/db/dbLocalidad.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cliente App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PaginaRegistrar(),
    );
  }
}

class PaginaRegistrar extends StatefulWidget {
  const PaginaRegistrar({Key? key}) : super(key: key);

  @override
  _PaginaRegistrarState createState() => _PaginaRegistrarState();
}

class _PaginaRegistrarState extends State<PaginaRegistrar> {
  Cliente? clienteSeleccionado;
  Ruta? rutaSeleccionada; // Variable para almacenar la ruta seleccionada
  String estadoSeleccionado = 'Visitado'; // Estado inicial seleccionado
  List<String> estados = ['Ausente', 'Visitado', 'No Visitado', 'Ordeno'];
  TextEditingController observacionesController = TextEditingController();

  List<Cliente> clientes = []; // Lista de clientes

  @override
  void initState() {
    super.initState();
    _cargarClientes(); // Cargar clientes al iniciar la página
  }

  void _cargarClientes() async {
    try {
      // Obtener los clientes desde la base de datos local
      DatabaseHelperCliente databaseHelperCliente = DatabaseHelperCliente();
      clientes = await databaseHelperCliente.getClientesLocalidad(rutaSeleccionada!.id);

      setState(() {
        // Actualizar la interfaz con los clientes cargados
      });
    } catch (error) {
      print('Error al cargar clientes: $error');
      // Manejar el error según sea necesario
    }
  }

  void _seleccionarRuta() async {
    // Obtener las rutas desde la base de datos local
    DatabaseHelperRuta databaseHelperRuta = DatabaseHelperRuta();
    List<Ruta> rutas = await databaseHelperRuta.getRutas();

    // Mostrar el diálogo de selección de rutas
    final Ruta? resultado = await showDialog<Ruta>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Ruta'),
          content: SingleChildScrollView(
            child: ListBody(
              children: rutas.map((ruta) {
                return ListTile(
                  title: Text(ruta
                      .nombre), // Ajusta según la propiedad que quieras mostrar
                  onTap: () {
                    Navigator.of(context)
                        .pop(ruta); // Devolver la ruta seleccionada
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );

    // Actualizar la ruta seleccionada si se devuelve una ruta
    if (resultado != null) {
      setState(() {
        rutaSeleccionada = resultado;
        _cargarClientes();
      });
    }
  }

  void _iniciarRuta() {
    // Lógica para iniciar la ruta seleccionada
    if (rutaSeleccionada != null) {
      // Puedes implementar aquí la lógica para iniciar la ruta
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ruta iniciada: ${rutaSeleccionada!.nombre}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se ha seleccionado ninguna ruta')),
      );
    }
  }

  void _finalizarRuta() {
    // Lógica para finalizar la ruta seleccionada
    if (rutaSeleccionada != null) {
      // Puedes implementar aquí la lógica para finalizar la ruta
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ruta finalizada: ${rutaSeleccionada!.nombre}')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se ha seleccionado ninguna ruta')),
      );
    }
  }

  void _guardarCliente() {
    // Lógica para guardar la información del cliente
    if (clienteSeleccionado != null) {
      // Aquí puedes agregar la lógica para guardar el cliente con sus observaciones y estado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Cliente guardado: ${clienteSeleccionado!.nombre}')),
      );
      // También puedes agregar la lógica para guardar el estado y las observaciones en la base de datos
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se ha seleccionado ningún cliente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0), // Ajustar el padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly, // Alinea los botones
              children: [
                ElevatedButton(
                  onPressed: _seleccionarRuta,
                  child: const Text('Ruta'),
                ),
                ElevatedButton(
                  onPressed: _iniciarRuta,
                  child: const Text('Iniciar'),
                ),
                ElevatedButton(
                  onPressed: _finalizarRuta,
                  child: const Text('Finalizar'),
                ),
              ],
            ),
            const SizedBox(height: 10), // Reducir el espacio vertical
            Text(
              'Ruta de hoy:',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold), // Reducir el tamaño del texto
            ),
            Text(
              '${rutaSeleccionada?.nombre ?? "No se ha seleccionado ninguna ruta"}',
              style: TextStyle(fontSize: 14), // Reducir el tamaño del texto
            ),
            const SizedBox(height: 20), // Reducir el espacio vertical
            Text(
              'Clientes',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold), // Reducir el tamaño del texto
            ),
            const SizedBox(height: 10), // Reducir el espacio vertical
            Expanded(
              child: ListView.builder(
                itemCount: clientes.length,
                itemBuilder: (context, index) {
                  return Card(
                    elevation: 2,
                    child: ListTile(
                      title: Text(clientes[index].nombre,
                          style: TextStyle(
                              fontSize: 14)), // Reducir el tamaño del texto
                      onTap: () {
                        setState(() {
                          clienteSeleccionado = clientes[index];
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          if (clienteSeleccionado != null) ...[
 SingleChildScrollView(
  child: Card(
    elevation: 2,
    child: Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  clienteSeleccionado != null ? clienteSeleccionado!.nombre : '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              DropdownButton<String>(
                value: estadoSeleccionado,
                onChanged: (String? newValue) {
                  setState(() {
                    estadoSeleccionado = newValue!;
                  });
                },
                items: estados.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(fontSize: 14)),
                  );
                }).toList(),
              ),
              IconButton(
                icon: Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    clienteSeleccionado = null;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          Container(
            constraints: BoxConstraints(maxHeight: 200),
            child: SingleChildScrollView(
              child: TextField(
                controller: observacionesController,
                decoration: InputDecoration(
                  labelText: 'Observaciones',
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ),
          SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: _guardarCliente,
              child: Text('Guardar', style: TextStyle(fontSize: 14)),
       ),
          ),
        ],
      ),
    ),
  ),
)
],

          ],
        ),
      ),
    );
  }
}
