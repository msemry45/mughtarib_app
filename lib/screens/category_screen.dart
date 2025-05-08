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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'التصنيفات',
          style: GoogleFonts.cairo(
            color: colorScheme.onPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.5,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          return Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: InkWell(
              onTap: () => Navigator.pushNamed(context, category['route']),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.primary,
                      colorScheme.primary.withOpacity(0.8),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      category['icon'],
                      color: colorScheme.onPrimary,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      category['title'],
                      style: GoogleFonts.cairo(
                        color: colorScheme.onPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
