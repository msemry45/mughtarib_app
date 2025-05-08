import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsScreen({Key? key, required this.isDarkMode, required this.onThemeChanged}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _selectedLanguage = 'العربية';
  final List<String> _languages = ['العربية', 'English'];

  @override
  Widget build(BuildContext context) {
    final textColor = Theme.of(context).colorScheme.onBackground;
    return Scaffold(
      appBar: AppBar(
        title: Text('الإعدادات', style: GoogleFonts.cairo(color: textColor)),
        backgroundColor: Theme.of(context).colorScheme.background,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('الوضع الليلي', style: GoogleFonts.cairo(color: textColor)),
            secondary: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode, color: textColor),
            value: widget.isDarkMode,
            onChanged: widget.onThemeChanged,
          ),
          ListTile(
            leading: Icon(Icons.language, color: textColor),
            title: Text('اللغة', style: GoogleFonts.cairo(color: textColor)),
            trailing: DropdownButton<String>(
              value: _selectedLanguage,
              dropdownColor: Theme.of(context).colorScheme.background,
              items: _languages.map((lang) => DropdownMenuItem(
                value: lang,
                child: Text(lang, style: GoogleFonts.cairo(color: textColor)),
              )).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedLanguage = val!;
                });
                // TODO: تنفيذ تغيير اللغة
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.info_outline, color: textColor),
            title: Text('عن التطبيق', style: GoogleFonts.cairo(color: textColor)),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'تطبيق المغترب',
                applicationVersion: '1.0.0',
                applicationLegalese: 'جميع الحقوق محفوظة © 2024',
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.logout, color: textColor),
            title: Text('تسجيل الخروج', style: GoogleFonts.cairo(color: textColor)),
            onTap: () {
              // TODO: تنفيذ تسجيل الخروج
            },
          ),
        ],
      ),
    );
  }
} 