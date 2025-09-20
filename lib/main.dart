import 'package:flutter/material.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OTP Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      // Chạy thẳng vào RegisterScreen
      home: const RegisterScreen(),
    );
  }
}
