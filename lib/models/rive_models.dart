import 'package:rive/rive.dart';

class RiveModels {
  final String src, artboard, stateMachine;
  late BooleanInput? status;

  RiveModels({
    required this.src,
    required this.artboard,
    required this.stateMachine,
    this.status,
  });

  set setStatus(BooleanInput state) {
    status = state;
  }
}