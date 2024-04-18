
import 'package:upsa/custom/widgets/tarjetas.dart';
import 'package:upsa/helpers/theme/app_notifier.dart';
import 'package:upsa/helpers/theme/app_theme.dart';
import 'package:upsa/helpers/widgets/my_spacing.dart';
import 'package:upsa/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  late ThemeData theme;
  double _elevation = 2;
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
                child: MyText("Inicio"),
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

