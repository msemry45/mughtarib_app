import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  void _login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    final userId = int.tryParse(_userIdController.text);
    final password = _passwordController.text;
    if (userId == null || password.isEmpty) {
      setState(() {
        errorMessage = 'الرجاء إدخال بيانات صحيحة';
        isLoading = false;
      });
      return;
    }
    try {
      final token = await AuthService().login(userId, password);
      // بعد النجاح، يتم الانتقال إلى الشاشة الرئيسية وتمرير التوكن
      Navigator.pushReplacementNamed(context, '/home', arguments: token);
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
      });
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  void dispose() {
    _userIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("تسجيل الدخول"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: "الرقم الجامعي"),
            ),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "كلمة المرور"),
            ),
            SizedBox(height: 20),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login, child: Text("تسجيل الدخول")),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
