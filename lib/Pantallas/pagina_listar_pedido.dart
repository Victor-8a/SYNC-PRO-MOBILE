import 'package:flutter/material.dart';
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
      _filteredOrders.addAll(_orders.where((order) =>
          order['nombreCliente'].toLowerCase().contains(searchText.toLowerCase())));
    }
    setState(() {});
  }

  void _showOrderDetailsDialog(BuildContext context, int orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalle del Pedido $orderId'),
          content: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseHelperDetallePedidos().getUnsyncedOrderDetails(
                orderId), // Asegúrate de que este método exista y esté correctamente implementado
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
                return Container(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: orderDetails.length,
                    itemBuilder: (context, index) {
                      final detail = orderDetails[index];
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
                              Text('Precio: ${detail['PrecioVenta']}'),
                              const SizedBox(height: 4.0),
                              Text('Total: ${detail['Total']}'),
                            ],
                          ),
                        ),
                      );
                    },
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
                      final String syncedStatus =
                          order['synced'] == 1 ? 'Sincronizado' : 'No sincronizado';
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4.0, horizontal: 8.0),
                        child: InkWell(
                          onTap: () {
                            final int orderId = order['id'];
                            _showOrderDetailsDialog(
                                context, orderId); // Pasa el ID del pedido
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Vendedor: ${order['nombreVendedor']}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16.0,
                                  ),
                                ),
                                const SizedBox(height: 4.0),
                                Text('Cliente: ${order['nombreCliente']}'),
                                const SizedBox(height: 4.0),
                                Text('Fecha Entrega: ${order['FechaEntrega']}'),
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
        ],
      ),
    );
  }
}
