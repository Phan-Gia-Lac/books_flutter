import 'rive_models.dart';

const String url = "assets/animations/icon-set-1.riv";

class NavItemModel {
  final String title;
  final RiveModels rive;

  NavItemModel({required this.title, required this.rive});
}

List<NavItemModel> bottomNavItems = [
  NavItemModel(
    title: "Home",
    rive: RiveModels(
      src: url,
      artboard: "HOME",
      stateMachine: "HOME_interactivity",
    ),
  ),
  NavItemModel(
    title: "Search",
    rive: RiveModels(
      src: url,
      artboard: "SEARCH",
      stateMachine: "SEARCH_Interactivity",
    ),
  ),
  NavItemModel(
    title: "User",
    rive: RiveModels(
      src: url,
      artboard: "USER",
      stateMachine: "USER_Interactivity",
    ),
  ),
];