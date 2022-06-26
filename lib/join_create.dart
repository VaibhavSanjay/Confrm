import 'package:auto_size_text/auto_size_text.dart';
import 'package:family_tasks/Services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'Services/database.dart';

class JoinCreateGroupPage extends StatefulWidget {
  const JoinCreateGroupPage({Key? key, required this.onJoinOrCreate}) : super(key: key);

  final Function() onJoinOrCreate;

  @override
  State<JoinCreateGroupPage> createState() => _JoinCreateGroupPageState();
}

class _JoinCreateGroupPageState extends State<JoinCreateGroupPage> {
  String _input = '';
  bool _foundFamily = false;
  final _formKey = GlobalKey<FormState>();
  DatabaseService ds = DatabaseService('');
  AuthenticationService auth = AuthenticationService();

  Widget _getButton(IconData icon, String text, String desc,
      Function() onPressed) {
    return InkWell(
      onTap: onPressed,
      child: Card(
        elevation: 5,
        child: Container(
          margin: const EdgeInsets.only(
              top: 20, bottom: 20, left: 10, right: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                  children: [
                    Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 0),
                        child: Icon(icon, size: MediaQuery
                            .of(context)
                            .size
                            .height / 8, color: Colors.blueAccent)
                    ),
                    Container(padding: const EdgeInsets.only(left: 20),
                        child: Text(text, style: const TextStyle(
                            fontSize: 50, color: Colors.blueAccent)))
                  ]
              ),
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width / 3,
                padding: const EdgeInsets.only(top: 10),
                child: Text(desc, style: const TextStyle(fontSize: 16)),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(bottom: 5),
        child: SingleChildScrollView(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Material(
                          elevation: 10,
                          color: Colors.transparent,
                          child: Container(
                            decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  stops: [0.1, 0.5, 0.7],
                                  colors: [
                                    Colors.lightBlueAccent,
                                    Colors.lightBlue,
                                    Colors.blueAccent
                                  ],
                                ),
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(27),
                                  topRight: Radius.circular(27),
                                )
                            ),
                            width: double.infinity,
                            height: 100,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(top: 15),
                        child: Card(
                          elevation: 10,
                          child: Padding(
                            padding: EdgeInsets.all(8.0),
                            child: AutoSizeText(
                                'Welcome!',
                                style: TextStyle(
                                    fontSize: 45,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue
                                ),
                                maxLines: 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: _getButton(
                              FontAwesomeIcons.userPlus,
                              'Create',
                              'Create a New Task Listing. Send the group ID to those you want to add.',
                                  () {
                                _input = '';
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Form(
                                        key: _formKey,
                                        child: AlertDialog(
                                            title: const Text(
                                                'Create New Group',
                                                style: TextStyle(
                                                    fontWeight: FontWeight
                                                        .bold)),
                                            contentPadding: const EdgeInsets
                                                .only(
                                                top: 20, left: 24, right: 24),
                                            content: TextFormField(
                                              maxLength: 20,
                                              decoration: const InputDecoration(
                                                  hintText: 'Group Name',
                                                  border: OutlineInputBorder(),
                                                  counterText: ''
                                              ),
                                              onChanged: (String? value) {
                                                _input = value ?? '';
                                              },
                                              validator: (String? value) {
                                                if (value == null ||
                                                    value.isEmpty) {
                                                  return 'Please enter a name';
                                                }
                                                return null;
                                              },
                                            ),
                                            actions: [
                                              TextButton(
                                                  child: const Text('Cancel'),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  }
                                              ),
                                              TextButton(
                                                  child: const Text('Create'),
                                                  onPressed: () async {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      Navigator.pop(context);
                                                      String famID =
                                                      await ds.addNewFamily(
                                                          _input);
                                                      await ds.setUserFamily(auth.id!, famID);
                                                      widget.onJoinOrCreate();
                                                    }
                                                  }
                                              ),
                                            ]
                                        ),
                                      );
                                    }
                                );
                              },
                            ),
                          ),
                          const Divider(
                            thickness: 8,
                            indent: 20,
                            endIndent: 20,
                            color: Colors.black,
                          ),
                          Container(
                              padding: const EdgeInsets.only(top: 20),
                              child: _getButton(
                                  FontAwesomeIcons.peopleRoof,
                                  'Join',
                                  'If someone already created a group, join it with their ID.',
                                      () {
                                    _input = '';
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return Form(
                                            key: _formKey,
                                            child: AlertDialog(
                                                title: const Text('Join Group',
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold)),
                                                contentPadding: const EdgeInsets
                                                    .only(top: 20,
                                                    right: 24,
                                                    left: 24),
                                                content: TextFormField(
                                                  maxLength: 30,
                                                  decoration: const InputDecoration(
                                                      hintText: 'Group ID',
                                                      border: OutlineInputBorder(),
                                                      counterText: ''
                                                  ),
                                                  onChanged: (String? value) {
                                                    _input = value ?? '';
                                                  },
                                                  validator: (String? value) {
                                                    return _foundFamily
                                                        ? null
                                                        : 'Invalid ID';
                                                  },
                                                ),
                                                actions: [
                                                  TextButton(
                                                      child: const Text(
                                                          'Cancel'),
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      }
                                                  ),
                                                  TextButton(
                                                      child: const Text('Join'),
                                                      onPressed: () async {
                                                        _foundFamily =
                                                        await ds.famExists(auth.id!,
                                                        _input.isEmpty
                                                            ? '0'
                                                            : _input);
                                                        if (_formKey
                                                            .currentState!
                                                            .validate()) {
                                                          WidgetsBinding.instance!.addPostFrameCallback((_) {
                                                            Navigator.pop(context);
                                                          });
                                                          await ds.setUserFamily(auth.id!, _input);
                                                          widget.onJoinOrCreate();
                                                        }
                                                      }
                                                  ),
                                                ]
                                            ),
                                          );
                                        }
                                    );
                                  }
                              )
                          )
                        ],
                      ),
                    ),
                  ],
                )
              ]
          ),
        ),
      ),
    );
  }
}
