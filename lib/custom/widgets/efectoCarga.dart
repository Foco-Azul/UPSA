import 'dart:ui';

import 'package:flutkit/helpers/widgets/my_text.dart';
import 'package:flutter/material.dart';

class EfectoCarga {
  static void showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EfectoCargaContent();
      },
    );
  }
}

class EfectoCargaContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Stack(
      children: [
        BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.5),
          ),
        ),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.primary,
                ),
              ),
              SizedBox(width: 20),
              MyText.bodyMedium("Espera por favor...",
                  fontWeight: 600, letterSpacing: 0.3)
            ],
          ),
        ),
      ],
    );
  }
}
