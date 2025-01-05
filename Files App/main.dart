import 'package:appayu/cpassworduser.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'login_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ayuntamiento Texistepec',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('es', 'ES'),
      ],
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginScreen(),
        '/password_user': (context) => PasswordUser(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
