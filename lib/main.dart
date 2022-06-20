import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:family_tasks/Services/database.dart';
import 'package:family_tasks/Services/location_callback.dart';
import 'package:family_tasks/pages/Helpers/hero_dialogue_route.dart';
import 'package:family_tasks/pages/auth_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:family_tasks/pages/account.dart';
import 'package:family_tasks/pages/task_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_circular_text/circular_text.dart';

import 'Services/authentication.dart';
import 'Services/location_service.dart';

late SharedPreferences prefs; // Used to store family ID on the phone

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widget initialization
  await DatabaseService.initializeFirebase(); // Initialize Firebase Database
  await dotenv.load(); // Load environment variables
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: Colors.blue,
            ledColor: Colors.white)
      ],
      // Channel groups are only visual and are not required
      channelGroups: [
        NotificationChannelGroup(
            channelGroupkey: 'basic_channel_group',
            channelGroupName: 'Basic group')
      ],
      debug: true
  );
  AwesomeNotifications().actionStream.listen((ReceivedNotification receivedNotification){
        print('Notification!');
      }
  );
  runApp(const FamilyTasks());
}

class FamilyTasks extends StatelessWidget {
  const FamilyTasks({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Confrm!',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Confrm!'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  final GlobalKey<TaskViewPageState> _keyTaskView = GlobalKey(), _keyAccount = GlobalKey(); // Used to control state of pages
  /* This app is made of two screens, the task view screen and the account screen
  * The task view screen holds all of the tasks that the group adds while the account screen holds data such as the
  * name of the group, tasks left, and options such as leaving.
  */
  late final List<Widget> _screens = [TaskViewPage(key: _keyTaskView),
                                      AccountPage(key: _keyAccount, onJoinOrCreate: _resetFamID, onLeave: _onLeave, onLocationSetting: _onLocationSetting)];
  int _curPage = 0;
  bool _haveSetFamID = false; // If the family ID exists

  ReceivePort port = ReceivePort();

  AuthenticationService auth = AuthenticationService();

  @override
  void initState() {
    super.initState();
    _initializePreference().whenComplete(() {
      prefs.remove('location');
      prefs.remove('famID');
      _setUp();
      LocationCallbackHandler.initPlatformState(prefs.getBool('location') ?? false);
    }); // Initialize prefs and set the family ID
    if (IsolateNameServer.lookupPortByName(
        LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    port.listen( (dynamic data) async {
        print('Got data in app!');
      },
    );
  }

  // Function called when the family ID is submitted
  void _resetFamID(String famID) {
    prefs.setString('famID', famID);
    _setUp();
    _pageController.animateToPage(0, curve: Curves.easeOut, duration: const Duration(milliseconds: 500));
  }

  // When leaving the family
  void _onLeave() {
    prefs.remove('famID');
    _setUp();
  }

  void _onLocationSetting(bool set) {
    prefs.setBool('location', set);
    _setUp();
  }

  // Set the family ID and reset the widgets
  void _setUp() {
    String? ID = prefs.getString('famID');
    bool? locationEnabled = prefs.getBool('location');
    _haveSetFamID = ID != null;
    // If no family ID, force user to set family ID
    if (_pageController.hasClients && !_haveSetFamID) {
      _pageController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    }
    // Set family ID in each widget
    TaskViewPageState.setFamID(ID);
    AccountPageState.setUp(ID, locationEnabled);
    if (_keyAccount.currentState != null) {
      _keyAccount.currentState!.setState((){});
    }
    if (_keyTaskView.currentState != null) {
      _keyTaskView.currentState!.setState((){});
    }
    setState(() {});
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _initializePreference() async{
    prefs = await SharedPreferences.getInstance();
  }

  void _onPageChanged(int index) {
    setState(() {
      _curPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Allows keyboard to go over widgets
      appBar: _haveSetFamID ? AppBar(
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
      ) : null,
      drawer: _haveSetFamID ? Drawer(
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
              child: Text('User Information', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
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
                        title: Text('Name: ${auth.name ?? 'No Name'}', style: const TextStyle(fontSize: 18))
                    ),
                    const Divider(thickness: 1),
                    ListTile(
                        leading: const Icon(Icons.email),
                        title: Text('Email: ${auth.email ?? 'No email'}', style: const TextStyle(fontSize: 18))
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('Actions', style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
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
                      leading: const Icon(FontAwesomeIcons.personWalkingArrowRight),
                      title: const Text('Leave Group', style: TextStyle(fontSize: 18)),
                      onTap: _onLeave
                    ),
                    const Divider(thickness: 1),
                    ListTile(
                      leading: const Icon(FontAwesomeIcons.rightFromBracket),
                      title: const Text('Sign Out', style: TextStyle(fontSize: 18)),
                      onTap: () {
                        setState(() {
                          Navigator.pop(context);
                          _onLeave();
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
      ) : null,
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return AuthPage(onLogin: _setUp);
          } else {
            return PageView(
              controller: _pageController,
              children: _screens,
              onPageChanged: _onPageChanged,
              // Scroll between pages only if you set the family ID
              physics: _haveSetFamID ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
            );
          }
        }
      ),
      floatingActionButton: _haveSetFamID ? SpeedDial(
        spaceBetweenChildren: 12,
        heroTag: 'archive', // Hero animation when archive is clicked
        child: const Icon(FontAwesomeIcons.bars),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            backgroundColor: Colors.green,
            label: 'New Task',
            onTap: () async {
              // We animate to the task view page if necessary
              _pageController.animateToPage(0,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 500)
              );
              // Wait for animation to finish if necessary
              Future.delayed(Duration(milliseconds: _curPage == 0 ? 0 : 500)).whenComplete(() async {
                if (_keyTaskView.currentState != null) {
                  if (! (await _keyTaskView.currentState!.addTask())) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text('Maximum of 20 tasks reached.')
                    ));
                  }
                }
              });
            }
          ),
          SpeedDialChild(
              child: const Icon(Icons.inbox),
              backgroundColor: Colors.orange,
              label: 'Archive',
              onTap: () async {
                _pageController.animateToPage(0,
                    curve: Curves.easeOut,
                    duration: const Duration(milliseconds: 500)
                );
                Future.delayed(Duration(milliseconds: _curPage == 0 ? 0 : 500)).whenComplete(() {
                  // Push hero dialog route, creates animation
                  Navigator.of(context).push(HeroDialogRoute(builder: (context) {
                    if (_keyTaskView.currentState != null) {
                      // Create the archive card list from the widget
                      return _keyTaskView.currentState!.createArchiveCardList(
                          EdgeInsets.only(top: MediaQuery.of(context).size.height / 6, left: 30, right: 30,
                              bottom: MediaQuery.of(context).size.height / 6
                          )
                      );
                    }
                    return const SizedBox.shrink(); // Should never happen
                  }));
                });
              }
          ),
          SpeedDialChild(
            backgroundColor: Colors.grey,
            child: _curPage == 0 ? const Icon(Icons.people) : const Icon(FontAwesomeIcons.clipboard),
            label: _curPage == 0 ? 'Family' : 'Tasks',
            onTap: () {
              // Switch between task view and account page
              _pageController.animateToPage(1 - _curPage,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 500)
              );
            }
          )
        ]
      ) : null,
    );
  }

}