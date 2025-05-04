import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotificationsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('الإشعارات', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: Center(
        child: Text(
          'لا توجد إشعارات حالياً\n(سيتم ربطها بالباكند لاحقاً)',
          style: GoogleFonts.cairo(fontSize: 20, color: Colors.grey[700]),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
} 