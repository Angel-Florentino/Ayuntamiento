import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_font_icons/flutter_font_icons.dart';
import 'package:http/http.dart' as http;
import 'admin_screen.dart';
import 'user_screen.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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

  Future<void> login(BuildContext context) async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Por favor, complete todos los campos.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showLoadingDialog(context);

    try {
      final response = await http.post(
        Uri.parse(
            'https://a4c9-2806-10ae-16-7e24-50e3-d50b-ea77-b605.ngrok-free.app/api/login.php'),
        body: {
          'nombre_usuario': emailController.text,
          'contrasena': passwordController.text,
        },
      );

      Navigator.pop(context);

      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        if (responseBody['status'] == 'success') {
          if (responseBody['role'] == 'Administrador') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AdminScreen()),
            );
          } else if (responseBody['role'] == 'Usuario') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => UserScreen()),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseBody['message'],
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        throw Exception('Error en la solicitud al servidor.');
      }
    } catch (error) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error al conectar con el servidor.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Cabecera
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(top: 26.0, bottom: 16.0),
                decoration: BoxDecoration(
                  color: Color(0xFFA41F1E),
                ),
                child: Center(
                  child: Text(
                    'Bienvenidos',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Gobierno Municipal De Texistepec 2022-2025',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFA41F1E),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Image.asset(
                'assets/logo_ayu.png',
                height: 180,
                width: 180,
              ),
              SizedBox(height: 20),
              Text(
                'Iniciar Sesión',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 30),
              // Campo de usuario
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: emailController,
                  style: TextStyle(color: Colors.black),
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      MaterialCommunityIcons.account_circle_outline,
                      color: Colors.black,
                    ),
                    hintText: 'Usuario',
                    hintStyle: TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: TextField(
                  controller: passwordController,
                  style: TextStyle(color: Colors.black),
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon: Icon(
                      MaterialCommunityIcons.lock_outline,
                      color: Colors.black,
                    ),
                    hintText: 'Contraseña',
                    hintStyle: TextStyle(color: Colors.black54),
                    filled: true,
                    fillColor: Colors.grey[200],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
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
                    onPressed: () => login(context),
                    child: Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
