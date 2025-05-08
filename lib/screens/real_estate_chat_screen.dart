import 'package:flutter/material.dart';
import '../models/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RealEstateChatScreen extends StatelessWidget {
  Stream<List<Message>> getRealEstateMessages() {
    return FirebaseFirestore.instance
        .collection('messages')
        .where('receiverType', isEqualTo: 'real_estate_office')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromJson(doc.data())).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("محادثة مع المكاتب العقارية"),
      ),
      body: StreamBuilder<List<Message>>(
        stream: getRealEstateMessages(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ أثناء جلب الرسائل'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد رسائل'));
          }
          final messages = snapshot.data!;
          return ListView.builder(
            reverse: true,
            itemCount: messages.length,
            itemBuilder: (context, index) {
              final msg = messages[index];
              return ListTile(
                title: Text(msg.content),
                subtitle: Text(msg.senderId),
                trailing: msg.isRead ? Icon(Icons.done_all) : Icon(Icons.done),
              );
            },
          );
        },
      ),
    );
  }
}
