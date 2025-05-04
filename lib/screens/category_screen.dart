import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CategoryScreen extends StatelessWidget {
  final List<Map<String, dynamic>> categories = [
    {'title': 'سكن', 'icon': Icons.home, 'route': '/property'},
    {'title': 'مطاعم', 'icon': Icons.restaurant, 'route': '/restaurants'},
    {'title': 'عيادات', 'icon': Icons.local_hospital, 'route': '/clinics'},
    {'title': 'أسر مضيفة', 'icon': Icons.family_restroom, 'route': '/host-families'},
    {'title': 'إعلانات', 'icon': Icons.post_add, 'route': '/posts'},
    {'title': 'استكشاف', 'icon': Icons.explore, 'route': '/explore'},
    {'title': 'الرسائل', 'icon': Icons.chat, 'route': '/messages'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('التصنيفات', style: GoogleFonts.cairo()),
        backgroundColor: const Color(0xFF9C27B0),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(category['icon'], color: const Color(0xFF9C27B0), size: 32),
              title: Text(
                category['title'],
                style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
              onTap: () => Navigator.pushNamed(context, category['route']),
            ),
          );
        },
      ),
    );
  }
}
