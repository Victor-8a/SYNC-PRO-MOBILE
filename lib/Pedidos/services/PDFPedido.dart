import 'dart:io';
import 'package:pdf/widgets.dart' as pw;

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:sync_pro_mobile/Pedidos/services/PdfService.dart';
import 'package:sync_pro_mobile/db/dbDetallePedidos.dart';
import 'package:sync_pro_mobile/db/dbEmpresa.dart';
import 'package:sync_pro_mobile/db/dbPedidos.dart';

void showOrderDetailsDialog(
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
                double precioConDescuento =
                    detail['PrecioVenta'] * (1 - detail['PorcDescuento'] / 100);
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
                                  Text('Descripción: ${detail['Descripcion']}'),
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
                        final pedido =
                            await DatabaseHelperPedidos().getOrderById(orderId);

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
                                105 * PdfPageFormat.mm, double.infinity),
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
                                      child: pw.Text('${empresa?['Direccion']}',
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

                                    pw.Text(
                                        'DESCRIPCION PRODUCTO |BARRAS | MARCA |',
                                        style: pw.TextStyle(fontSize: 10)),
                                    pw.Text(
                                        'CANT | PRECIO UNIT | DESC | IMPORTE',
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
                                          pw.Text(
                                              '${detail['Descripcion']}' +
                                                  ' | ${detail['barras']}' +
                                                  ' | ${detail['marcas']}',
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
                        final file = File('${output.path}/pedido_$orderId.pdf');
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
