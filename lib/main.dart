import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutkit/custom/screens/bienvenida/bienvenida_screen.dart';
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
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  //You will need to initialize AppThemeNotifier class for theme changes.
  WidgetsFlutterBinding.ensureInitialized();
  await PushNotificationService.initializeApp();
  // MobileAds.instance.initialize();
  AppTheme.init();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? esNuevo = prefs.getBool('esNuevo') ?? true;
  Widget initialScreen = esNuevo == true ? WelcomeScreen() : HomesScreen();
  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider<AppNotifier>(create: (context) => AppNotifier()),
      ],
      child: MyApp(initialScreen: initialScreen),
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
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            title: "UPSA",
            home: initialScreen, // Ruta inicial
            builder: (context, child) {
              return Directionality(
                textDirection: AppTheme.textDirection,
                child: child ?? Container(),
              );
            },
            localizationsDelegates: [
              AppLocalizationsDelegate(context),
              // Add this line
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: Language.getLocales(),
            // home: IntroScreen(),
            // home: CookifyShowcaseScreen(),
          );
        });

  }
}
