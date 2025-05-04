import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import '../models/user.dart';
import 'login_screen.dart';
import 'registration_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ApiService _apiService = ApiService();
  User? _user;
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
        _user = User.fromJson(userData);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'الملف الشخصي',
          style: GoogleFonts.cairo(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Color(0xFF9C27B0),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildLoginOptions(context),
            _buildProfileInfo(),
            _buildSettingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginOptions(BuildContext context) {
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
              color: Color(0xFF9C27B0),
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
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _buildLoginOption(
                  'مكاتب عقارات',
                  Icons.business,
                  () => Navigator.pushNamed(context, '/agency-login'),
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

  Widget _buildLoginOption(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Color(0xFF9C27B0).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: Color(0xFF9C27B0),
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.cairo(
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileInfo() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF9C27B0).withOpacity(0.1),
            child: Icon(
              Icons.person,
              size: 50,
              color: Color(0xFF9C27B0),
            ),
          ),
          SizedBox(height: 16),
          Text(
            'مرحباً بك',
            style: GoogleFonts.cairo(
              fontSize: 24,
              fontWeight: FontWeight.bold,
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

  Widget _buildSettingsList() {
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
            () {},
          ),
          Divider(height: 1),
          _buildSettingsItem(
            'الخصوصية',
            Icons.lock_outline,
            () {},
          ),
          Divider(height: 1),
          _buildSettingsItem(
            'المساعدة والدعم',
            Icons.help_outline,
            () {},
          ),
          Divider(height: 1),
          _buildSettingsItem(
            'عن التطبيق',
            Icons.info_outline,
            () {},
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsItem(String title, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(
        icon,
        color: Color(0xFF9C27B0),
      ),
      title: Text(
        title,
        style: GoogleFonts.cairo(),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }
}
