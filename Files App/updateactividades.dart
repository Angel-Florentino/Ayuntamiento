import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class UpdateActividades extends StatefulWidget {
  @override
  _UpdateActividadesState createState() => _UpdateActividadesState();
}

class _UpdateActividadesState extends State<UpdateActividades> {
  final TextEditingController _notasController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final ImagePicker _picker = ImagePicker();

  List<dynamic> actividades = [];
  List<dynamic> filteredActividades = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _selectedArea = 'Agua y Saneamiento';

  String? _imagen1;
  String? _imagen2;

  Future<void> _getActividades() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(
        'https://a4c9-2806-10ae-16-7e24-50e3-d50b-ea77-b605.ngrok-free.app/api/ver_actividades.php',
      ));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          setState(() {
            actividades = responseData['actividades'];
            _filterActividadesByArea();
          });
        } else {
          setState(() {
            _errorMessage = 'No se encontraron actividades';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Error al cargar las actividades';
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = 'Error de conexión: $error';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterActividadesByArea() {
    setState(() {
      filteredActividades = actividades
          .where((actividad) => actividad['area'] == _selectedArea)
          .toList();
    });
  }

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

  Future<void> _updateActivity() async {
    if (_idController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingresa un ID de actividad válido'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_notasController.text.isNotEmpty ||
        _imagen1 != null ||
        _imagen2 != null) {
      setState(() {
        _isLoading = true;
      });

      String? imagen1Base64 = _imagen1 != null
          ? base64Encode(File(_imagen1!).readAsBytesSync())
          : null;
      String? imagen2Base64 = _imagen2 != null
          ? base64Encode(File(_imagen2!).readAsBytesSync())
          : null;

      final Map<String, String> data = {
        'id': _idController.text.trim(),
        'notas': _notasController.text,
        'imagen1': imagen1Base64 ?? '',
        'imagen2': imagen2Base64 ?? '',
      };

      try {
        final response = await http.post(
          Uri.parse(
              'https://a4c9-2806-10ae-16-7e24-50e3-d50b-ea77-b605.ngrok-free.app/api/update_act.php'),
          headers: {'Content-Type': 'application/x-www-form-urlencoded'},
          body: data,
        );

        if (response.statusCode == 200) {
          final jsonResponse = json.decode(response.body);
          if (jsonResponse['status'] == 'success') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Actividad actualizada exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${jsonResponse['message']}'),
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Por favor, complete todos los campos antes de actualizar la actividad'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Actualizar Notas',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFA41F1E),
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            DropdownButton<String>(
              value: _selectedArea,
              onChanged: (String? newValue) {
                setState(() {
                  _selectedArea = newValue!;
                  _filterActividadesByArea();
                });
              },
              items: const [
                'Agua y Saneamiento',
                'Obras Públicas',
                'Parques y Jardines'
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getActividades,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA41F1E),
                padding: const EdgeInsets.symmetric(vertical: 15),
                textStyle:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              child: const Text('Ver Actividades Registradas',
                  style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFFA41F1E)))
                : _errorMessage.isNotEmpty
                    ? Text(_errorMessage,
                        style: const TextStyle(color: Colors.red))
                    : filteredActividades.isEmpty
                        ? const Center(
                            child: Text('No hay Actividades Registradas',
                                style: TextStyle(
                                    color: Colors.grey, fontSize: 18)),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: filteredActividades.length,
                            itemBuilder: (ctx, index) {
                              final actividad = filteredActividades[index];
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: ListTile(
                                  title: Text(
                                    'ID: ${actividad['id']} - ${actividad['nombre_actividad']}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Área: ${actividad['area']}',
                                          style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14)),
                                      Text(
                                          'Ubicación: ${actividad['ubicacion']}',
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                      Text(
                                          'Descripción: ${actividad['descripcion']}',
                                          style: const TextStyle(
                                              color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
            const SizedBox(height: 20),
            const Text('Actualizar Actividades',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _idController,
              decoration: const InputDecoration(
                labelText: 'ID de la Actividad',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _notasController,
              decoration: const InputDecoration(
                labelText: 'Notas',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _imagen1 == null
                    ? ElevatedButton(
                        onPressed: () => _pickImage(1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA41F1E),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Seleccionar Imagen 1',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                      )
                    : Image.file(File(_imagen1!), width: 100, height: 100),
                _imagen2 == null
                    ? ElevatedButton(
                        onPressed: () => _pickImage(2),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFA41F1E),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                        child: const Text('Seleccionar Imagen 2',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14)),
                      )
                    : Image.file(File(_imagen2!), width: 100, height: 100),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateActivity,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA41F1E),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text('Actualizar Actividad',
                  style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
