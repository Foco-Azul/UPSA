import 'package:upsa/helpers/extensions/extensions.dart';
import 'package:upsa/helpers/theme/app_notifier.dart';
import 'package:upsa/helpers/theme/app_theme.dart';
import 'package:upsa/helpers/theme/theme_type.dart';
import 'package:upsa/helpers/widgets/my_container.dart';
import 'package:upsa/helpers/widgets/my_spacing.dart';
import 'package:upsa/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import 'package:upsa/images.dart';

class AppSettingScreen extends StatefulWidget {
  const AppSettingScreen({Key? key}) : super(key: key);

  @override
  _AppSettingScreenState createState() => _AppSettingScreenState();
}

class _AppSettingScreenState extends State<AppSettingScreen> {
  late ThemeData theme;
  late CustomTheme customTheme;

  bool isDark = false;

  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
    customTheme = AppTheme.customTheme;
  }

  void changeDirection() {
    if (AppTheme.textDirection == TextDirection.ltr) {
      Provider.of<AppNotifier>(context, listen: false)
          .changeDirectionality(TextDirection.rtl);
    } else {
      Provider.of<AppNotifier>(context, listen: false)
          .changeDirectionality(TextDirection.ltr);
    }
    setState(() {});
  }

  void changeTheme() {
    if (AppTheme.themeType == ThemeType.light) {
      Provider.of<AppNotifier>(context, listen: false)
          .updateTheme(ThemeType.dark);
    } else {
      Provider.of<AppNotifier>(context, listen: false)
          .updateTheme(ThemeType.light);
    }
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (BuildContext context, AppNotifier value, Widget? child) {
        theme = AppTheme.theme;
        customTheme = AppTheme.customTheme;
        isDark = AppTheme.themeType == ThemeType.dark;
        return Theme(
          data: theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                  secondary: theme.colorScheme.primary.withAlpha(80))),
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              title: MyText.titleMedium(
                "Configuración de la App".tr(),
                fontWeight: 600,
              ),
              leading: InkWell(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(
                  LucideIcons.chevronLeft,
                  size: 20,
                  color: theme.colorScheme.onBackground,
                ).autoDirection(),
              ),
            ),
            body: GestureDetector(
              onPanUpdate: (details) {
                if (details.delta.dx > 0) {
                  Navigator.pop(context);
                }
              },
              child: ListView(
                padding: MySpacing.fromLTRB(20, 8, 20, 20),
                children: [
                  InkWell(
                    onTap: () {
                      changeDirection();
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Row(
                      children: [
                        MyContainer(
                          paddingAll: 12,
                          borderRadiusAll: 4,
                          color: CustomTheme.skyBlue.withAlpha(20),
                          child: Image(
                            height: 20,
                            width: 20,
                            image: AssetImage(
                                AppTheme.textDirection == TextDirection.ltr
                                    ? Images.paragraphRTLOutline
                                    : Images.paragraphLTROutline),
                            color: CustomTheme.skyBlue,
                          ),
                        ),
                        MySpacing.width(16),
                        Expanded(
                          child: MyText.bodyLarge(
                            AppTheme.textDirection == TextDirection.ltr
                                ? "${'right_to_left'.tr()} (RTL)"
                                : "${'left_to_right'.tr()} (LTR)",
                          ),
                        ),
                        MySpacing.width(16),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: theme.colorScheme.onBackground,
                        ).autoDirection(),
                      ],
                    ),
                  ),
                  MySpacing.height(20),
                  InkWell(
                    onTap: () {
                      changeTheme();
                    },
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    child: Row(
                      children: [
                        MyContainer(
                          paddingAll: 12,
                          borderRadiusAll: 4,
                          color: CustomTheme.occur.withAlpha(28),
                          child: Image(
                            height: 20,
                            width: 20,
                            image: AssetImage(!isDark
                                ? Images.darkModeOutline
                                : Images.lightModeOutline),
                            color: CustomTheme.occur,
                          ),
                        ),
                        MySpacing.width(16),
                        Expanded(
                          child: MyText.bodyLarge(
                            !isDark ? 'dark_mode'.tr() : 'light_mode'.tr(),
                          ),
                        ),
                        MySpacing.width(16),
                        Icon(
                          LucideIcons.chevronRight,
                          size: 18,
                          color: theme.colorScheme.onBackground,
                        ).autoDirection(),
                      ],
                    ),
                  ),
                  MySpacing.height(20),
                  Divider(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
