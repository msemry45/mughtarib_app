import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ClinicsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('العيادات', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: Center(
        child: Text(
          'هذه صفحة العيادات\n(سيتم ربطها بالباكند لاحقاً)',
          style: GoogleFonts.cairo(fontSize: 20, color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
} 