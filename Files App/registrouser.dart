import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Registrouser extends StatefulWidget {
  @override
  _RegistrouserState createState() => _RegistrouserState();
}

class _RegistrouserState extends State<Registrouser> {
  final _nombreController = TextEditingController();
  final _areaController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _usuarioController = TextEditingController();
  final _contrasenaController = TextEditingController();
  String? _rolSeleccionado = 'Usuario';
  List<Map<String, dynamic>> _usuarios = [];

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Center(
          child: CircularProgressIndicator(
            color: Color(0xFFA41F1E),
          ),
        );
      },
    );
  }

  void _registrarUsuario() async {
    if (_nombreController.text.isEmpty ||
        _areaController.text.isEmpty ||
        _correoController.text.isEmpty ||
        _telefonoController.text.isEmpty ||
        _usuarioController.text.isEmpty ||
        _contrasenaController.text.isEmpty ||
        _rolSeleccionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, rellena todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
    } else {
      showLoadingDialog(context);
      try {
        final response = await http.post(
          Uri.parse(
              'https://a4c9-2806-10ae-16-7e24-50e3-d50b-ea77-b605.ngrok-free.app/api/registrar_usuario.php'),
          body: {
            'nombre_completo': _nombreController.text,
            'area': _areaController.text,
            'correo': _correoController.text,
            'telefono': _telefonoController.text,
            'nombre_usuario': _usuarioController.text,
            'contrasena': _contrasenaController.text,
            'rol': _rolSeleccionado!,
          },
        );
        Navigator.pop(context);

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Usuario registrado con éxito',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.green,
            ),
          );

          _nombreController.clear();
          _areaController.clear();
          _correoController.clear();
          _telefonoController.clear();
          _usuarioController.clear();
          _contrasenaController.clear();
          setState(() {
            _rolSeleccionado = 'Usuario';
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error al registrar el usuario',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error en la conexión con el servidor',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _verUsuarios() async {
    showLoadingDialog(context);
    final response = await http.get(Uri.parse(
        'https://a4c9-2806-10ae-16-7e24-50e3-d50b-ea77-b605.ngrok-free.app/api/ver_usuarios.php'));

    if (response.statusCode == 200) {
      setState(() {
        _usuarios = List<Map<String, dynamic>>.from(json.decode(response.body));
      });
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al obtener los usuarios')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Registrar Usuario',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: _verUsuarios,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA41F1E),
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: Text(
                'Ver Usuarios Registrados',
                style: TextStyle(color: Colors.white),
              ),
            ),
            SizedBox(height: 20),
            if (_usuarios.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: [
                    DataColumn(label: Text('Nombre Completo')),
                    DataColumn(label: Text('Nombre de Usuario')),
                  ],
                  rows: _usuarios.map((usuario) {
                    return DataRow(cells: [
                      DataCell(Text(usuario['nombre_completo'] ?? 'No Nombre')),
                      DataCell(Text(usuario['nombre_usuario'] ?? 'No Usuario')),
                    ]);
                  }).toList(),
                ),
              ),
            SizedBox(height: 20),
            Text(
              'Registrar Nuevo Usuario',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA41F1E),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _nombreController,
              decoration: InputDecoration(
                labelText: 'Nombre Completo',
                labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Color(0xFFA41F1E)),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _areaController,
              decoration: InputDecoration(
                labelText: 'Área',
                labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business, color: Color(0xFFA41F1E)),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _correoController,
              decoration: InputDecoration(
                labelText: 'Correo Electrónico',
                labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email, color: Color(0xFFA41F1E)),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _telefonoController,
              decoration: InputDecoration(
                labelText: 'Teléfono',
                labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone, color: Color(0xFFA41F1E)),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _usuarioController,
              decoration: InputDecoration(
                labelText: 'Usuario',
                labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                border: OutlineInputBorder(),
                prefixIcon:
                    Icon(Icons.account_circle, color: Color(0xFFA41F1E)),
              ),
            ),
            SizedBox(height: 20),
            TextFormField(
              controller: _contrasenaController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Contraseña',
                labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock, color: Color(0xFFA41F1E)),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _rolSeleccionado,
              onChanged: (value) {
                setState(() {
                  _rolSeleccionado = value;
                });
              },
              items: ['Usuario', 'Administrador'].map((String role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
              decoration: InputDecoration(
                labelText: 'Rol',
                labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.security, color: Color(0xFFA41F1E)),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _registrarUsuario,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA41F1E),
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: Text(
                'Registrar Usuario',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
