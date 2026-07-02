import 'rive_models.dart';

const String url1 = "assets/animations/icon-set-1.riv";
const String url2 = "assets/animations/back1.riv";

class NavItemModel {
  final String title;
  final RiveModels rive;

  NavItemModel({required this.title, required this.rive});
}

List<NavItemModel> screenItems = [
  NavItemModel(
    title:  "Intro",
    rive: RiveModels(
      src:url2,
      artboard: "Intro_screen",
      stateMachine: "State Machine 1"
    )
  ),

  NavItemModel(
    title:  "Background",
    rive: RiveModels(
      src:url2,
      artboard: "Back_ground",
      stateMachine: "State Machine 1"
    )
  ),
];

List<NavItemModel> bottomNavItems = [
  NavItemModel(
    title: "Home",
    rive: RiveModels(
      src: url1,
      artboard: "HOME",
      stateMachine: "HOME_interactivity",
    ),
  ),
  NavItemModel(
    title: "Search",
    rive: RiveModels(
      src: url1,
      artboard: "SEARCH",
      stateMachine: "SEARCH_Interactivity",
    ),
  ),
  NavItemModel(
    title: "User",
    rive: RiveModels(
      src: url1,
      artboard: "USER",
      stateMachine: "USER_Interactivity",
    ),
  ),
];