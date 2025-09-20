import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OtpScreen extends StatefulWidget {
  final String phone;
  final String reqId;

  const OtpScreen({super.key, required this.phone, required this.reqId});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _seconds = 240; // 4 phút
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel(); // hủy nếu có timer cũ
    setState(() {
      _seconds = 240;
      _expired = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_seconds > 0) {
        setState(() {
          _seconds--;
        });
      } else {
        timer.cancel();
        setState(() {
          _expired = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⏰ OTP đã hết hạn, vui lòng gửi lại.")),
        );
      }
    });
  }

  Future<void> _verifyOtp() async {
    final otp = _otpController.text.trim();

    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng nhập đủ 6 số OTP")),
      );
      return;
    }

    try {
      final url = Uri.parse("http://10.0.2.2:3000/otp/verify");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "phone": widget.phone,
          "code": otp,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data["ok"] == true && data["valid"] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("✅ OTP chính xác")),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("❌ OTP sai hoặc đã hết hạn")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("⚠️ Lỗi server: ${response.statusCode}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("🚨 Lỗi kết nối: $e")),
      );
    }
  }

  void _resendOtp() {
    _startTimer(); // reset lại countdown về 4p
    _otpController.clear();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("📩 OTP mới đã được gửi")),
    );
    // TODO: gọi API gửi lại OTP ở đây
  }



  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (_seconds % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.grey[100],
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          "Xác minh OTP",
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Nhập mã OTP",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _otpController,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              maxLength: 6,
              style: const TextStyle(
                fontSize: 28,
                letterSpacing: 16,
              ),
              decoration: InputDecoration(
                counterText: "",
                hintText: "------",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "$minutes:$secs",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _verifyOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Tiếp tục",
                style:
                TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _resendOtp, // luôn bấm được
              child: const Text(
                "Gửi lại OTP",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
