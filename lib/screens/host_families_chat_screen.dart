import 'package:flutter/material.dart';

class HostFamiliesChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("محادثة مع الأسر المضيفة"),
      ),
      body: Center(
        child: Text("هنا يمكنك التحدث مع الأسر المضيفة."),
      ),
    );
  }
}
