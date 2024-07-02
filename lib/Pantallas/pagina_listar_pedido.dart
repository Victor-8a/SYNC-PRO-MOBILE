import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/Pantallas/pagina_pedidos.dart';
import 'package:sync_pro_mobile/db/dbPedidos.dart'; // Asegúrate de que esta importación esté correcta
import 'package:sync_pro_mobile/db/dbDetallePedidos.dart'; // Asegúrate de que esta importación esté correcta
class PaginaListarPedidos extends StatefulWidget {
  const PaginaListarPedidos({Key? key}) : super(key: key);

  @override
  _PaginaListarPedidosState createState() => _PaginaListarPedidosState();
}

class _PaginaListarPedidosState extends State<PaginaListarPedidos> {
  late List<Map<String, dynamic>> _orders;
  List<Map<String, dynamic>> _filteredOrders = [];

  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() async {
    _orders = await DatabaseHelperPedidos().getOrdersWithClientAndSeller();
    _filteredOrders = List.from(_orders); // Copia de la lista original
    setState(() {});
  }

  void _filterOrders(String searchText) {
    _filteredOrders.clear();
    if (searchText.isEmpty) {
      _filteredOrders.addAll(_orders);
    } else {
      _filteredOrders.addAll(_orders.where((order) => order['nombreCliente']
          .toLowerCase()
          .contains(searchText.toLowerCase())));
    }
    setState(() {});
  }

  void _showOrderDetailsDialog(BuildContext context, int orderId, int numPedido) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalle del Pedido $numPedido'),
          content: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseHelperDetallePedidos().getUnsyncedOrderDetails(orderId),
            builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay detalles del pedido disponibles.'));
              } else {
                final orderDetails = snapshot.data!;
                double total = orderDetails.fold(0.0, (sum, detail) {
                  double precioConDescuento = detail['PrecioVenta'] * (1 - detail['PorcDescuento'] / 100);
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
                            double precioConDescuento = detail['PrecioVenta'] * (1 - detail['PorcDescuento'] / 100);
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Producto: ${detail['CodArticulo']}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0,
                                      ),
                                    ),
                                    const SizedBox(height: 4.0),
                                    Text('Descripción: ${detail['Descripcion']}'),
                                    const SizedBox(height: 4.0),
                                    Text('Cantidad: ${detail['Cantidad']}'),
                                    const SizedBox(height: 4.0),
                                    Text('Precio: Q${detail['PrecioVenta']}'),
                                    const SizedBox(height: 4.0),
                                    Text('Descuento: ${detail['PorcDescuento']}%'),
                                    const SizedBox(height: 4.0),
                                    Text('Subtotal: Q${(precioConDescuento * detail['Cantidad']).toStringAsFixed(2)}'),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Buscar por cliente',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterOrders,
            ),
          ),
          Expanded(
            child: _filteredOrders.isEmpty
                ? Center(child: Text('No se encontraron resultados'))
                : ListView.builder(
                    itemCount: _filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = _filteredOrders[index];
                      final String syncedStatus = order['synced'] == 1 ? 'Sincronizado' : 'No sincronizado';
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: InkWell(
                          onTap: () {
                            final int orderId = order['id'];
                            _showOrderDetailsDialog(context, orderId, order['NumPedido']);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pedido: ${order['id']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
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
                                Text('Fecha Entrega: ${order['FechaEntrega'].substring(0, 10)}'),
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
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PaginaPedidos(cliente: null)),
                    );
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
          ),
        ],
      ),
    );
  }
}
