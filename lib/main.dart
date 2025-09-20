import 'package:flutter/material.dart';
import 'screens/otp_screen.dart'; // import màn hình OTP của bạn

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
      // chạy thẳng vào OtpScreen
      home: const OtpScreen(
        phone: "0961520154", // test số phone
        reqId: "demo_reqId", // tạm fake để chạy giao diện
      ),
    );
  }
}
