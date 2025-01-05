import 'package:appayu/cpassworduser.dart';
import 'package:appayu/updateactividades.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'reg_actividades.dart';

class UserScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Panel de Usuario',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Color(0xFFA41F1E),
          leading: null,
          actions: [
            IconButton(
              icon: Icon(Icons.logout, color: Colors.white),
              tooltip: 'Cerrar sesión',
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        ),
        body: ListView(
          children: [
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
              height: 200,
              width: 200,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Divider(
                color: Color(0xFFA41F1E),
                thickness: 5,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(10),
              child: ListTile(
                leading: const Icon(Icons.vpn_key,
                    color: Color(0xFFA41F1E), size: 40),
                title: const Text(
                  'Cambiar Contraseña',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PasswordUser()),
                  );
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: ListTile(
                leading: Icon(Icons.event, color: Color(0xFFA41F1E), size: 40),
                title: Text(
                  'Registrar Actividad',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  _registerActivity(context);
                },
              ),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: ListTile(
                leading: Icon(Icons.update, color: Color(0xFFA41F1E), size: 40),
                title: Text(
                  'Actualizar Actividades',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => UpdateActividades()),
                  );
                },
              ),
            )
          ],
        ),
        backgroundColor: Colors.white,
      ),
    );
  }

  void _registerActivity(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegActividades()),
    );
  }
}
