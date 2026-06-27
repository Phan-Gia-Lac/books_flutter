import 'package:books_flutter/screens/main_pages/home.dart';
import 'package:books_flutter/screens/main_pages/search.dart';
import 'package:books_flutter/screens/main_pages/profile.dart';
import 'package:rive/rive.dart';
import 'package:books_flutter/models/NavItemModel.dart';
import 'package:flutter/material.dart';

const Color bottomNavBgColor = Color(0xFF17203A);

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  final List<StateMachine?> _stateMachines = [];
  late final List<FileLoader> _fileLoaders;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    _stateMachines.addAll(
      List.generate(bottomNavItems.length, (_) => null),
    );

    _fileLoaders = bottomNavItems
        .map((item) => FileLoader.fromAsset(
              item.rive.src,
              riveFactory: Factory.rive,
            ))
        .toList();
  }

  void _onItemTapped(int index) {
    _stateMachines[_selectedIndex]?.boolean('active')?.value = false;
    _stateMachines[index]?.boolean('active')?.value = true;
    setState(() => _selectedIndex = index);
  }

  RiveWidget _buildRiveWidget(
    File file,
    String artboard,
    String stateMachine,
    int index,
  ) {
    final controller = RiveWidgetController(
      file,
      artboardSelector: ArtboardSelector.byName(artboard),
      stateMachineSelector: StateMachineSelector.byName(stateMachine),
    );

    _stateMachines[index] = controller.stateMachine;

    final activeInput = controller.stateMachine.boolean('active');
    activeInput?.value = index == _selectedIndex;

    return RiveWidget(
      controller: controller,
      fit: Fit.contain,
    );
  }

  @override
  void dispose(){
    for (final controller in _stateMachines) {
      controller?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          height: 56,
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: bottomNavBgColor.withValues(alpha: 0.3),
                offset: const Offset(0, 20),
                blurRadius: 20,
              ),
            ],
          ),
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: bottomNavBgColor.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                bottomNavItems.length,
                (index) {
                  final riveIcon = bottomNavItems[index].rive;
                  return GestureDetector(
                    onTap: () => _onItemTapped(index),
                    child: Column(         
                      children: [
                        AnimatedBar(isActive: index == _selectedIndex),
                        SizedBox(
                          height: 36,
                          width: 36,
                          child: RiveWidgetBuilder(
                            fileLoader: _fileLoaders[index],
                            builder: (context, state) => switch (state) {
                              RiveLoading() => const SizedBox(),
                              RiveFailed() => const Icon(
                                Icons.error_outline,
                                color: Colors.red,
                                size: 20,
                              ),
                              RiveLoaded(:final file) => _buildRiveWidget(
                                file,
                                riveIcon.artboard,
                                riveIcon.stateMachine,
                                index,
                              ),
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 1, top: 5),
      height: 4,
      width: isActive ? 20 : 0,
      decoration: const BoxDecoration(
        color: Color(0xFF81B4FF),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }
}