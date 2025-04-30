import 'package:flutter/material.dart';
import 'package:mughtarib_app/screens/registration_screen.dart';
import 'package:mughtarib_app/screens/splash_screen.dart';
import 'package:mughtarib_app/theme/app_theme.dart';
import 'screens/home_screen.dart';
import 'screens/posts_screen.dart';
import 'screens/stays_screen.dart';
import 'screens/category_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/property_screen.dart';
import 'screens/student_screen.dart';
import 'screens/host_families_chat_screen.dart';
import 'screens/real_estate_chat_screen.dart';
import 'screens/chatbot_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mughtarib App',
      theme: AppTheme.lightTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/posts': (context) => PostsScreen(),
        '/stays': (context) => StaysScreen(),
        '/category': (context) => CategoryScreen(),
        '/profile': (context) => ProfileScreen(),
        '/messages': (context) => MessagesScreen(),
        '/property': (context) => PropertyScreen(),
        '/student': (context) => StudentScreen(),
        '/register': (context) => RegistrationScreen(),
        '/hostFamiliesChat': (context) => HostFamiliesChatScreen(),
        '/realEstateChat': (context) => RealEstateChatScreen(),
        '/chatbot': (context) => ChatbotScreen(),
      },
    );
  }
}
