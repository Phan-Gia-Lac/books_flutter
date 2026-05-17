import 'package:flutter/material.dart';
import '../AppRoutes.dart';

Future<void> navigateToLogin(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 3));
  if (context.mounted) {
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }
}

class IntroPage extends StatefulWidget {
  const IntroPage({super.key});

  @override
  State<IntroPage> createState() => _IntroPageState();
}
class _IntroPageState extends State<IntroPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      navigateToLogin(context);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Icon(
                Icons.wb_sunny_outlined, 
                size: 80, 
                color: Colors.blue,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Welcome to our app!',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.login);
              },
              child: const Text('Get Started'),
            )
          ],
        ),
      ),
    );
  }
}