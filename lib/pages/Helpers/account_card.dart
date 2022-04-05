import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import '../../models/family_task_data.dart';

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
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
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

class DataCard extends StatelessWidget {
  const DataCard({Key? key, required this.taskName, required this.taskColor, required this.textSpan}) : super(key: key);

  final String taskName;
  final Color taskColor;
  final TextSpan textSpan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 10, right: 10, top: 5),
      child: Card(
          color: taskColor,
          elevation: 5,
          child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(left: 16.0, right: 16, top: 15),
                    child: AutoSizeText(taskName, maxLines: 1, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                  ),
                  const Divider(
                    color: Colors.black,
                    thickness: 3,
                    indent: 16,
                    endIndent: 200,
                  ),
                  Container(
                      padding: const EdgeInsets.only(left: 16.0, right: 16, bottom: 10),
                      child : AutoSizeText.rich(
                        textSpan,
                        maxLines: 1,
                      )
                  )
                ],
              )
          )
      ),
    );
  }
}

