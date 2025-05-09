import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/student_model.dart';
import 'login_screen.dart';
import 'registration_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  Student? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final userData = await _apiService.getStudentProfile();
      setState(() {
        _user = Student(
          userID: userData['userID'].toString(),
          firstName: userData['firstName'] ?? '',
          lastName: userData['lastName'] ?? '',
          phoneNumber: userData['phoneNumber'] ?? '',
          email: userData['email'],
          password: userData['password'] ?? '',
          role: userData['role'] ?? 'student',
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load profile: $e')),
        );
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _apiService.logout();
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => LoginScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to logout: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = colorScheme.onBackground;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الملف الشخصي',
          style: GoogleFonts.cairo(
            color: colorScheme.onPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: colorScheme.primary,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: colorScheme.onPrimary),
            onPressed: () {
              Navigator.pushNamed(context, '/settings');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildLoginOptions(context, colorScheme, textColor),
            _buildProfileInfo(colorScheme, textColor),
            _buildSettingsList(colorScheme, textColor),
            _buildAdminsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginOptions(BuildContext context, ColorScheme colorScheme, Color textColor) {
    return Container(
      margin: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تسجيل الدخول',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLoginOption(
                  'طلاب',
                  Icons.school,
                  () => Navigator.pushNamed(context, '/student-login'),
                  colorScheme,
                  textColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildLoginOption(
                  'مكاتب عقارات',
                  Icons.business,
                  () => Navigator.pushNamed(context, '/agency-login'),
                  colorScheme,
                  textColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildLoginOption(
                  'أسر مضيفة',
                  Icons.family_restroom,
                  () => Navigator.pushNamed(context, '/host-login'),
                  colorScheme,
                  textColor,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Container(), // Empty container to maintain layout
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginOption(String title, IconData icon, VoidCallback onTap, ColorScheme colorScheme, Color textColor) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: colorScheme.primary,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo(ColorScheme colorScheme, Color textColor) {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: colorScheme.primary.withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 50,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'مرحباً بك',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'قم بتسجيل الدخول للوصول إلى جميع الميزات',
            style: GoogleFonts.cairo(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList(ColorScheme colorScheme, Color textColor) {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            'الإشعارات',
            Icons.notifications_outlined,
            () => Navigator.pushNamed(context, '/notifications'),
            colorScheme,
            textColor,
          ),
          Divider(height: 1),
          _buildSettingsItem(
            'الخصوصية',
            Icons.lock_outline,
            () => Navigator.pushNamed(context, '/settings'),
            colorScheme,
            textColor,
          ),
          Divider(height: 1),
          _buildSettingsItem(
            'المساعدة والدعم',
            Icons.help_outline,
            () => Navigator.pushNamed(context, '/support'),
            colorScheme,
            textColor,
          ),
          Divider(height: 1),
          _buildSettingsItem(
            'عن التطبيق',
            Icons.info_outline,
            () => Navigator.pushNamed(context, '/about'),
            colorScheme,
            textColor,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap, ColorScheme colorScheme, Color textColor) {
    return ListTile(
      leading: Icon(
        icon,
        color: colorScheme.primary,
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(
          color: textColor,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildAdminsSection() {
    return FutureBuilder<List<Admin>>(
      future: _fetchAdmins(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('حدث خطأ أثناء جلب بيانات الإداريين'));
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('لا يوجد إداريون'));
        }
        final admins = snapshot.data!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('الإداريون:', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
            ...admins.map((admin) => ListTile(
                  title: Text(admin.adminName),
                  subtitle: Text(admin.email),
                  trailing: Text(admin.phoneNumber),
                )),
          ],
        );
      },
    );
  }

  Future<List<Admin>> _fetchAdmins() async {
    final snapshot = await FirebaseFirestore.instance.collection('admins').get();
    return snapshot.docs.map((doc) => Admin.fromJson(doc.data())).toList();
  }
}
