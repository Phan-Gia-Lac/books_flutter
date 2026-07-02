import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import '../AppRoutes.dart';
import '../models/NavItemModel.dart';

// Animation is 8 second
Future<void> _navigateToLogin(BuildContext context) async {
  await Future.delayed(const Duration(seconds: 8));
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
  // Using the new native file loader factory syntax
  late final fileLoader = FileLoader.fromAsset(
    "assets/animations/new_intro.riv", 
    riveFactory: Factory.rive,
  );
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateToLogin(context);
    });
  }

  RiveWidget _buildWidget (
    File file,
    String artboard,
    String stateMachine,
  ) {
    final controller = RiveWidgetController(
      file,
      artboardSelector: ArtboardSelector.byName(artboard),
      stateMachineSelector: StateMachineSelector.byName(stateMachine),
    );

    return RiveWidget(
      controller: controller,
      fit: Fit.cover,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: RiveWidgetBuilder(
        fileLoader: fileLoader,
        builder: (context, state) => switch (state) {
          RiveLoading() => const Center(child: CircularProgressIndicator()),
          RiveFailed() => const Center(child: Text("Failed to load animation")),
          RiveLoaded() => _buildWidget(
            state.file,
            screenItems[0].rive.artboard,
            screenItems[0].rive.stateMachine,
          ),
        },
      ),
    );
  }
}