
import 'package:upsa/custom/widgets/tarjetas.dart';
import 'package:upsa/helpers/theme/app_notifier.dart';
import 'package:upsa/helpers/theme/app_theme.dart';
import 'package:upsa/helpers/widgets/my_spacing.dart';
import 'package:upsa/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Actividades extends StatefulWidget {
  const Actividades({Key? key}) : super(key: key);

  @override
  _ActividadesState createState() => _ActividadesState();
}

class _ActividadesState extends State<Actividades> {
  late ThemeData theme;

  @override
  void initState() {
    super.initState();
    theme = AppTheme.theme;
  }

  @override
    Widget build(BuildContext context) {
    return Consumer<AppNotifier>(
      builder: (BuildContext context, AppNotifier value, Widget? child) {
        return Scaffold(
          body: ListView(
            padding: MySpacing.all(0),
            children: <Widget>[
              Container(
                margin: MySpacing.all(16),
                child: MyText("Actividades"),
              ),
              Container(
                  margin: MySpacing.all(16),
                  child: CircularCard(
                    elevation: 2,
                  )),
            ],
          )
        );
      },
    );
  }
}
