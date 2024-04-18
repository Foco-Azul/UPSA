import 'package:flutter/material.dart';
import 'package:upsa/helpers/widgets/my_spacing.dart';
import 'package:upsa/helpers/widgets/my_text.dart';
import 'package:upsa/images.dart';

class SimpleCard extends StatefulWidget {
  final double elevation;

  const SimpleCard({Key? key, this.elevation = 1}) : super(key: key);

  @override
  _SimpleCardState createState() => _SimpleCardState();
}

class _SimpleCardState extends State<SimpleCard> {
  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Card(
      elevation: widget.elevation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image(
            image: AssetImage(Images.profileBanner),
            height: 200,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fill,
          ),
          Container(
            padding: MySpacing.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MyText.titleMedium("Title", fontWeight: 600),
                    MyText.bodyMedium(
                        "Lorem ipsum, or lipsum as it is sometimes known",
                        height: 1.2,
                        fontWeight: 500),
                    Container(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                          onPressed: () {},
                          child: MyText.labelMedium("ACTION",
                              fontWeight: 600,
                              color: theme.colorScheme.primary)),
                    )
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class CircularCard extends StatefulWidget {
  final double elevation;

  const CircularCard({Key? key, this.elevation = 1}) : super(key: key);

  @override
  _CircularCardState createState() => _CircularCardState();
}

class _CircularCardState extends State<CircularCard> {
  late ThemeData theme;

  @override
  Widget build(BuildContext context) {
    theme = Theme.of(context);
    return Card(
      elevation: widget.elevation,
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Image(
            image: AssetImage(Images.profileBanner),
            height: 180,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.fill,
          ),
          Container(
            padding: MySpacing.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    MyText.titleMedium("¡Arranca la copa UPSA!", fontWeight: 600),
                    MyText.bodyMedium(
                        "¡Estamos listos para iniciar la Copa UPSA! Este lunes 18 de marzo comienza...",
                        height: 1.2,
                        fontWeight: 500),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}