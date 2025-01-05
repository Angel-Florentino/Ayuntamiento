import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';

class GenerarReporteScreen extends StatefulWidget {
  const GenerarReporteScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GenerarReporteScreenState createState() => _GenerarReporteScreenState();
}

class _GenerarReporteScreenState extends State<GenerarReporteScreen> {
  DateTime? fechaInicio;
  DateTime? fechaFin;

  String formatDate(DateTime? date) {
    if (date == null) return '';
    return DateFormat('dd/MM/yyyy').format(date);
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFFA41F1E),
          ),
        );
      },
    );
  }

  Future<void> seleccionarFechaInicio() async {
    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );
    if (fecha != null) {
      setState(() {
        fechaInicio = fecha;
      });
    }
  }

  Future<void> seleccionarFechaFin() async {
    DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: const Locale('es', 'ES'),
    );
    if (fecha != null) {
      setState(() {
        fechaFin = fecha;
      });
    }
  }

  Future<void> fetchActividades() async {
    if (fechaInicio == null || fechaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text(
          'Por favor selecciona ambas fechas.',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
      ));
      return;
    }

    String fechaInicioStr = DateFormat('yyyy-MM-dd').format(fechaInicio!);
    String fechaFinStr = DateFormat('yyyy-MM-dd').format(fechaFin!);

    showLoadingDialog(context);

    try {
      final response = await http.post(
        Uri.parse(
            'https://a4c9-2806-10ae-16-7e24-50e3-d50b-ea77-b605.ngrok-free.app/api/obt_actividades.php'),
        body: {
          'fechaInicio': fechaInicioStr,
          'fechaFin': fechaFinStr,
        },
      );
      Navigator.pop(context);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        if (data['status'] == 'success') {
          List actividades = data['actividades'];

          await generatePDF(context, actividades);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'No se encontraron actividades en este rango de fechas',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } else {
        throw Exception(
          'Error al cargar actividades',
        );
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Error al cargar las actividades',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  Future<void> generatePDF(BuildContext context, List actividades) async {
    final pdf = pw.Document();
    showLoadingDialog(context);

    try {
      final List<Map<String, dynamic>> actividadesConImagenes = [];

      for (var actividad in actividades) {
        Uint8List? image1Bytes;
        Uint8List? image2Bytes;

        try {
          if (actividad['imagen1'] != null && actividad['imagen1'].isNotEmpty) {
            final response1 = await http.get(Uri.parse(actividad['imagen1']));
            if (response1.statusCode == 200) {
              image1Bytes = response1.bodyBytes;
            }
          }
          if (actividad['imagen2'] != null && actividad['imagen2'].isNotEmpty) {
            final response2 = await http.get(Uri.parse(actividad['imagen2']));
            if (response2.statusCode == 200) {
              image2Bytes = response2.bodyBytes;
            }
          }
        } catch (e) {
          print('Error al descargar imágenes: $e');
        }

        actividadesConImagenes.add({
          'actividad': actividad,
          'imagen1': image1Bytes,
          'imagen2': image2Bytes,
        });
      }

      // Fecha actual
      final String fechaActual =
          DateFormat('dd/MM/yyyy').format(DateTime.now());

// Genera el PDF
      for (var i = 0; i < actividadesConImagenes.length; i += 2) {
        pdf.addPage(pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                pw.Text(
                  'Gobierno Municipal de Texistepec, Ver.',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 14,
                    color: PdfColors.red,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 15),
                pw.Text(
                  'Reporte de Actividades del Día - $fechaActual',
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 12,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 15),
                for (var j = 0; j < 2; j++)
                  if (i + j < actividadesConImagenes.length)
                    _buildActividad(
                      actividadesConImagenes[i + j]['actividad']
                          as Map<String, dynamic>,
                      actividadesConImagenes[i + j]['imagen1'] as Uint8List?,
                      actividadesConImagenes[i + j]['imagen2'] as Uint8List?,
                    ),
              ],
            );
          },
        ));
      }

      final output = await getExternalStorageDirectory();
      if (output == null)
        throw Exception('Directorio de almacenamiento no encontrado');
      final file = File('${output.path}/reporte_actividades.pdf');
      await file.writeAsBytes(await pdf.save());

      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewScreen(pdfPath: file.path),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'PDF generado correctamente',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      print('Error al generar el PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          'Error al generar el PDF: $e',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
      ));
    }
  }

  pw.Widget _buildActividad(Map<String, dynamic> actividad,
      Uint8List? image1Bytes, Uint8List? image2Bytes) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Área: ${actividad['area']}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 15),
        pw.Text('Nombre: ${actividad['nombre_actividad']}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 15),
        pw.Text('Ubicación: ${actividad['ubicacion'] ?? 'No disponible'}'),
        pw.SizedBox(height: 15),
        pw.Text('Descripción: ${actividad['descripcion'] ?? 'No disponible'}'),
        pw.SizedBox(height: 15),
        pw.Text('Notas: ${actividad['notas'] ?? 'No disponible'}'),
        pw.SizedBox(height: 15),
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceEvenly,
          children: [
            if (image1Bytes != null)
              pw.Image(
                pw.MemoryImage(image1Bytes),
                height: 200,
                width: 200,
                fit: pw.BoxFit.contain,
              ),
            if (image2Bytes != null)
              pw.Image(
                pw.MemoryImage(image2Bytes),
                height: 200,
                width: 200,
                fit: pw.BoxFit.contain,
              ),
          ],
        ),
        pw.SizedBox(height: 20),
        pw.Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Generar Reporte', style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFA41F1E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'En este apartado puedes generar un PDF con las actividades guardadas.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Selecciona el rango de fechas:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA41F1E),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: seleccionarFechaInicio,
                child: Text(
                  fechaInicio == null
                      ? 'Seleccionar fecha de inicio'
                      : 'Inicio: ${formatDate(fechaInicio)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFA41F1E),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: seleccionarFechaFin,
                child: Text(
                  fechaFin == null
                      ? 'Seleccionar fecha de término'
                      : 'Fin: ${formatDate(fechaFin)}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFA41F1E),
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: fetchActividades,
                  child: Text(
                    'Generar PDF',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PDFViewScreen extends StatelessWidget {
  final String pdfPath;

  PDFViewScreen({required this.pdfPath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ver PDF", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFA41F1E),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: Colors.white),
            onPressed: () async {
              try {
                XFile pdfFile = XFile(pdfPath);
                await Share.shareXFiles(
                  [pdfFile],
                );
              } catch (e) {
                print('Error al compartir archivo: $e');
              }
            },
          ),
        ],
      ),
      body: PDFView(
        filePath: pdfPath,
      ),
    );
  }
}
