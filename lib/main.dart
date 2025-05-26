import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'MedicSync Login',
    initialRoute: '/',
    routes: {
      '/': (context) => LoginScreen(),
      '/dashboard': (context) => DashboardScreen(),
    },
  ));
}
