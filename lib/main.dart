import 'package:flutter/material.dart';
import 'package:cosmetics_project/Pages/Login.dart';
import 'Pages/Home_Page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginScreen(),
        '/LoginScreenapp': (context) => LoginScreenapp(),
        '/HomePage': (context) => HomePage(),
      },
    );
  }
}
