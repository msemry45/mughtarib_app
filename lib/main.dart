import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/student_login_screen.dart';
import 'screens/agency_login_screen.dart';
import 'screens/host_login_screen.dart';
import 'screens/restaurant_login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/posts_screen.dart';
import 'screens/restaurants_screen.dart';
import 'screens/stays_screen.dart';
import 'screens/category_screen.dart';
import 'screens/messages_screen.dart';
import 'screens/property_screen.dart';
import 'screens/student_screen.dart';
import 'screens/host_families_chat_screen.dart';
import 'screens/real_estate_chat_screen.dart';
import 'screens/chatbot_screen.dart';
import 'screens/explore_screen.dart';
import 'screens/host_families_screen.dart';
import 'screens/clinics_screen.dart';
import 'screens/notifications_screen.dart';
import 'screens/students_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mughtarib App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF9C27B0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9C27B0),
          primary: const Color(0xFF9C27B0),
          secondary: const Color(0xFF9C27B0),
        ),
        useMaterial3: true,
        // Optimize text rendering
        textTheme: Theme.of(context).textTheme.apply(
          fontFamily: 'Cairo',
        ),
        // Optimize button rendering
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        // Optimize input decoration
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/home': (context) => HomeScreen(),
        '/profile': (context) => ProfileScreen(),
        '/login': (context) => LoginScreen(),
        '/register': (context) => RegistrationScreen(),
        '/posts': (context) => PostsScreen(),
        '/restaurants': (context) => RestaurantsScreen(),
        '/student-login': (context) => StudentLoginScreen(),
        '/agency-login': (context) => AgencyLoginScreen(),
        '/host-login': (context) => HostLoginScreen(),
        '/restaurant-login': (context) => RestaurantLoginScreen(),
        '/stays': (context) => StaysScreen(),
        '/category': (context) => CategoryScreen(),
        '/messages': (context) => MessagesScreen(),
        '/property': (context) => PropertyScreen(),
        '/student': (context) => StudentScreen(),
        '/hostFamiliesChat': (context) => HostFamiliesChatScreen(),
        '/realEstateChat': (context) => RealEstateChatScreen(),
        '/chatbot': (context) => ChatbotScreen(),
        '/explore': (context) => ExploreScreen(),
        '/host-families': (context) => HostFamiliesScreen(),
        '/clinics': (context) => ClinicsScreen(),
        '/notifications': (context) => NotificationsScreen(),
        '/students': (context) => StudentsScreen(),
      },
    );
  }
}
