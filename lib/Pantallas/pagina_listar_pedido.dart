import 'package:flutter/material.dart';
import 'package:sync_pro_mobile/db/dbPedidos.dart'; // Asegúrate de que esta importación esté correcta
import 'package:sync_pro_mobile/db/dbDetallePedidos.dart'; // Asegúrate de que esta importación esté correcta

class PaginaListarPedidos extends StatelessWidget {
  const PaginaListarPedidos({Key? key}) : super(key: key);

  void _showOrderDetailsDialog(BuildContext context, int orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Detalle del Pedido $orderId'),
          content: FutureBuilder<List<Map<String, dynamic>>>(
            future: DatabaseHelperDetallePedidos().getUnsyncedOrderDetails(orderId), // Asegúrate de que este método exista y esté correctamente implementado
            builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('No hay detalles del pedido disponibles.'));
              } else {
                final orderDetails = snapshot.data!;
                return Container(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: orderDetails.length,
                    itemBuilder: (context, index) {
                      final detail = orderDetails[index];
                      return ListTile(
                        title: Text('Producto: ${detail['CodArticulo']}'),
                        subtitle: Text(
                          'Descripción: ${detail['Descripcion']} - Cantidad: ${detail['Cantidad']} - Precio: ${detail['PrecioVenta']}   - Total: ${detail['Total']}',
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
     
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelperPedidos().getOrdersWithClientAndSeller(), // Asegúrate de que este método exista y esté correctamente implementado
        builder: (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay detalles de pedidos disponibles.'));
          } else {
            final orders = snapshot.data!;
            return ListView.builder(
              itemCount: orders.length,
              itemBuilder: (context, index) {
                final order = orders[index];
                final String syncedStatus = order['synced'] == 1 ? 'Sincronizado' : 'No sincronizado';
                return ListTile(
                  title: Text('Vendedor: ${order['nombreVendedor']} '),
                  subtitle: Text(
                    'Cliente: ${order['nombreCliente']} - Fecha Entrega: ${order['FechaEntrega']} - Observaciones: ${order['Observaciones']} - Estado: $syncedStatus',
                  ),
                  onTap: () {
                    _showOrderDetailsDialog(context, order['id']); // Pasa el ID del pedido
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}
