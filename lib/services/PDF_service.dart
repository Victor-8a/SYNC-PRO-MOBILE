import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart'; // Importar el paquete share_plus

class PdfViewerPage extends StatelessWidget {
  final String path;

  PdfViewerPage({required this.path});

  Future<void> _savePdfToDevice(BuildContext context) async {
    final directory = await getExternalStorageDirectory(); // Obtener directorio de almacenamiento externo
    final fileName = 'pedido_pdf.pdf'; // Nombre del archivo PDF que se guardará
    final File file = File('${directory!.path}/$fileName');

    try {
      await file.writeAsBytes(await File(path).readAsBytes()); // Copiar el archivo PDF al nuevo directorio
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF guardado correctamente en $fileName')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar el PDF')),
      );
    }
  }
Future<void> _sharePdf(BuildContext context) async {
  try {
    final directory = await getExternalStorageDirectory(); // Obtener directorio de almacenamiento externo
    final fileName = 'pedido_pdf.pdf'; // Nombre del archivo PDF que se guardará
    final filePath = '${directory!.path}/$fileName';

    // Convertir la ruta de archivo a XFile
    final xFile = XFile(filePath);

    await Share.shareXFiles([xFile], text: 'Compartir PDF'); // Compartir el archivo usando share_plus
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al compartir el PDF')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _savePdfToDevice(context),
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _sharePdf(context),
          ),
        ],
      ),
      body: PDFView(
        filePath: path,
      ),
    );
  }
}
