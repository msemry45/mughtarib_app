import 'package:flutter/material.dart';

class CustomWidget extends StatelessWidget {
  final String text;
  const CustomWidget({Key? key, required this.text}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.blueAccent),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(text),
    );
  }
}
