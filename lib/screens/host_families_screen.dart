import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/host_family_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HostFamiliesScreen extends StatelessWidget {
  Future<List<HostFamily>> fetchHostFamilies() async {
    final snapshot = await FirebaseFirestore.instance.collection('hostFamilies').get();
    return snapshot.docs.map((doc) => HostFamily.fromJson(doc.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الأسر المضيفة', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: FutureBuilder<List<HostFamily>>(
        future: fetchHostFamilies(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ أثناء جلب البيانات', style: GoogleFonts.cairo()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد أسر مضيفة متاحة', style: GoogleFonts.cairo()));
          }
          final families = snapshot.data!;
          return ListView.builder(
            itemCount: families.length,
            itemBuilder: (context, index) {
              final family = families[index];
              return ListTile(
                title: Text(family.name, style: GoogleFonts.cairo()),
                subtitle: Text(family.city, style: GoogleFonts.cairo()),
                trailing: Text(family.phone, style: GoogleFonts.cairo()),
                onTap: () {
                  // يمكنك هنا فتح صفحة تفاصيل الأسرة
                },
              );
            },
          );
        },
      ),
    );
  }
} 