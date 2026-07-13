import 'package:books_flutter/navigation_bar.dart';
import 'package:books_flutter/services/socket_service.dart';
import 'package:books_flutter/viewmodel/authVM.dart';
import 'package:books_flutter/viewmodel/adminVM.dart';
import 'package:books_flutter/viewmodel/productsVM.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/intro_page.dart';
import 'screens/main_pages/order_history_screen.dart';
import 'screens/main_pages/checkout_screen.dart';
import 'screens/auth/forgot_password.dart';
import 'screens/auth/2step.dart';
import 'screens/admin/main.dart';
import 'screens/admin/admin_product_screen.dart';
import 'screens/admin/admin_pending_screen.dart';
import 'screens/admin/admin_profile_screen.dart';
import './AppRoutes.dart';
import 'package:books_flutter/app_layout.dart';

// class ComicoApp extends StatelessWidget
class ComicoApp extends StatefulWidget {
  const ComicoApp({super.key});

  @override
  State<ComicoApp> createState() => _ComicoAppState();
}

class _ComicoAppState extends State<ComicoApp> {
  late ProductsVM _productsVM;
  late AdminVM _adminVM;
  late AuthVM _authVM;
  SocketService? _socketService;

  @override
  void initState() {
    super.initState();
    _productsVM = ProductsVM();
    // _socketService = _socketService(_productsVM);

    _adminVM = AdminVM();
    // _socketService = _socketService(_productsVM, _adminVM);

    _authVM = AuthVM();
    _socketService = SocketService(_productsVM, _adminVM, _authVM);
    _socketService!.connect();
  }

  @override
  void dispose() {
    _socketService?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ChangeNotifierProvider(create: (_) => AuthVM()),
        // ChangeNotifierProvider(create: (_) => ProductsVM()),
        // ChangeNotifierProvider(create: (_) => AdminVM()),

        ChangeNotifierProvider.value(value: _authVM),
        ChangeNotifierProvider.value(value: _productsVM),
        ChangeNotifierProvider.value(value: _adminVM),
      ],
      child: MaterialApp(
        title: 'COMICO STORE',
        debugShowCheckedModeBanner: false,

        // Theme
        theme: AppTheme.dark,

        // Initial screen
        initialRoute: AppRoutes.admin,

        // All app routes in one place
        routes: {
          // No Navigation
          AppRoutes.intro: (context) => const IntroPage(),
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),

          // Main app with bottom navigation
          AppRoutes.home: (context) => const Navigation(),
          AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
          AppRoutes.orderHistory: (context) => const OrderHistoryScreen(),
          AppRoutes.checkout: (context) => const CheckoutScreen(),
          AppRoutes.twoStep: (context) => const TwoStepScreen(),
        },

        // Custom page transition for all routes
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case AppRoutes.admin:
              return _buildRoute(const AdminHomeScreen(), settings);
            // case AppRoutes.admin_product:
            //   return _buildRoute(const AdminProductScreen(), settings);
            case AppRoutes.admin_pending:
              return _buildRoute(const AdminPendingScreen(), settings);
            case AppRoutes.admin_profile:
              return _buildRoute(const AdminProfileScreen(), settings);
            case AppRoutes.intro:
              return _buildRoute(const IntroPage(), settings);
            case AppRoutes.login:
              return _buildRoute(const LoginScreen(), settings);
            case AppRoutes.register:
              return _buildRoute(const RegisterScreen(), settings);
            case AppRoutes.home:
              return _buildRoute(const Navigation(), settings);
            case AppRoutes.forgotPassword:
              return _buildRoute(const ForgotPasswordScreen(), settings);
            case AppRoutes.orderHistory:
              return _buildRoute(const OrderHistoryScreen(), settings);
            case AppRoutes.checkout:
              return _buildRoute(const CheckoutScreen(), settings);
            case AppRoutes.twoStep:
              return _buildRoute(const TwoStepScreen(), settings);
            default:
              return MaterialPageRoute(builder: (context) => const IntroPage());
          }
        },
      ),
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
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
          child: child,
        );
      },
    );
  }
}
