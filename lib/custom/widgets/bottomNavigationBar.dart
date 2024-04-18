import 'package:flashy_tab_bar2/flashy_tab_bar2.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const CustomBottomNavigationBar({
    Key? key,
    required this.selectedIndex,
    required this.onItemSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FlashyTabBar(
      iconSize: 20,
      backgroundColor: theme.colorScheme.background,
      selectedIndex: selectedIndex,
      animationDuration: Duration(milliseconds: 500),
      showElevation: true,
      items: [
        FlashyTabBarItem(
          icon: Icon(LucideIcons.home),
          title: const Text(
            'Inicio',
          ),
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.primary,
        ),
        FlashyTabBarItem(
          icon: Icon(LucideIcons.trophy),
          title: Text(
            'Actividades',
            style: TextStyle(
              fontSize: 11.4,
            ),
          ),
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.primary,
        ),
        FlashyTabBarItem(
          icon: Icon(LucideIcons.bookOpen),
          title: Text(
            'Campus',
          ),
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.primary,
        ),
        FlashyTabBarItem(
          icon: Icon(LucideIcons.pin),
          title: Text(
            'Noticias',
          ),
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.primary,
        ),
        FlashyTabBarItem(
          icon: Icon(LucideIcons.info),
          title: Text(
            'Info',
          ),
          activeColor: theme.colorScheme.primary,
          inactiveColor: theme.colorScheme.primary,
        ),
      ],
      onItemSelected: onItemSelected,
    );
  }
}
