import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart'; 
import 'package:provider/provider.dart';
import 'package:upsa/custom/screens/inicio/screen_home.dart';
import 'package:upsa/helpers/localizations/app_localization_delegate.dart';
import 'package:upsa/helpers/localizations/language.dart';
import 'package:upsa/helpers/theme/app_notifier.dart';
import 'package:upsa/helpers/theme/app_theme.dart';

Future<void> main() async {
  //You will need to initialize AppThemeNotifier class for theme changes.
  WidgetsFlutterBinding.ensureInitialized();
  // MobileAds.instance.initialize();
  AppTheme.init();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(
    MultiProvider(
      providers:[
        ChangeNotifierProvider<AppNotifier>(create: (context) => AppNotifier()),
      ],
    child: MyApp(),
    )
  );
}
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
        builder: (BuildContext context, AppNotifier value, Widget? child) {
          return GetMaterialApp(
            debugShowCheckedModeBanner: false,
            theme: AppTheme.theme,
            home: HomesScreen(),
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
