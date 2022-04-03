import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'hero_dialogue_route.dart';

class GroupIDWidget extends StatefulWidget {
  const GroupIDWidget({Key? key, required this.famID}) : super(key: key);

  final String famID;

  @override
  State<GroupIDWidget> createState() => _GroupIDWidgetState();
}

class _GroupIDWidgetState extends State<GroupIDWidget> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'groupID',
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin, end: end);
      },
      child: TextButton(
        style: TextButton.styleFrom(
            elevation: 5,
            backgroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 20)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.perm_identity),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Group ID'),
            ),
          ],
        ),
        onPressed: () {
          Navigator.of(context).push(HeroDialogRoute(builder: (context) {
            return FamilyIDPopUp(famID: widget.famID);
          }));
        },
      ),
    );
  }
}

class LeaveWidget extends StatefulWidget {
  const LeaveWidget({Key? key, required this.onLeave}) : super(key: key);

  final Function() onLeave;

  @override
  State<LeaveWidget> createState() => _LeaveWidgetState();
}

class _LeaveWidgetState extends State<LeaveWidget> {
  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'leave',
      createRectTween: (begin, end) {
        return CustomRectTween(begin: begin, end: end);
      },
      child: TextButton(
        style: TextButton.styleFrom(
            primary: Colors.white,
            elevation: 5,
            backgroundColor: Colors.red,
            textStyle: const TextStyle(fontSize: 20, color: Colors.white)
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            Padding(
              padding: EdgeInsets.only(left: 8.0),
              child: Icon(Icons.exit_to_app, color: Colors.white),
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('Leave'),
            ),
          ],
        ),
        onPressed: () {
          Navigator.of(context).push(HeroDialogRoute(builder: (context) {
            return LeavePopUp(onLeave: widget.onLeave);
          }));
        },
      ),
    );
  }
}


class FamilyIDPopUp extends StatefulWidget {
  final String famID;

  const FamilyIDPopUp({Key? key, required this.famID}) : super(key: key);

  @override
  State<FamilyIDPopUp> createState() => _FamilyIDPopUpState();
}

class _FamilyIDPopUpState extends State<FamilyIDPopUp> {
  IconData _curIcon = Icons.copy;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery
          .of(context)
          .size
          .width / 2 - 150, vertical: MediaQuery
          .of(context)
          .size
          .height / 2 - 75),
      child: Hero(
        tag: "groupID",
        createRectTween: (begin, end) {
          return CustomRectTween(begin: begin, end: end);
        },
        child: Card(
            child: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(bottom: 10),
                      child: Text('Copy and send to others!', style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 1,
                          child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey)
                              ),
                              child: Text(widget.famID, style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 30))
                          ),
                        ),
                        IconButton(
                            icon: Icon(_curIcon, size: 30),
                            onPressed: () {
                              setState(() {
                                _curIcon = FontAwesomeIcons.clipboardCheck;
                                Clipboard.setData(
                                    ClipboardData(text: widget.famID));
                              });
                            }
                        )
                      ],
                    )
                  ]
              ),
            )
        ),
      ),
    );
  }
}

class LeavePopUp extends StatefulWidget {
  const LeavePopUp({Key? key, required this.onLeave}) : super(key: key);

  final Function() onLeave;

  @override
  State<LeavePopUp> createState() => _LeavePopUpState();
}

class _LeavePopUpState extends State<LeavePopUp> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery
          .of(context)
          .size
          .width / 2 - 150, vertical: MediaQuery
          .of(context)
          .size
          .height / 2 - 65),
      child: Hero(
        tag: 'leave',
        child: Card(
          elevation: 5,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red, width: 3)
            ),
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: MediaQuery.removePadding(
                removeTop: true,
                context: context,
                child: ListView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Container(
                      padding: const EdgeInsets.only(top: 15),
                      child: const Text('Leave Group', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))
                    ),
                    Container(
                      padding: const EdgeInsets.only(top: 10),
                      child: const Text('Are you sure you want to leave?', style: TextStyle(color: Colors.blueGrey))
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, right: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: TextButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          TextButton(
                              child: const Text('Confirm'),
                              onPressed: () {
                                Navigator.of(context).pop();
                                widget.onLeave();
                              }
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        )
      )
    );
  }
}
