import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sync_pro_mobile/Models/Cliente.dart';
import 'package:sync_pro_mobile/Models/DetalleRuta.dart';
import 'package:sync_pro_mobile/Models/Localidad.dart';
import 'package:sync_pro_mobile/Models/Vendedor.dart';
import 'package:sync_pro_mobile/PantallasSecundarias/listar_ruta.dart';
import 'package:sync_pro_mobile/PantallasSecundarias/pagina_pedidos.dart';
import 'package:sync_pro_mobile/db/dbCliente.dart';
import 'package:sync_pro_mobile/db/dbLocalidad.dart';
import 'package:sync_pro_mobile/Models/Ruta.dart';
import 'package:sync_pro_mobile/db/dbRuta.dart';
import 'package:sync_pro_mobile/services/sincronizarRuta.dart';
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
  DetalleRuta? clienteSeleccionado;
  Localidad? rutaSeleccionada;
  Ruta? miRuta; // Variable para almacenar la ruta seleccionada

  String estadoSeleccionado = 'No Visitado'; // Estado inicial seleccionado
  bool esIniciar = true; // Controla el estado del botón Iniciar/Finalizar
  bool esFinalizar = true;
  List<String> estados = ['Ausente', 'Visitado', 'No Visitado', 'Ordeno'];

  bool rutaIniciada = false;
  List<DetalleRuta> _detallesRuta = []; // Añadir esta línea

  TextEditingController observacionesController =
      TextEditingController(); // Controlador para el campo de observaciones

  @override
  void initState() {

  
    super.initState();

    loadRutaActiva().then((ruta) {
      if (mounted) {
        setState(() {
          miRuta = ruta;
        });

        if (miRuta?.id != null) {
          cargarDetallesRuta();
          rutaIniciada = true;
          DatabaseHelperLocalidad dbHelperLocalidad =
              DatabaseHelperLocalidad(); // Inicializa tu helper aquí

          if (miRuta?.idLocalidad != null) {
            dbHelperLocalidad
                .getLocalidadById(miRuta!.idLocalidad)
                .then((localidad) {
              if (mounted) {
                setState(() {
                  rutaSeleccionada = localidad;
                });
              }
            }).catchError((error) {
              print('Error cargando localidad: $error');
            });
          }
        }
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
                  Navigator.of(context)
                      .pop(); // Cerrar el diálogo de confirmación
                  try {
                    // Cargar el vendedor desde SharedPreferences
                    Vendedor vendedor = await loadSalesperson();

                    // Verificar si el widget sigue montado después de una operación asincrónica
                    if (!mounted) return;

                    // Crear el mapa de datos para la ruta
                    Map<String, dynamic> ruta = {
                      "idVendedor": vendedor.value,
                      "idLocalidad": rutaSeleccionada?.id ?? 0,
                      "fechaInicio":DateTime.now().toIso8601String(),
                      "fechaFin": '',
                      "anulado": 0,
                    };

                    // Insertar la ruta en la base de datos
                    Ruta rutaInsertada =
                        await DatabaseHelperRuta().insertRuta(ruta);

                    if (!mounted) return;

                    setState(() {
                      miRuta = rutaInsertada;
                      rutaIniciada = true; // Marcar la ruta como iniciada
                    });

                    for (DetalleRuta cliente in _detallesRuta) {
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

                      await DatabaseHelperDetalleRuta()
                          .insertDetalleRuta(detalleRuta);
                      if (!mounted) return;
                    }

                    // Verificar si el widget sigue montado antes de mostrar el SnackBar
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Ruta iniciada: ${rutaSeleccionada!.nombre}')),
                      );

                      // Actualizar el estado local para indicar que la ruta está iniciada
                      setState(() {
                        rutaIniciada = true;
                      });
                      cargarDetallesRuta();
                    }
                  } catch (error) {
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

  Color _getColorByEstado(String estado) {
    switch (estado) {
      case 'Ausente':
        return const Color.fromARGB(255, 248, 86, 75);
      case 'Visitado':
        return Colors.green;
      case 'No Visitado':
        return Colors.grey;
      case 'Ordeno':
        return Colors.blue;
      default:
        return Colors.white;
    }
  }

  Future<void> cargarDetallesRuta() async {
    // Cargar los detalles de la ruta activa
    List<DetalleRuta> detallesRuta = await loadDetalleRutaActiva();

    // Mostrar los detalles de la ruta activa en la pantalla actual
    if (detallesRuta.isNotEmpty) {
      setState(() {
        // Actualizar el estado con los detalles de la ruta
        _detallesRuta = detallesRuta;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No hay clientes en la ruta activa'),
        ),
      );
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
      DatabaseHelperDetalleRuta dbHelper = DatabaseHelperDetalleRuta();

      _detallesRuta =
          await dbHelper.getClientesDetalle(rutaSeleccionada?.id ?? 0);

      setState(() {
        // Actualizar la interfaz con los clientes cargados
      });
    } catch (error) {
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

  void _mostrarDetallesCliente(DetalleRuta detalle, Cliente clienteRuta) {
    if (!rutaIniciada) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Debe iniciar la ruta antes de realizar esta acción')),
      );
      return;
    }

    observacionesController.text = ''; // Limpiar el texto al mostrar el diálogo

    estadoSeleccionado = detalle.estado;

    bool esIniciarVisita = detalle.inicio != '';

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
                onPressed: () async {
                  setState(() {
                    esIniciarVisita = true;
                    loadRutaActiva();
                  });
                  Navigator.of(context).pop();

                  Fluttertoast.showToast(
                    msg: "La visita ha sido iniciada",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                  );

                  // Obtener la hora actual para el campo 'inicio'
                  String inicio = DateTime.now().toIso8601String();

                  // Asegúrate de que el cliente seleccionado no sea nulo
                  if (clienteSeleccionado != null) {
                    // Actualizar solo el campo 'inicio' en la base de datos
                    await updateInicioDetalleRuta(
                        clienteSeleccionado!.id, inicio);
                    cargarDetallesRuta();
                  } else {
                    Fluttertoast.showToast(
                      msg: "No se ha seleccionado ningún cliente",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
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
            onPressed: () async {
              // Verificar si la visita está iniciada
              if (esIniciarVisita) {
                // Asegúrate de que el cliente seleccionado no sea nulo
                if (clienteSeleccionado != null) {
                  // Consultar el campo 'fin' de la visita actual en la base de datos
                final String? fin = await DatabaseHelperDetalleRuta().obtenerFinDetalleRuta(detalle.id ?? 0);

                  // Verificar si el campo 'fin' ya está establecido
                
                  // ignore: unnecessary_null_comparison
                  if (fin != null) {
                    // Mostrar mensaje de error si la visita ya ha sido finalizada
                    Fluttertoast.showToast(
                      msg: "La visita ya ha sido finalizada",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                    Navigator.of(context).pop();
                  } else {
                    // Obtener la hora actual para el campo 'fin'
                    String fin = DateTime.now().toIso8601String();

                    // Actualizar el campo 'fin' en la base de datos
                    await updateFinDetalleRuta(clienteSeleccionado!.id, fin);
                    cargarDetallesRuta();
                    setState(() {
                      esIniciarVisita = false; // Indicar que la visita ha finalizado
                      rutaIniciada = true; // Bloquear clientes al finalizar la visita
                    });

                    // Mostrar mensaje de éxito
                    Fluttertoast.showToast(
                      msg: "La visita ha sido finalizada",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                    );
                    // Cerrar el diálogo
                    Navigator.of(context).pop();
                  }
                } else {
                  // Mostrar mensaje de error si no hay cliente seleccionado
                  Fluttertoast.showToast(
                    msg: "No se ha seleccionado ningún cliente",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.red,
                    textColor: Colors.white,
                  );
                }
              } else {
                // Mostrar mensaje de error si la visita no ha sido iniciada
                Fluttertoast.showToast(
                  msg: "La visita no ha sido iniciada",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                );
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      );
    },
  );
}


    void mostrarDialogoGuardarCambios() {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('¿Está seguro de guardar los cambios?'),
            content: esIniciarVisita
                ? (rutaIniciada
                    ? null
                    : Text(
                        'La visita está iniciada pero no finalizada. ¿Desea finalizarla antes de guardar?'))
                : Text(
                    'La visita no está iniciada. No se pueden guardar los cambios.'),
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
                  if (rutaIniciada) {
                    // Solo guarda si la visita está iniciada y finalizada
                    _guardarCliente();
                    Navigator.of(context).pop();
                  } else if (esIniciarVisita && !rutaIniciada) {
                    // Mostrar mensaje si la visita está iniciada pero no finalizada
                    Fluttertoast.showToast(
                      msg:
                          "La visita está iniciada pero no finalizada. Finalízala antes de guardar.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  } else {
                    // Mostrar mensaje si la visita no está iniciada
                    Fluttertoast.showToast(
                      msg: "La visita no ha sido iniciada. No puedes guardar.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
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
        bool puedeRealizarPedido = true;

        Future<void> verificarEstadoPedido() async {
          List<Map<String, dynamic>> resultado = await getDetalleRealizado(detalle.id ?? 0);
          setState(() {
            puedeRealizarPedido = resultado.isNotEmpty && resultado.first['realizaPedido'] == 1;
          });
        }

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
                        detalle.nombreCliente ?? '',
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
             esIniciarVisita
  ? Text(
      // ignore: unnecessary_null_comparison
      (detalle.inicio != null && detalle.inicio.length >= 16)
          ? 'Inicio: ${detalle.inicio.substring(11, 16) + ' ' + detalle.inicio.substring(0, 10)}'
          : 'Inicio: ${detalle.inicio}',
      style: const TextStyle(fontSize: 14),
    )
  : SizedBox(width: 0),
const SizedBox(height: 10),
                Row(
                  children: [
                    detalle.estado == 'No Visitado'
                        ? DropdownButton<String>(
                            value: estadoSeleccionado,
                            onChanged: (String? newValue) {
                              setState(() {
                                estadoSeleccionado = newValue!;
                              });
                            },
                            items: estados.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value, style: const TextStyle(fontSize: 14)),
                              );
                            }).toList(),
                          )
                        : Text(
                            estadoSeleccionado,
                            style: const TextStyle(fontSize: 14),
                          ),
                    SizedBox(width: 20),
                    !esIniciarVisita
                        ? IconButton(
                            onPressed: () {
                              _mostrarDialogoIniciarVisita();
                            },
                            icon: Icon(Icons.play_arrow, color: Colors.blue),
                            tooltip: 'Iniciar Visita',
                          )
                        : SizedBox(width: 0),
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
                        backgroundColor: puedeRealizarPedido ? Colors.blue : Colors.grey,
                      ),
                      onPressed: () async {
                        await verificarEstadoPedido();
                        if (puedeRealizarPedido) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaginaPedidos(cliente: clienteRuta),
                            ),
                          ).then((_) {
                            Navigator.of(context).pop();
                            cargarDetallesRuta();
                          });
                        }
                        
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
                        mostrarDialogoGuardarCambios();
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

  void _guardarCliente() async {
    if (clienteSeleccionado != null) {
      // Actualiza el detalle de la ruta con el nuevo estado y observaciones
      DetalleRuta detalleRutaActualizado = DetalleRuta(
        id: clienteSeleccionado!.id,
        idRuta: clienteSeleccionado!.idRuta,
        codCliente: clienteSeleccionado!.codCliente,
        estado: estadoSeleccionado,
        observaciones: observacionesController.text,
        idPedido: 0,
        inicio: '',
        fin: '',
      );
      // Llama al método para actualizar el detalle en la base de datos
      await DatabaseHelperDetalleRuta()
          .updateDetallesRuta(detalleRutaActualizado);
      cargarDetallesRuta();
      Fluttertoast.showToast(
        msg:
            "Visita al cliente ${clienteSeleccionado!.nombreCliente} guardada correctamente",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se ha seleccionado ningún cliente'),
        ),
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
                    itemCount: _detallesRuta.length,
                    itemBuilder: (context, index) {
                      final detalle = _detallesRuta[index];
                      return Card(
                          child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: _getColorByEstado(
                                detalle.estado), // Color del borde
                            width: 1.50, // Ancho del borde
                          ),
                          borderRadius:
                              BorderRadius.circular(4.0), // Radio del borde
                        ),
                        child: ListTile(
                          title: Text(
                            detalle.nombreCliente ?? '',
                            style: TextStyle(
                              fontSize: 14, // Reducir el tamaño del texto
                            ),
                          ),
                          onTap: () async {
                            DatabaseHelperCliente dbHelper =
                                DatabaseHelperCliente();
                            Cliente cliente = await dbHelper
                                .getClientesById(detalle.codCliente);
                            setState(() {
                              clienteSeleccionado = detalle;
                            });
                            _mostrarDetallesCliente(detalle, cliente);
                          },
                        ),
                      ));
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

       floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListarRuta()), // Redirige a la página ListarRuta
          );
        },
        child: Icon(Icons.local_shipping), // Icono de camión
    )
    );
  }
// Método para finalizar la ruta
void _finalizarRuta() async {
  if (!rutaIniciada) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('No se puede finalizar la ruta porque no está iniciada')),
    );
    return;
  }

  // Verificar sincronización de la ruta
  int pedidosNoSincronizados = await verificarSincronizacionRuta(miRuta!.id);

  if (pedidosNoSincronizados > 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'No se puede finalizar la ruta. Hay $pedidosNoSincronizados pedidos no sincronizados.')),
    );
    return;
  }

  // Ejecutar la consulta para verificar las condiciones
  int count =
      await DatabaseHelperDetalleRuta().getDetalleRutaCount(miRuta!.id);

  if (count > 0) {
    // Obtener detalles sin finalizar
    List<Map<String, dynamic>> detallesNoFinalizados =
        await DatabaseHelperDetalleRuta().getDetallesNoFinalizados(miRuta!.id);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles sin finalizar'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: detallesNoFinalizados.map((detalle) {
              return ListTile(
                title: Text('Cliente: ${detalle['nombreCliente'] ?? ''}'),
                subtitle: Text(
                    'Estado: ${detalle['estado']}, Observaciones: ${detalle['observaciones']}'),
              );
            }).toList(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Finalizar ruta de todos modos'),
              onPressed: () async {
                // Obtener la fecha actual
                String fechaFin = DateTime.now().toIso8601String();

                // Actualizar la fecha de finalización en la base de datos
                await DatabaseHelperRuta().updateFechaFinRuta(
                  miRuta!.id, // Id de la ruta que se está finalizando
                  fechaFin, // Fecha actual de finalización
                );

                await DatabaseHelperDetalleRuta()
                    .getDetalleRutaCountAndUpdate(miRuta!.id);

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
    return;
  }

  // Si no hay detalles sin finalizar, proceder a finalizar la ruta directamente
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

              syncRutas();
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
    final ruta = await dbHelper.getRutaActiva();

    return ruta;
  }

  Future<List<DetalleRuta>> loadDetalleRutaActiva() async {
    DatabaseHelperDetalleRuta dbHelper = DatabaseHelperDetalleRuta();
    final detalleRuta = await dbHelper.getDetalleRutaActiva(miRuta!.id);

    return detalleRuta;
  }

  updateInicioDetalleRuta(id, String inicio) async {
    DatabaseHelperDetalleRuta dbHelper = DatabaseHelperDetalleRuta();
    final detalleRuta = await dbHelper.updateInicioDetalleRuta(id, inicio);

    return detalleRuta;
  }

  updateFinDetalleRuta(int? id, fin) async {
    DatabaseHelperDetalleRuta dbHelper = DatabaseHelperDetalleRuta();
    final detalleRuta = await dbHelper.updateFinDetalleRuta(id!, fin);

    return detalleRuta;
  }

  getDetalleRealizado(int idRuta) async {
    DatabaseHelperDetalleRuta dbHelper = DatabaseHelperDetalleRuta();
    final detalleRuta = await dbHelper.getDetalleRealizado(idRuta);
    return detalleRuta;
  }
  
  verificarSincronizacionRuta(int id) async {
    DatabaseHelperDetalleRuta dbHelper = DatabaseHelperDetalleRuta();
    final detalleRuta = await dbHelper.verificarSincronizacionRuta(id);

    return detalleRuta;

  }
  

}

