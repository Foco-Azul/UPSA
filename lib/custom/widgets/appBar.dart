import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:upsa/custom/auth/login_screen.dart';
import 'package:upsa/custom/screens/perfil/profile_screen.dart';
import 'package:upsa/helpers/widgets/my_spacing.dart';
import 'package:upsa/helpers/widgets/my_text.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final bool isLoggedIn;
  final Function onProfileTap;
  final Function onSettingsTap;
  final int pantalla;

  const CustomAppBar({
    Key? key,
    required this.isLoggedIn,
    required this.onProfileTap,
    required this.onSettingsTap,
    required this.pantalla,
  }) : super(key: key);

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      elevation: 0,
      title: pantalla == 1 ? MyText.titleMedium("Actividades", fontWeight: 600) : null, 
      centerTitle: true,
      actions: [
        if(pantalla == 0)
        InkWell(
          onTap: () {
            if (isLoggedIn) {
              onProfileTap();
            } else {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()),);
            }
          },
          child: Container(
            padding: MySpacing.x(20),
            child: Icon(
              LucideIcons.user,
              color: theme.colorScheme.onBackground,
              size: 25,
            ),
          ),
        ),
        if(pantalla == 0)
        InkWell(
          onTap: () {
            onSettingsTap();
          },
          child: Container(
            padding: MySpacing.x(20),
            child: Icon(
              LucideIcons.bell,
              color: theme.colorScheme.onBackground,
              size: 25,
            ),
          ),
        ),
      ],
    );
  }
}
