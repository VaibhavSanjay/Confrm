import 'package:auto_size_text/auto_size_text.dart';
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

class LocationInfo extends StatelessWidget {
  const LocationInfo({Key? key, required this.bgColor, required this.icon, required this.title,
    required this.subtitle, required this.confirmText, required this.onCancel, required this.onConfirm,
    required this.iconBgColor}) : super(key: key);

  final Color bgColor;
  final Color iconBgColor;
  final Icon icon;
  final String title;
  final String subtitle;
  final String confirmText;
  final Function() onCancel;
  final Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Stack(
                alignment: Alignment.topCenter,
                children: [
                  Container(
                      color: bgColor,
                      height: 80
                  ),
                  Container(
                      transform: Matrix4.translationValues(0, 30, 0),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 5,
                        ),
                        color: iconBgColor,
                      ),
                      child: icon
                  ),
                ],
              ),
              Container(
                  padding: const EdgeInsets.only(top: 32),
                  child: Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold))
              ),
              Container(
                  padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
                  child: Text(subtitle, style: const TextStyle(fontSize: 18), textAlign: TextAlign.justify)
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                      child: const Text('Cancel'),
                      onPressed: onCancel
                  ),
                  TextButton(
                      child: Text(confirmText),
                      onPressed: onConfirm
                  )
                ],
              )
            ],
          ),
        )
    );
  }
}


