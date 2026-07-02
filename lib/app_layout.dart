import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:books_flutter/models/NavItemModel.dart';

class PersistentBackground extends StatelessWidget {
  const PersistentBackground({super.key});

  static final FileLoader globalFileLoader = FileLoader.fromAsset(
    "assets/animations/back6.riv",
    riveFactory: Factory.rive,
  );

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: RiveWidgetBuilder(
        fileLoader: globalFileLoader,
        builder: (context, state) => switch (state) {
          RiveLoading() => const SizedBox.shrink(),
          RiveFailed(error: final error) => Center(
              child: Text('Error: $error', style: const TextStyle(color: Colors.red)),
            ),
          RiveLoaded() => RiveWidget(
              controller: RiveWidgetController(
                state.file,
                artboardSelector: ArtboardSelector.byName(screenItems[1].rive.artboard),
                stateMachineSelector: StateMachineSelector.byName(screenItems[1].rive.stateMachine),
              ),
              fit: Fit.cover,
            ),
        },
      ),
    );
  }
}


// this isn't working so i'll try finding another way to do this