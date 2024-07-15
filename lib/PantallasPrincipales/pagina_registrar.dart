import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Models/Cliente.dart';
import 'package:sync_pro_mobile/Models/Localidad.dart';
import 'package:sync_pro_mobile/PantallasSecundarias/pagina_pedidos.dart';
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
  Localidad? rutaSeleccionada; // Variable para almacenar la ruta seleccionada
  String estadoSeleccionado = 'No Visitado'; // Estado inicial seleccionado
  bool esIniciar = true; // Controla el estado del botón Iniciar/Finalizar
  List<String> estados = ['Ausente', 'Visitado', 'No Visitado', 'Ordeno'];
  List<Cliente> clientes = []; // Lista de clientes

  TextEditingController observacionesController = TextEditingController(); // Controlador para el campo de observaciones

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose del TextEditingController cuando se elimine la página
    observacionesController.dispose();
    super.dispose();
  }

  void _cargarClientes() async {
    try {
      // Obtener los clientes desde la base de datos local
      DatabaseHelperCliente databaseHelperCliente = DatabaseHelperCliente();
      clientes = await databaseHelperCliente.getClientesLocalidad(rutaSeleccionada?.id ?? 0);

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
    DatabaseHelperLocalidad databaseHelperRuta = DatabaseHelperLocalidad();
    List<Localidad> rutas = await databaseHelperRuta.getLocalidades();

    // Mostrar el diálogo de selección de rutas
    final Localidad? resultado = await showDialog<Localidad>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Seleccionar Ruta'),
          content: SingleChildScrollView(
            child: ListBody(
              children: rutas.map((ruta) {
                return ListTile(
                  title: Text(ruta.nombre), // Ajusta según la propiedad que quieras mostrar
                  onTap: () {
                    Navigator.of(context).pop(ruta); // Devolver la ruta seleccionada
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
void _mostrarDetallesCliente(Cliente cliente) {
  observacionesController.text = ''; // Limpiar el texto al mostrar el diálogo

  String estado = estadoSeleccionado;
  // ignore: unused_local_variable
  bool esIniciarVisita = false;

  // Función para mostrar el AlertDialog de iniciar visita
  void _mostrarDialogoIniciarVisita() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Está seguro de iniciar la visita?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                setState(() {
                  esIniciarVisita = true; // Cambiar el estado a iniciar visita
                });
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar el AlertDialog de finalizar visita
  void _mostrarDialogoFinalizarVisita() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Está seguro de finalizar la visita?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () {
                setState(() {
                  esIniciarVisita = false; // Cambiar el estado a finalizar visita
                });
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  // Función para mostrar el AlertDialog de guardar cambios
  void _mostrarDialogoGuardarCambios() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Está seguro de guardar los cambios?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                _guardarCliente(); // Llamar al método para guardar el cliente
                Navigator.of(context).pop(); // Cerrar el diálogo
              },
            ),
          ],
        );
      },
    );
  }

  // Mostrar el AlertDialog principal
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          cliente.nombre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
               Row(
  children: [
    DropdownButton<String>(
      value: estado,
      onChanged: (String? newValue) {
        setState(() {
          estado = newValue!;
        });
      },
      items: estados.map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
    ),
    SizedBox(width: 20),
    IconButton(
      onPressed: () {
        _mostrarDialogoIniciarVisita();
      },
      icon: Icon(Icons.play_arrow,
      color: Colors.blue),
      tooltip: 'Iniciar Visita',
    ),
    SizedBox(width: 10),
    IconButton(
      onPressed: () {
        _mostrarDialogoFinalizarVisita();
      },
      icon: Icon(Icons.stop,
      color: Colors.blue),
      tooltip: 'Finalizar Visita',
    ),
  ],
),

                  const SizedBox(height: 10),
                  TextField(
                    controller: observacionesController,
                    decoration: const InputDecoration(
                      labelText: 'Observaciones',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaginaPedidos(cliente: cliente),
                            ),
                          ).then((_) {
                            // Código a ejecutar después de regresar de PaginaPedidos
                          });
                        },
                        child: const Icon(Icons.add, color: Colors.white),
                      ),
                            const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                        onPressed: () {
                          _mostrarDialogoGuardarCambios();
                        },
                        child: const Text('✓'),
                      ),
                      const SizedBox(width: 12),
                     
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}



  void _guardarCliente() {
    // Lógica para guardar la información del cliente
    if (clienteSeleccionado != null) {
      // Aquí puedes agregar la lógica para guardar el cliente con sus observaciones y estado
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Cliente guardado: ${clienteSeleccionado!.nombre}'),
        ),
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
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0), // Ajustar el padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Alinea los botones
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
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold), // Reducir el tamaño del texto
                ),
                Text(
                  '${rutaSeleccionada?.nombre ?? "No se ha seleccionado ninguna ruta"}',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 10), // Reducir el espacio vertical
                Expanded(
                  child: ListView.builder(
                    itemCount: clientes.length,
                    itemBuilder: (context, index) {
                      final cliente = clientes[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            cliente.nombre,
                            style: TextStyle(fontSize: 14), // Reducir el tamaño del texto
                          ),
                          onTap: () {
                            setState(() {
                              clienteSeleccionado = cliente;
                            });
                            _mostrarDetallesCliente(cliente);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
}
