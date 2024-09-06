import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Localidad.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Ruta.dart';
import 'package:sync_pro_mobile/Pedidos/db/dbDetalleRuta.dart';
import 'package:sync_pro_mobile/Pedidos/db/dbRuta.dart';
import 'package:sync_pro_mobile/Pedidos/db/dbCliente.dart';

class ListarRuta extends StatelessWidget {
  final DatabaseHelperRuta dbHelperRuta = DatabaseHelperRuta();
  final DatabaseHelperDetalleRuta dbHelperDetalleRuta =
      DatabaseHelperDetalleRuta();
  final DatabaseHelperCliente dbHelperCliente = DatabaseHelperCliente();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rutas'),
      ),
      body: FutureBuilder<List<Ruta>>(
        future: dbHelperRuta.getRutas(), // Este método debería devolver todas las rutas
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay rutas disponibles'));
          } else {
            final rutas = snapshot.data!;
            return ListView.builder(
              itemCount: rutas.length,
              itemBuilder: (context, index) {
                final ruta = rutas[index];
                return FutureBuilder<Localidad>(
                  future: dbHelperRuta.getLocalidadById(ruta.idLocalidad),
                  builder: (context, localidadSnapshot) {
                    if (localidadSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Cargando...'),
                        ),
                      );
                    } else if (localidadSnapshot.hasError) {
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Error al cargar la localidad'),
                        ),
                      );
                    } else if (!localidadSnapshot.hasData) {
                      return Card(
                        margin: EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text('Localidad no encontrada'),
                        ),
                      );
                    } else {
                      final localidad = localidadSnapshot.data!;
                      final estadoRuta = (ruta.fechaFin.isEmpty)
                          ? 'No finalizada'
                          : 'Finalizada';
                      final syncedStatus = ruta.sincronizado == 1
                          ? 'Sincronizada'
                          : 'No sincronizada';
                      final fechaInicio = _formatearFecha(ruta.fechaInicio);
                      final fechaFin = _formatearFecha(ruta.fechaFin);

                      return Card(
                        margin: EdgeInsets.all(8.0),
                        elevation: 5.0,
                        child: ListTile(
                          contentPadding: EdgeInsets.all(16.0),
                          title: Text('Ruta: ${localidad.nombre}'),
                          subtitle: Text(
                            'Estado: $estadoRuta\n'
                            'Fecha de inicio: $fechaInicio\n'
                            'Fecha de fin: $fechaFin\n'
                            'Sincronización: $syncedStatus\n'
                            'Número de Ruta: ${ruta.numRuta}', // Aquí se muestra numPedido
                          ),
                          onTap: () {
                            _showRutaDetails(context, ruta.id);
                          },
                        ),
                      );
                    }
                  },
                );
              },
            );
          }
        },
      ),
    );
  }


  String _transformarEstado(String estado) {
    switch (estado) {
      case 'NV':
        return 'No Visitado';
      case 'O':
        return 'Ordenado';
      case 'A':
        return 'Ausente';
      case 'V':
        return 'Visitado';
      default:
        return 'No Visitado';
    }
  }

  void _showRutaDetails(BuildContext context, int rutaId) async {
    final detalles = await dbHelperDetalleRuta.getDetallesRutaPorRuta(rutaId);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalles de la Ruta: $rutaId'),
          content: detalles.isEmpty
              ? Text('No hay detalles para esta ruta')
              : Container(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: detalles.length,
                    itemBuilder: (context, index) {
                      final detalle = detalles[index];
                      return FutureBuilder<String?>(
                        future: dbHelperCliente.getClienteNombre(detalle.codCliente),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return ListTile(
                              title: Text('Cargando...'),
                            );
                          } else if (snapshot.hasError) {
                            return ListTile(
                              title: Text('Error al cargar nombre del cliente'),
                            );
                          } else {
                            final clienteNombre = snapshot.data ?? 'Desconocido';
                            final estadoTransformado = _transformarEstado(detalle.estado);
                            return ListTile(
                              title: Text('Cliente: $clienteNombre'),
                              subtitle: Text(
                                'Estado: $estadoTransformado\n'
                                'Observaciones: ${detalle.observaciones}\n'
                                'Pedido: ${detalle.idPedido}',
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String _formatearFecha(String? fecha) {
    if (fecha == null || fecha.length < 16) {
      return 'No disponible';
    }
    return fecha.substring(0, 16);
  }
}
