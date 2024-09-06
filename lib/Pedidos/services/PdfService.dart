import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';


class PdfViewerPage extends StatefulWidget {
  final String path;

  PdfViewerPage({required this.path});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String? savedFilePath;
  String? sharedFileName; // Nombre utilizado al compartir por primera vez

  @override
  void initState() {
    super.initState();
    _loadSavedFilePath();
  }

  Future<void> _loadSavedFilePath() async {
    final prefs = await SharedPreferences.getInstance();
    savedFilePath = prefs.getString(widget.path);
    setState(() {}); // Actualiza el estado para reflejar el cambio
  }

  Future<void> _saveFilePath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(widget.path, path);
    setState(() {
      savedFilePath = path; // Actualiza savedFilePath con la nueva ruta
    });
  }

  Future<void> _savePdfToDevice(BuildContext context) async {
    final directory = await getExternalStorageDirectory();
    final fileName = await _getFileNameFromUser(context);

    if (fileName != null && fileName.isNotEmpty) {
      final filePath = '${directory!.path}/$fileName.pdf';
      final File file = File(filePath);

      try {
        await file.writeAsBytes(await File(widget.path).readAsBytes());
        await _saveFilePath(filePath);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF guardado correctamente en $fileName.pdf')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el PDF')),
        );
      }
    }
  }

  Future<void> _sharePdf(BuildContext context) async {
    final directory = await getExternalStorageDirectory();
    final fileName = await _getFileNameFromUser(context);

    if (fileName != null && fileName.isNotEmpty) {
      final filePath = '${directory!.path}/$fileName.pdf';
      final File file = File(filePath);

      try {
        await file.writeAsBytes(await File(widget.path).readAsBytes());
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('PDF guardado temporalmente en $fileName.pdf')),
        );

        final xFile = XFile(filePath);
        await Share.shareXFiles([xFile], text: 'Compartir PDF');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al compartir el PDF')),
        );
      }
    }
  }

  Future<String?> _getFileNameFromUser(BuildContext context) async {
    TextEditingController controller = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nombre del archivo'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Ingrese el nombre del archivo'),
          ),
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
                Navigator.of(context).pop(controller.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _printPdf() async {
    final directory = await getExternalStorageDirectory();
    final fileName = await _getFileNameFromUser(context);

    if (fileName != null && fileName.isNotEmpty) {
      final filePath = '${directory!.path}/$fileName.pdf';
      final File file = File(filePath);

      try {
        await file.writeAsBytes(await File(widget.path).readAsBytes());

        // final pdfFile = File(filePath);
        // await Printing.sharePdf(bytes: await pdfFile.readAsBytes(), filename: fileName);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al imprimir el PDF')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: () => _savePdfToDevice(context),
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => _sharePdf(context),
          ),
          IconButton(
            icon: Icon(Icons.print),
            onPressed: () => _printPdf(),
          ),
        ],
      ),
      body: PDFView(
        filePath: widget.path,
      ),
    );
  }
}
