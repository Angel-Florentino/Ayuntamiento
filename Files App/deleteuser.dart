import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeleteUser extends StatefulWidget {
  @override
  _DeleteUserState createState() => _DeleteUserState();
}

class _DeleteUserState extends State<DeleteUser> {
  List<Map<String, dynamic>> _usuarios = [];
  final _usuarioController = TextEditingController();

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
          SnackBar(content: Text('Error al obtener los usuarios')),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error en la conexión con el servidor')),
      );
    }
  }

  Future<void> _eliminarUsuario() async {
    if (_usuarioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Por favor, ingrese el nombre de usuario'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showLoadingDialog(context);
    try {
      final response = await http.post(
        Uri.parse(
            'https://a4c9-2806-10ae-16-7e24-50e3-d50b-ea77-b605.ngrok-free.app/api/eliminar_user.php'),
        body: {'nombre_usuario': _usuarioController.text},
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(responseData['message']),
              backgroundColor: Colors.green,
            ),
          );
          _usuarioController.clear();
          _verUsuarios();
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
            content: Text('Error al eliminar el usuario'),
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
          'Eliminar Usuario',
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
            const SizedBox(height: 20),
            const Text(
              'Ingrese el Nombre de Usuario a Eliminar',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA41F1E),
              ),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _usuarioController,
              decoration: InputDecoration(
                labelText: 'Nombre de Usuario',
                labelStyle: TextStyle(color: Color(0xFFA41F1E)),
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person, color: Color(0xFFA41F1E)),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _eliminarUsuario,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA41F1E),
                padding: EdgeInsets.symmetric(vertical: 15),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              child: const Text(
                'Eliminar Usuario',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
