import 'package:auto_size_text/auto_size_text.dart';
import 'package:family_tasks/Services/authentication.dart';
import 'package:flutter/material.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false, // Allows keyboard to go over widgets
        appBar: AppBar(),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 0.03 * MediaQuery.of(context).size.height, bottom: 10),
                child: Image.asset( // Icon at the top
                    'assets/icon/icon_android.png',
                    fit: BoxFit.contain,
                    height: 0.2 * MediaQuery.of(context).size.height
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.35,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: AutoSizeText(
                        "Welcome to Confrm!",
                        maxLines: 2,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: MediaQuery.of(context).size.height * 0.06,
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top:15, right:15, left: 15),
                      child: AutoSizeText(
                        "Please join or create a group to start tracking your tasks.",
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: MediaQuery.of(context).size.height * 0.03,
                            color: Colors.white,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.lightBlue,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                      minimumSize: Size(MediaQuery.of(context).size.width * 0.4, 50),
                    ),
                    onPressed: () {
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
                    child: const Text('Create', style: TextStyle(fontSize: 18),),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.indigo,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0)),
                      minimumSize: Size(MediaQuery.of(context).size.width * 0.4, 50), //////// HERE
                    ),
                    onPressed: () {
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
                    },
                    child: const Text('Join', style: TextStyle(fontSize: 18),),
                  )
                ],
              )
            ],
          ),
        ),
    );
  }
}
