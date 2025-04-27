import 'package:flutter/material.dart';

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final TextEditingController _userIdController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool isLoading = false;
  String errorMessage = '';

  // دالة محاكاة تسجيل الدخول (سيتم ربطها بـ API لاحقاً)
  Future<void> _login() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });
    final userId = _userIdController.text;
    final password = _passwordController.text;
    
    if (userId.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'الرجاء إدخال البيانات المطلوبة';
        isLoading = false;
      });
      return;
    }
    
    // محاكاة تأخير تسجيل الدخول
    await Future.delayed(Duration(seconds: 2));
    
   
    if (userId == "1" && password == "pass123") {
      // نجاح تسجيل الدخول، مثلاً ننتقل إلى الصفحة الرئيسية أو لوحة التحكم
      Navigator.pushReplacementNamed(context, '/');
    } else {
      setState(() {
        errorMessage = 'بيانات الدخول غير صحيحة';
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
        title: Text("تسجيل الدخول / بيانات الطالب"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _userIdController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "الرقم الجامعي",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "كلمة المرور",
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _login, 
                    child: Text("دخول"),
                  ),
            if (errorMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.red),
                ),
              ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // الانتقال إلى شاشة التسجيل
                Navigator.pushNamed(context, '/register');
              },
              child: Text("تسجيل جديد"),
            ),
          ],
        ),
      ),
    );
  }
}
