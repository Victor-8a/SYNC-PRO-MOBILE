import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sync_pro_mobile/Pedidos/Models/Cliente.dart';
import 'package:sync_pro_mobile/Pedidos/PantallasSecundarias/PaginaPedidos.dart';
import 'package:sync_pro_mobile/Pedidos/db/dbConfiguraciones.dart';
import 'package:sync_pro_mobile/Pedidos/db/dbDetallePedidos.dart';
import 'package:sync_pro_mobile/Pedidos/db/dbEmpresa.dart';
import 'package:sync_pro_mobile/Pedidos/db/dbPedidos.dart';
import 'package:sync_pro_mobile/Pedidos/db/dbVendedores.dart';
import 'package:sync_pro_mobile/Pedidos/services/ClienteService.dart';
import 'package:sync_pro_mobile/Pedidos/services/PdfService.dart'; // Asegúrate de que esta importación esté correcta
// import 'package:google_fonts/google_fonts.dart'; // Importa Google Fonts

class PaginaListarPedidos extends StatefulWidget {
  const PaginaListarPedidos({Key? key}) : super(key: key);

  @override
  _PaginaListarPedidosState createState() => _PaginaListarPedidosState();
}

class _PaginaListarPedidosState extends State<PaginaListarPedidos> {
  late List<Map<String, dynamic>> _orders;
  List<Map<String, dynamic>> _filteredOrders = [];
  bool _usaRuta = false;
  final _databaseHelperConfiguraciones = DatabaseHelperConfiguraciones();

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _loadOrders();
    super.initState();
    _tryFetchAndStoreVendedores();
    insertarCliente();

    _initializeConfiguration();
  }

  void _loadOrders() async {
    // Proceder con la carga de órdenes
    _orders = await DatabaseHelperPedidos().getOrdersWithClientAndSeller();
    setState(() {
      _filteredOrders = List.from(_orders); // Copia de la lista original
    });
  }

  Future<void> _initializeConfiguration() async {
    await _loadConfiguracion();
  }

  void _filterOrders(String searchText) {
    _filteredOrders.clear();
    if (searchText.isEmpty) {
      _filteredOrders.addAll(_orders);
    } else {
      searchText = searchText.toLowerCase();
      _filteredOrders.addAll(_orders.where((order) {
        return order.values.any(
            (value) => value.toString().toLowerCase().contains(searchText));
      }));
    }
    setState(() {});
  }

// Dentro de la página anterior donde se recibe el valor de retorno:

  void _showOrderDetailsDialog(
      BuildContext context, int orderId, int numPedido) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalle del Pedido $numPedido'),
          content: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseHelperDetallePedidos()
                .getOrderDetailsWithProductos(orderId),
            builder: (BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                    child: Text('No hay detalles del pedido disponibles.'));
              } else {
                final orderDetails = snapshot.data!;
                double total = orderDetails.fold(0.0, (sum, detail) {
                  double precioConDescuento = detail['PrecioVenta'] *
                      (1 - detail['PorcDescuento'] / 100);
                  return sum + (precioConDescuento * detail['Cantidad']);
                });
                return Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: orderDetails.length,
                          itemBuilder: (context, index) {
                            final detail = orderDetails[index];
                            double precioConDescuento = detail['PrecioVenta'] *
                                (1 - detail['PorcDescuento'] / 100);
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Producto: ${detail['barras']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text(
                                        'Descripción: ${detail['Descripcion']}'),
                                    const SizedBox(height: 4.0),
                                    Text('Cantidad: ${detail['Cantidad']}'),
                                    const SizedBox(height: 4.0),
                                    Text('Precio: Q${detail['PrecioVenta']}'),
                                    const SizedBox(height: 4.0),
                                    Text(
                                        'Descuento: ${detail['PorcDescuento']}%'),
                                    const SizedBox(height: 4.0),
                                    Text(
                                        'Subtotal: Q${(precioConDescuento * detail['Cantidad']).toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final empresa =
                              await DatabaseHelperEmpresa().getEmpresa();
                          final pedido = await DatabaseHelperPedidos()
                              .getOrderById(orderId);

                          final pdf = pw.Document();

                          final directory =
                              await getApplicationDocumentsDirectory();
                          final imagesDirectory =
                              Directory('${directory.path}/images');
                          final logoFile =
                              File('${imagesDirectory.path}/logo.png');

                          final logoImage =
                              pw.MemoryImage(logoFile.readAsBytesSync());

                          pdf.addPage(
                            pw.Page(
                              pageFormat: PdfPageFormat(
                                  80 * PdfPageFormat.mm, double.infinity),
                              build: (pw.Context context) {
                                return pw.Container(
                                  padding: pw.EdgeInsets.all(5.0),
                                  child: pw.Column(
                                    crossAxisAlignment:
                                        pw.CrossAxisAlignment.start,
                                    children: [
                                      pw.Center(
                                          child: pw.Image(logoImage,
                                              width: 100,
                                              height:
                                                  100)), // Añadir la imagen aquí
                                      pw.SizedBox(height: 20),
                                      pw.Center(
                                        child: pw.Text('${empresa?['Empresa']}',
                                            style: pw.TextStyle(fontSize: 14)),
                                      ),
                                      pw.Center(
                                        child: pw.Text('${empresa?['Cedula']}',
                                            style: pw.TextStyle(fontSize: 12)),
                                      ),
                                      pw.Center(
                                        child: pw.Text(
                                            '${empresa?['Telefono01']}',
                                            style: pw.TextStyle(fontSize: 12)),
                                      ),
                                      pw.Center(
                                        child: pw.Text(
                                            '${empresa?['Direccion']}',
                                            style: pw.TextStyle(fontSize: 10)),
                                      ),
                                      pw.Center(
                                        child: pw.Text('${empresa?['Email']}',
                                            style: pw.TextStyle(fontSize: 12)),
                                      ),
                                      pw.Center(
                                        child: pw.Text(
                                            '------------------------------------------------',
                                            style: pw.TextStyle(fontSize: 12)),
                                      ),

                                      pw.Text(
                                          'Cliente: ${pedido?['nombreCliente']}'),
                                      pw.Text(
                                          'Fecha de Entrega: ${pedido?['FechaEntrega'].substring(0, 10)}'),

                                      pw.Text('Detalle del Pedido $orderId',
                                          style: pw.TextStyle(
                                              fontSize: 12,
                                              fontWeight: pw.FontWeight.bold)),
                                      pw.SizedBox(height: 12),

                                      pw.Text('DESCRIPCION PRODUCTO',
                                          style: pw.TextStyle(fontSize: 10)),
                                      pw.Text(
                                          'CANT |PRECIO UNIT| DESC  |IMPORTE',
                                          style: pw.TextStyle(fontSize: 10)),
                                      pw.Center(
                                        child: pw.Text(
                                            '------------------------------------------------',
                                            style: pw.TextStyle(fontSize: 12)),
                                      ),
                                      for (var detail in orderDetails)
                                        pw.Column(
                                          crossAxisAlignment:
                                              pw.CrossAxisAlignment.start,
                                          children: [
                                            pw.Text('${detail['Descripcion']}',
                                                style:
                                                    pw.TextStyle(fontSize: 10)),
                                            pw.Text(
                                                '${detail['Cantidad']}                 Q${detail['PrecioVenta']}        ${detail['PorcDescuento']}%     Q${detail['Total']} ',
                                                style:
                                                    pw.TextStyle(fontSize: 10)),
                                          ],
                                        ),
                                      pw.Center(
                                        child: pw.Text(
                                            '------------------------------------------------',
                                            style: pw.TextStyle(fontSize: 12)),
                                      ),
                                      pw.Text(
                                        'Total: Q${orderDetails.fold<double>(0.0, (sum, detail) => sum + (detail['PrecioVenta'] * (1 - detail['PorcDescuento'] / 100) * detail['Cantidad'])).toStringAsFixed(2)}',
                                        style: pw.TextStyle(
                                            fontSize: 12,
                                            fontWeight: pw.FontWeight.bold),
                                      ),
                                      pw.Center(
                                        child: pw.Text(
                                            '*****************************',
                                            style: pw.TextStyle(fontSize: 12)),
                                      ),
                                      pw.Center(
                                        child: pw.Text('${empresa?['Frase']}',
                                            style: pw.TextStyle(fontSize: 10)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          );

                          final output = await getTemporaryDirectory();
                          final file =
                              File('${output.path}/pedido_$orderId.pdf');
                          await file.writeAsBytes(await pdf.save());

                          Navigator.of(context)
                              .pop(); // Cerrar diálogo de confirmación

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  PdfViewerPage(path: file.path),
                            ),
                          );
                        },
                        child: Text('Generar PDF'),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Total: Q${total.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cerrar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadConfiguracion() async {
    bool usaRuta = await _databaseHelperConfiguraciones.getUsaRuta();
    setState(() {
      _usaRuta = usaRuta;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(children: [
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  labelText: 'Buscar',
                  prefixIcon: Icon(Icons.search),
                  prefixIconColor: Colors.blue,
                  border: OutlineInputBorder(),
                ),
                onChanged: _filterOrders,
              ),
            ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () async {
                _loadOrders(); // Llama a la función para recargar los pedidos
              },
            ),
          ],
        ),
      ),
      Expanded(
        child: _filteredOrders.isEmpty
            ? Center(child: Text('No se encontraron resultados'))
            : ListView.builder(
                itemCount: _filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];
                  final String syncedStatus =
                      order['synced'] == 1 ? 'Sincronizado' : 'No sincronizado';
                  return Card(
                    margin: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                    child: InkWell(
                      onTap: () {
                        final int orderId = order['id'];
                        _showOrderDetailsDialog(
                            context, orderId, order['NumPedido']);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Pedido: ${order['id']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    confirmDeleteOrder(context, order['id']);
                                  },
                                ),
                              ],
                            ),
                            Text(
                              'Cliente: ${order['nombreCliente']}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            const SizedBox(height: 4.0),
                            Text('Numero de Pedido: ${order['NumPedido']}'),
                            const SizedBox(height: 4.0),
                            Text('Vendedor: ${order['nombreVendedor']}'),
                            const SizedBox(height: 4.0),
                            Text(
                                'Fecha Entrega: ${order['FechaEntrega'].substring(0, 10)}'),
                            const SizedBox(height: 4.0),
                            Text('Estado: $syncedStatus'),
                            const SizedBox(height: 4.0),
                            Text('Observaciones: ${order['Observaciones']}'),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 5,
              ),
              onPressed: _usaRuta
                  ? null // Deshabilita el botón si usaRuta es verdadero
                  : () async {
                      // Llama a la función asíncrona
                      await _loadConfiguracion();
                      // Navega a la página de pedidos
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PaginaPedidos(
                            cliente: Cliente(
                                codCliente: 0,
                                nombre: '',
                                cedula: '',
                                direccion: ''),
                          ),
                        ),
                      ).then((_) {
                     _loadOrders();
                  });
                    },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.add, color: Colors.white),
                ],
              ),
            ),
          ],
        ),
      )
    ]));
  }

  void insertarCliente() async {
    ClienteService clienteService = ClienteService();
    clienteService.insertarCliente(); // Asegúrate de usar el nombre correcto
  }

  Future<bool> _tryFetchAndStoreVendedores() async {
    try {
      return await DatabaseHelperVendedor().fetchAndStoreVendedores();
    } catch (e) {
      print('Error fetching and storing vendedores: $e');
      return false;
    }
  }

// Función para mostrar el cuadro de diálogo de confirmación
  void confirmDeleteOrder(BuildContext context, int orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('¿Estás seguro de que deseas eliminar este pedido?'),
          content: Text(
              'Los pedidos que no estan sincronizados se perderan permanentemente'),
          actions: [
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Cierra el diálogo
                await DatabaseHelperPedidos()
                    .deleteOrder(orderId); // Elimina el pedido y sus detalles
                _loadOrders(); // Recarga la lista de pedidos después de la eliminación
                Fluttertoast.showToast(
                    msg: "Pedido eliminado correctamente",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0);
              },
              child: Text('Eliminar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Solo cierra el diálogo
              },
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );
  }

  // Future<void> showLoadingDialog(BuildContext context) async {
  //   showDialog(
  //     context: context,
  //     barrierDismissible:
  //         false, // Evita que se cierre al tocar fuera del diálogo
  //     builder: (BuildContext context) {
  //       return Dialog(
  //         backgroundColor: Colors.white,
  //         child: Container(
  //           padding: EdgeInsets.all(20),
  //           child: Row(
  //               mainAxisSize: MainAxisSize.max,
  //               children: [
  //                 CircularProgressIndicator(
  //                   valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
  //                 ),
  //                 SizedBox(width: 20),
  //                 Text(
  //                   'Cargando ...',
  //                   style: TextStyle(color: Colors.blue),
  //                 ),
  //                 SizedBox(width: 20),
  //               ],
  //               crossAxisAlignment: CrossAxisAlignment.center),
  //         ),
  //       );
  //     },
  //   );
  // }
}
