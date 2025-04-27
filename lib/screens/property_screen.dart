import 'package:flutter/material.dart';

class PropertyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // يمكننا لاحقاً استدعاء بيانات العقارات من API
    return Scaffold(
      appBar: AppBar(
        title: Text("العقارات"),
      ),
      body: Center(
        child: Text("هنا يتم عرض بيانات العقارات"),
      ),
    );
  }
}
