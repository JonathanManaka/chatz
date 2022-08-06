import 'package:chatz/screens/auth_screens/sign_in_screen.dart';
import 'package:chatz/screens/auth_screens/sign_up_screen.dart';
import 'package:chatz/screens/chat_screen/chat_screen.dart';
import 'package:chatz/screens/home_screen/home_screen.dart';
import 'package:chatz/screens/landing_screen/landing_screen.dart';
import 'package:chatz/screens/profile_screen/profile_screen.dart';
import 'package:flutter/material.dart';

class AppRouter {
  static const String landingScreen = '/landing_screen',
      homeScreen = '/home_screen',
      profileScreen = '/profile_screen',
      chatScreen = '/chat_screen',
      signIncreen = '/sign_in_screen',
      signUpcreen = '/sign_up_screen';

  static Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case landingScreen:
        return MaterialPageRoute(
          builder: (context) => const LandingScreen(),
        );
      case homeScreen:
        return MaterialPageRoute(
          builder: (context) => const HomeScreen(),
        );
      case profileScreen:
        return MaterialPageRoute(
          builder: (context) => const ProfileScreen(),
        );
      case chatScreen:
        return MaterialPageRoute(
          builder: (context) => const ChatScreen(
            group: null,
          ),
        );
      case signIncreen:
        return MaterialPageRoute(
          builder: (context) => const SignInScreen(),
        );
      case signUpcreen:
        return MaterialPageRoute(
          builder: (context) => const SignUpScreen(),
        );
      default:
        return null;
    }
  }
}
