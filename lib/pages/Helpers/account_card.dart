import 'package:flutter/material.dart';

class AccountCard extends StatefulWidget {
  const AccountCard({Key? key, this.bgColor = Colors.white, this.iconColor = Colors.black, this.opacity = 1,
    required this.icon, required this.title, required this.subtitle, required this.iconSize, required this.bottomPadding}) : super(key: key);

  final Color bgColor;
  final Color iconColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final double opacity;
  final double iconSize;
  final double bottomPadding;

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2.5),
      child: Card(
          color: widget.bgColor,
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                height: 100,
                width: double.infinity,
                child: ClipRect(
                  child: Container(
                    transform: Matrix4.translationValues(0, -widget.bottomPadding, 0),
                    child: Opacity(
                      opacity: widget.opacity,
                      child: Icon(
                          widget.icon,
                          size: widget.iconSize,
                          color: widget.iconColor
                      ),
                    ),
                  )
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text(widget.title, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                    Text(widget.subtitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                  ],
                ),
              )
            ],
          )
      ),
    );
  }
}
