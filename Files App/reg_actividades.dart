import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegActividades extends StatefulWidget {
  @override
  _RegActividadesState createState() => _RegActividadesState();
}

class _RegActividadesState extends State<RegActividades> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _ubicacionController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _notasController = TextEditingController();

  String? _selectedArea;
  String? _imagen1;
  String? _imagen2;

  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage(int imagenIndex) async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (imagenIndex == 1) {
          _imagen1 = pickedFile.path;
        } else {
          _imagen2 = pickedFile.path;
        }
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      String nombre = _nombreController.text;
      String ubicacion = _ubicacionController.text;
      String descripcion = _descripcionController.text;
      String notas = _notasController.text;

      // Convertir imágenes a base64
      String? imagen1Base64 = _imagen1 != null
          ? base64Encode(File(_imagen1!).readAsBytesSync())
          : null;
      String? imagen2Base64 = _imagen2 != null
          ? base64Encode(File(_imagen2!).readAsBytesSync())
          : null;

      final Map<String, dynamic> data = {
        'nombre_actividad': nombre,
        'ubicacion': ubicacion,
        'descripcion': descripcion,
        'notas': notas,
        'area': _selectedArea,
        'imagen1': imagen1Base64 ?? '',
        'imagen2': imagen2Base64 ?? '',
      };

      final Uri url = Uri.parse(
          'https://a4c9-2806-10ae-16-7e24-50e3-d50b-ea77-b605.ngrok-free.app/api/reg_actividades.php');

      try {
        final response = await http.post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(data),
        );

        if (response.statusCode == 200) {
          try {
            final jsonResponse = json.decode(response.body);
            if (jsonResponse['status'] == 'success') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Actividad registrada exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              _formKey.currentState?.reset();
              setState(() {
                _imagen1 = null;
                _imagen2 = null;
                _selectedArea = null;
              });
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error: ${jsonResponse['message']}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al procesar la respuesta'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          throw Exception('Error en la solicitud: ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrar Actividad',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xFFA41F1E),
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: <Widget>[
                  TextFormField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la Actividad',
                      labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.event, color: Color(0xFFA41F1E)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un nombre';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedArea,
                    decoration: InputDecoration(
                      labelText: 'Área',
                      labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                      border: OutlineInputBorder(),
                      prefixIcon:
                          Icon(Icons.category, color: Color(0xFFA41F1E)),
                    ),
                    items: [
                      'Agua y Saneamiento',
                      'Obras Públicas',
                      'Parques y Jardines'
                    ].map((String area) {
                      return DropdownMenuItem<String>(
                        value: area,
                        child: Text(area),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedArea = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor seleccione un área';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _ubicacionController,
                    decoration: InputDecoration(
                      labelText: 'Ubicación',
                      labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                      border: OutlineInputBorder(),
                      prefixIcon:
                          Icon(Icons.location_on, color: Color(0xFFA41F1E)),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la ubicación';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _descripcionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción',
                      labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                      border: OutlineInputBorder(),
                      prefixIcon:
                          Icon(Icons.description, color: Color(0xFFA41F1E)),
                    ),
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una descripción';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _notasController,
                    decoration: InputDecoration(
                      labelText: 'Notas',
                      labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note, color: Color(0xFFA41F1E)),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _imagen1 == null
                          ? ElevatedButton(
                              onPressed: () => _pickImage(1),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFA41F1E),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                textStyle: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              child: Text(
                                'Seleccionar Imagen 1',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            )
                          : Image.file(File(_imagen1!),
                              width: 100, height: 100),
                      _imagen2 == null
                          ? ElevatedButton(
                              onPressed: () => _pickImage(2),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFFA41F1E),
                                padding: EdgeInsets.symmetric(vertical: 15),
                                textStyle: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              child: Text(
                                'Seleccionar Imagen 2',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              ),
                            )
                          : Image.file(File(_imagen2!),
                              width: 100, height: 100),
                    ],
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFA41F1E),
                      padding: EdgeInsets.symmetric(vertical: 15),
                      textStyle:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    child: Text(
                      'Registrar Actividad',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFA41F1E),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
