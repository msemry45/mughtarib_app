import 'package:flutter/material.dart';

class MessagesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("الرسائل"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // الخيار الأول: الأسر المضيفة
            Card(
              child: ListTile(
                leading: Icon(Icons.family_restroom),
                title: Text("التحدث مع الأسر المضيفة"),
                onTap: () {
                  Navigator.pushNamed(context, '/hostFamiliesChat');
                },
              ),
            ),
            SizedBox(height: 16),
            // الخيار الثاني: المكاتب العقارية
            Card(
              child: ListTile(
                leading: Icon(Icons.home_work),
                title: Text("التحدث مع المكاتب العقارية"),
                onTap: () {
                  Navigator.pushNamed(context, '/realEstateChat');
                },
              ),
            ),
            SizedBox(height: 16),
            // الخيار الثالث: الشات بوت
            Card(
              child: ListTile(
                leading: Icon(Icons.chat_bubble_outline),
                title: Text("التحدث مع الشات بوت"),
                onTap: () {
                  Navigator.pushNamed(context, '/chatbot');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
