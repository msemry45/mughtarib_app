import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/university_clinic_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClinicsScreen extends StatelessWidget {
  Future<List<UniversityClinic>> fetchClinics() async {
    final snapshot = await FirebaseFirestore.instance.collection('universityClinics').get();
    return snapshot.docs.map((doc) => UniversityClinic.fromJson(doc.data())).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('العيادات', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: FutureBuilder<List<UniversityClinic>>(
        future: fetchClinics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ أثناء جلب البيانات', style: GoogleFonts.cairo()));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('لا توجد عيادات متاحة', style: GoogleFonts.cairo()));
          }
          final clinics = snapshot.data!;
          return ListView.builder(
            itemCount: clinics.length,
            itemBuilder: (context, index) {
              final clinic = clinics[index];
              return ListTile(
                title: Text(clinic.clinicName, style: GoogleFonts.cairo()),
                subtitle: Text(clinic.location, style: GoogleFonts.cairo()),
                trailing: Text(clinic.phoneNumber, style: GoogleFonts.cairo()),
                onTap: () {
                  // يمكنك هنا فتح صفحة تفاصيل العيادة
                },
              );
            },
          );
        },
      ),
    );
  }
} 