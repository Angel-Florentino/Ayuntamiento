import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CPassword extends StatefulWidget {
  @override
  _CPasswordState createState() => _CPasswordState();
}

class _CPasswordState extends State<CPassword> {
  List<Map<String, dynamic>> _usuarios = [];
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

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

  Future<void> _verUsuarios() async {
    showLoadingDialog(context);
    try {
      final response = await http.get(Uri.parse(
          'https://a4c9-2806-10ae-16-7e24-50e3-d50b-ea77-b605.ngrok-free.app/api/ver_usuarios.php'));

      if (response.statusCode == 200) {
        setState(() {
          _usuarios =
              List<Map<String, dynamic>>.from(json.decode(response.body));
        });
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al obtener los usuarios'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en la conexión con el servidor'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cambiarContrasena() async {
    final nombreUsuario = _usernameController.text;
    final nuevaContrasena = _passwordController.text;

    if (nombreUsuario.isEmpty || nuevaContrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ambos campos son obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showLoadingDialog(context);

    try {
      final response = await http.post(
        Uri.parse(
            'https://a4c9-2806-10ae-16-7e24-50e3-d50b-ea77-b605.ngrok-free.app/api/cam_password.php'),
        body: {
          'nombre_usuario': nombreUsuario,
          'nueva_contrasena': nuevaContrasena,
        },
      );

      final responseData = json.decode(response.body);

      Navigator.pop(context);

      if (response.statusCode == 200) {
        if (responseData['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Contraseña actualizada con éxito'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cambiar la contraseña'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error en la conexión con el servidor'),
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
          'Cambiar Contraseña',
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
            ElevatedButton(
              onPressed: _verUsuarios,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA41F1E),
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: const Text(
                'Ver Usuarios Registrados',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            if (_usuarios.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(
                      label: Text(
                        'Nombre Completo',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA41F1E),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Nombre de Usuario',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFA41F1E),
                        ),
                      ),
                    ),
                  ],
                  rows: _usuarios.map((usuario) {
                    return DataRow(cells: [
                      DataCell(Text(usuario['nombre_completo'] ?? 'No Nombre')),
                      DataCell(Text(usuario['nombre_usuario'] ?? 'No Usuario')),
                    ]);
                  }).toList(),
                ),
              ),
            if (_usuarios.isNotEmpty) const SizedBox(height: 20),
            const Text(
              'Ingrese el Nombre de Usuario',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA41F1E),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                labelText: 'Nombre de Usuario',
                labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Color(0xFFA41F1E)),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ingrese la Nueva Contraseña',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA41F1E),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Nueva Contraseña',
                labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock, color: Color(0xFFA41F1E)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _cambiarContrasena,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA41F1E),
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: const Text(
                'Cambiar Contraseña',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
