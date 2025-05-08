import 'package:flutter/material.dart';
import '../models/property_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PropertyScreen extends StatelessWidget {
  Future<List<Property>> fetchProperties() async {
    final snapshot = await FirebaseFirestore.instance.collection('properties').get();
    return snapshot.docs.map((doc) => Property.fromJson(doc.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("العقارات"),
      ),
      body: FutureBuilder<List<Property>>(
        future: fetchProperties(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ أثناء جلب البيانات'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد عقارات متاحة'));
          }
          final properties = snapshot.data!;
          return ListView.builder(
            itemCount: properties.length,
            itemBuilder: (context, index) {
              final property = properties[index];
              return ListTile(
                title: Text(property.title),
                subtitle: Text(property.city),
                trailing: Text('${property.price} ${property.currency}'),
                onTap: () {
                  // يمكنك هنا فتح صفحة تفاصيل العقار
                },
              );
            },
          );
        },
      ),
    );
  }
}
