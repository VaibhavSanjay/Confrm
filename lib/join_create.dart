import 'package:family_tasks/Services/authentication.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_text/circular_text/model.dart';
import 'package:flutter_circular_text/circular_text/widget.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'Services/database.dart';
import 'models/user_data.dart';

class JoinCreateGroupPage extends StatefulWidget {
  const JoinCreateGroupPage({Key? key, required this.onJoinOrCreate, required this.user}) : super(key: key);

  final Function() onJoinOrCreate;
  final UserData user;

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
        color: Colors.blue,
        elevation: 5,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(15))
        ),
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
                            .height / 8, color: Colors.white)
                    ),
                    Container(padding: const EdgeInsets.only(left: 20),
                        child: Text(text, style: const TextStyle(
                            fontSize: 50, color: Colors.white)))
                  ]
              ),
              Container(
                width: MediaQuery
                    .of(context)
                    .size
                    .width / 3,
                padding: const EdgeInsets.only(top: 10),
                child: Text(desc, style: const TextStyle(fontSize: 16, color: Colors.white)),
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
      resizeToAvoidBottomInset: false, // Allows keyboard to go over widgets
      appBar: AppBar(
        title: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset( // Icon at the top
              'assets/icon/icon_android.png',
              height: 40,
              fit: BoxFit.contain,
            ),
            Container(  // Curving text Confrm!
              padding: const EdgeInsets.only(top: 220),
              child: CircularText(
                children: [
                  TextItem(
                      text: const Text(
                        'Confrm!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      space: 8,
                      startAngle: -87,
                      startAngleAlignment: StartAngleAlignment.center
                  )
                ],
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
        drawer: Drawer(
            child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                      ),
                      child: Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            Opacity(
                              opacity: 0.5,
                              child: Image.asset( // Icon at the top
                                'assets/icon/icon_android.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const Text('Account', style: TextStyle(fontSize: 60, color: Colors.white, fontWeight: FontWeight.bold))
                          ]
                      )
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text('User Information', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.grey[300],
                      child: Column(
                        children: [
                          ListTile(
                              leading: const Icon(Icons.person),
                              title: Text('Name: ${widget.user.name}', style: const TextStyle(fontSize: 14))
                          ),
                          const Divider(thickness: 1),
                          ListTile(
                              leading: const Icon(Icons.email),
                              title: Text('Email: ${widget.user.email}', style: const TextStyle(fontSize: 14))
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Text('Actions', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: Colors.red[500],
                      child: Column(
                        children: [
                          ListTile(
                              leading: const Icon(FontAwesomeIcons.rightFromBracket),
                              title: const Text('Sign Out', style: TextStyle(fontSize: 14)),
                              onTap: () {
                                setState(() {
                                  Navigator.pop(context);
                                  auth.signOut();
                                });
                              }
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
            )
        ),
        body: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.blue,
                  Colors.white,
                ],
              )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 20),
              _getButton(
                FontAwesomeIcons.userPlus,
                'Create',
                'Create a new group. Send the group ID to your team so they can join.',
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
                                        await ds.setUserFamily(famID);
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
              const Divider(
                height: 25,
                color: Colors.transparent,
              ),
              _getButton(
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
                                        await ds.famExists(_input.isEmpty
                                            ? '0'
                                            : _input);
                                        if (_formKey
                                            .currentState!
                                            .validate()) {
                                          WidgetsBinding.instance.addPostFrameCallback((_) {
                                            Navigator.pop(context);
                                          });
                                          await ds.setUserFamily(_input);
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
            ],
          ),
        ),
    );
  }
}
