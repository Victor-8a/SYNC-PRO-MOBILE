import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Models/Cliente.dart';
import 'package:sync_pro_mobile/Models/DetalleRuta.dart';
import 'package:sync_pro_mobile/Models/Localidad.dart';
import 'package:sync_pro_mobile/Models/Vendedor.dart';

import 'package:sync_pro_mobile/PantallasSecundarias/pagina_pedidos.dart';
import 'package:sync_pro_mobile/db/dbCliente.dart';
import 'package:sync_pro_mobile/db/dbLocalidad.dart';
import 'package:sync_pro_mobile/Models/Ruta.dart';
import 'package:sync_pro_mobile/db/dbRuta.dart';

import '../db/dbDetalleRuta.dart'; // Asegúrate de importar el modelo Ruta si no lo has hecho aún

 Future<Vendedor> loadSalesperson() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idVendedor = prefs.getString('idVendedor');
    String? vendedorName = prefs.getString('vendedorName');
  
  return Vendedor(value: int.parse(idVendedor!), nombre: vendedorName!);

  }

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  Localidad? rutaSeleccionada;
  Ruta? miRuta; // Variable para almacenar la ruta seleccionada
  String estadoSeleccionado = 'No Visitado'; // Estado inicial seleccionado
  bool esIniciar = true; // Controla el estado del botón Iniciar/Finalizar
  List<String> estados = ['Ausente', 'Visitado', 'No Visitado', 'Ordeno'];
  List<Cliente> clientes = []; // Lista de clientes
  bool rutaIniciada = false;
    


  TextEditingController observacionesController =
      TextEditingController(); // Controlador para el campo de observaciones

  @override
  void initState() {
    super.initState();

    loadRutaActiva().then((ruta) {
      print(ruta.idLocalidad);
      print('HOLA RUTA');
      if (mounted) {
        setState(() {
          miRuta = ruta;
        });
        loadDetalleRutaActiva();
      }

    }).catchError((error) {
      print('Error cargando ruta: $error');
    });
  }  
void _iniciarRuta() async {
  if (rutaIniciada) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La ruta ya está iniciada')),
      );
    }
    return;
  }

  if (rutaSeleccionada != null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Está seguro de iniciar la ruta?'),
          content: Text('Se iniciará la ruta: ${rutaSeleccionada!.nombre}'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () async {
                Navigator.of(context).pop(); // Cerrar el diálogo de confirmación
                try {
                  // Cargar el vendedor desde SharedPreferences
                  Vendedor vendedor = await loadSalesperson();

                  // Verificar si el widget sigue montado después de una operación asincrónica
                  if (!mounted) return;

                  // Crear el mapa de datos para la ruta
                  Map<String, dynamic> ruta = {
                    "idVendedor": vendedor.value,
                    "idLocalidad": rutaSeleccionada?.id ?? 0,
                    "fechaInicio": DateTime.now().toIso8601String(),
                    "fechaFin": '',
                    "anulado": 0,
                  };

                  // Insertar la ruta en la base de datos
                  Ruta rutaInsertada = await DatabaseHelperRuta().insertRuta(ruta);

                  if (!mounted) return;

                  setState(() {
                    miRuta = rutaInsertada;
                  });

                  // Crear un detalle de ruta para cada cliente en la localidad
                  for (Cliente cliente in clientes) {
                    DetalleRuta detalleRuta = DetalleRuta(
                      idRuta: miRuta!.id,
                      codCliente: cliente.codCliente,
                      estado: 'NV',
                      observaciones: '',
                      idPedido: 0, // O el id del pedido si lo tienes
                      inicio: '',
                      fin: '',
                     // O el id si lo tienes
                    );

                    await DatabaseHelperDetalleRuta().insertDetalleRuta(detalleRuta);
                    if (!mounted) return;
                  }

                  // Verificar si el widget sigue montado antes de mostrar el SnackBar
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ruta iniciada: ${rutaSeleccionada!.nombre}')),
                    );

                    // Actualizar el estado local para indicar que la ruta está iniciada
                    setState(() {
                      rutaIniciada = true;
                    });
                  }
                } catch (error) {
                  print('Error al insertar ruta: $error');
                  // Verificar si el widget sigue montado antes de mostrar el SnackBar
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error al iniciar la ruta')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  } else {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se ha seleccionado ninguna ruta')),
      );
    }
  }
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
      clientes = await databaseHelperCliente
          .getClientesLocalidad(rutaSeleccionada?.id ?? 0);

      setState(() {
        // Actualizar la interfaz con los clientes cargados
      });
    } catch (error) {
      print('Error al cargar clientes: $error');
      // Manejar el error según sea necesario
    }
  }

  void _seleccionarRuta() async {
    if (rutaIniciada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'La ruta ya está iniciada. No se puede seleccionar otra ruta.')),
      );
      return;
    }

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

  void _mostrarDetallesCliente(Cliente cliente) {
    if (!rutaIniciada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Debe iniciar la ruta antes de realizar esta acción')),
      );
      return;
    }

    observacionesController.text = ''; // Limpiar el texto al mostrar el diálogo

    String estado = estadoSeleccionado;
    // ignore: unused_local_variable
    bool esIniciarVisita = false;

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
                    esIniciarVisita = true;
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

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
                    esIniciarVisita = false;
                    rutaIniciada =
                        false; // Bloquear clientes al finalizar la visita
                  });
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('La visita ha sido finalizada')),
                  );
                },
              ),
            ],
          );
        },
      );
    }

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
                  _guardarCliente();
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

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
                              child: Text(value,
                                  style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                        ),
                        SizedBox(width: 20),
                        IconButton(
                          onPressed: () {
                            _mostrarDialogoIniciarVisita();
                          },
                          icon: Icon(Icons.play_arrow, color: Colors.blue),
                          tooltip: 'Iniciar Visita',
                        ),
                        SizedBox(width: 10),
                        IconButton(
                          onPressed: () {
                            _mostrarDialogoFinalizarVisita();
                          },
                          icon: Icon(Icons.stop, color: Colors.blue),
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
                                builder: (context) =>
                                    PaginaPedidos(cliente: cliente),
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
                      fontWeight:
                          FontWeight.bold), // Reducir el tamaño del texto
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
                            style: TextStyle(
                                fontSize: 14), // Reducir el tamaño del texto
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

  void _finalizarRuta() async {
    if (!rutaIniciada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('No se puede finalizar la ruta porque no está iniciada')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Está seguro de finalizar la ruta?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Aceptar'),
              onPressed: () async {
                // Obtener la fecha actual
                String fechaFin = DateTime.now().toIso8601String();

                // Actualizar la fecha de finalización en la base de datos
                await DatabaseHelperRuta().updateFechaFinRuta(
                  miRuta!.id, // Id de la ruta que se está finalizando
                  fechaFin, // Fecha actual de finalización
                );

                // Actualizar el estado de la ruta
                setState(() {
                  rutaIniciada = false;
                });

                Navigator.of(context)
                    .pop(); // Cerrar el diálogo de confirmación

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content:
                          Text('Ruta finalizada: ${rutaSeleccionada!.nombre}')),
                );
              },
            ),
          ],
        );
      },
    );
  }
  
  Future<Ruta> loadRutaActiva() async {
  DatabaseHelperRuta dbHelper = DatabaseHelperRuta();
  // await dbHelper.deleteAllRutas();
  final ruta =await dbHelper.getRutaActiva();
  print(ruta);
  return ruta;
  }
  
  Future<List<DetalleRuta>> loadDetalleRutaActiva() async {
DatabaseHelperDetalleRuta dbHelper = DatabaseHelperDetalleRuta ();
final detalleRuta = await dbHelper. getDetalleRutaActiva(miRuta!.id);

return detalleRuta;
  }
}
