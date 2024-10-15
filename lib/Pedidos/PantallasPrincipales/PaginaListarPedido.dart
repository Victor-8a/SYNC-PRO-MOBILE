import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sync_pro_mobile/Pedidos/Models/Cliente.dart';
import 'package:sync_pro_mobile/Pedidos/PantallasSecundarias/PaginaPedidos.dart';
import 'package:sync_pro_mobile/Pedidos/services/PDFPedido.dart';
import 'package:sync_pro_mobile/db/dbConfiguraciones.dart';
import 'package:sync_pro_mobile/db/dbPedidos.dart';
import 'package:sync_pro_mobile/db/dbVendedores.dart';
import 'package:sync_pro_mobile/Pedidos/services/ClienteService.dart';

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
                        showOrderDetailsDialog(
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
