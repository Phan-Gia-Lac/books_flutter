import 'package:books_flutter/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/intro_page.dart';
import 'screens/main_pages/home.dart';
import './AppRoutes.dart';

class ComicoApp extends StatelessWidget {
  const ComicoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'COMICO STORE',
      debugShowCheckedModeBanner: false,

      // Theme
      theme: AppTheme.dark,

      // Initial screen
      initialRoute: AppRoutes.intro,

      // All app routes in one place
      routes: {
        // No Navigation
        AppRoutes.intro: (context) => const IntroPage(),
        AppRoutes.login: (context) => const LoginScreen(),
        AppRoutes.register: (context) => const RegisterScreen(),

        // Main app with bottom navigation
        AppRoutes.home: (context) => const Navigation(),
      },

      // Custom page transition for all routes
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case AppRoutes.intro:
            return _buildRoute(const IntroPage(), settings);
          case AppRoutes.login:
            return _buildRoute(const LoginScreen(), settings);
          case AppRoutes.register:
            return _buildRoute(const RegisterScreen(), settings);
          case AppRoutes.home:
            return _buildRoute(const HomeScreen(), settings);
          default:
            return MaterialPageRoute(
              builder: (context) => const IntroPage(),
            );
        }
      },
    );
  }

  // Slide up transition for all screens
  PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionDuration: const Duration(milliseconds: 600),
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeIn,
          ),
          child: child,
        );
      },
    );
  }
}