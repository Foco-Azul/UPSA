import 'package:flutkit/custom/utils/push_notifications_service.dart';
import 'package:flutkit/homes/homes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart'; 
import 'package:provider/provider.dart';
import 'package:flutkit/helpers/localizations/app_localization_delegate.dart';
import 'package:flutkit/helpers/localizations/language.dart';
import 'package:flutkit/helpers/theme/app_notifier.dart';
import 'package:flutkit/helpers/theme/app_theme.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.initializeApp();
  AppTheme.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider( 
      providers:[
        ChangeNotifierProvider<AppNotifier>(create: (context) => AppNotifier()),
      ],
      child: MyApp(initialScreen: HomesScreen()),
    )
  ); 
} 
class MyApp extends StatelessWidget {
  final Widget initialScreen;

  MyApp({required this.initialScreen});
  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (BuildContext context, AppNotifier value, Widget? child) {
        return GetMaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.theme,
          title: "NIBU",
          home: initialScreen, // Ruta inicial
          builder: (context, child) {
            return Directionality(
              textDirection: AppTheme.textDirection,
              child: child ?? Container(),
            );
          },
          localizationsDelegates: [
            AppLocalizationsDelegate(context),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: Language.getLocales(),
        );
      }
    );
  }
}
