import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutkit/helpers/widgets/my_spacing.dart';
import 'package:flutkit/helpers/widgets/my_text.dart';

class ProgressEspera extends StatelessWidget {
  final ThemeData theme;

  const ProgressEspera({ Key? key,  required this.theme}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5), // Color semi-transparente
            ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          bottom: 0,
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.primary,
                  ),
                ),
                MySpacing.width(20),
                MyText.bodyMedium("Espera por favor...",
                    fontWeight: 600, letterSpacing: 0.3)
              ],
            ),
          ),
        ),
      ],
    );
  }

}
