import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PasswordUser extends StatefulWidget {
  @override
  _PasswordUserState createState() => _PasswordUserState();
}

class _PasswordUserState extends State<PasswordUser> {
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

  Future<Map<String, dynamic>> cambiarContrasena({
    required String nombreUsuario,
    required String nuevaContrasena,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
            'https://a4c9-2806-10ae-16-7e24-50e3-d50b-ea77-b605.ngrok-free.app/api/cam_password.php'),
        body: {
          'nombre_usuario': nombreUsuario,
          'nueva_contrasena': nuevaContrasena,
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        return {'success': false, 'message': 'Error en la solicitud'};
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error en la conexión con el servidor'
      };
    }
  }

  Future<void> _cambiarContrasena() async {
    final nombreUsuario = _usernameController.text;
    final nuevaContrasena = _passwordController.text;

    if (nombreUsuario.isEmpty || nuevaContrasena.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ambos campos son obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showLoadingDialog(context);

    final response = await cambiarContrasena(
      nombreUsuario: nombreUsuario,
      nuevaContrasena: nuevaContrasena,
    );

    Navigator.pop(context);

    if (response['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada con éxito'),
          backgroundColor: Colors.green,
        ),
      );

      await Future.delayed(Duration(seconds: 2));

      Navigator.of(context).pushReplacementNamed('/login');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message']),
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
            Center(
              child: Icon(
                Icons.lock_reset,
                size: 100,
                color: Color(0xFFA41F1E),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ingresa tu Usuario',
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
