import 'package:appayu/deleteuser.dart';
import 'package:appayu/password.dart';
import 'package:flutter/material.dart';
import 'registrouser.dart';
import 'login_screen.dart';
import 'generar_rep.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Panel de Administrador',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFA41F1E),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
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
          const SizedBox(height: 20),
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
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
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              'assets/logo_ayu.png',
              height: 200,
              width: 200,
              fit: BoxFit.contain,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
            child: Divider(
              color: Color(0xFFA41F1E),
              thickness: 5,
            ),
          ),
          _buildAdminOption(
            context,
            icon: Icons.person,
            label: 'Registrar Usuario',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Registrouser()),
            ),
          ),
          _buildAdminOption(
            context,
            icon: Icons.vpn_key,
            label: 'Cambiar Contraseñas',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CPassword()),
            ),
          ),
          _buildAdminOption(
            context,
            icon: Icons.delete,
            label: 'Eliminar Usuarios',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => DeleteUser()),
            ),
          ),
          _buildAdminOption(
            context,
            icon: Icons.picture_as_pdf,
            label: 'Generar Reporte',
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const GenerarReporteScreen()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminOption(BuildContext context,
      {required IconData icon,
      required String label,
      required VoidCallback onTap}) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFA41F1E), size: 40),
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}
