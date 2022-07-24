import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:family_tasks/Services/database.dart';
import 'package:family_tasks/join_create.dart';
import 'package:family_tasks/pages/Helpers/account_card.dart';
import 'package:family_tasks/pages/Helpers/hero_dialogue_route.dart';
import 'package:family_tasks/pages/auth_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:family_tasks/pages/account.dart';
import 'package:family_tasks/pages/task_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_circular_text/circular_text.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'Services/authentication.dart';
import 'Services/location_callback.dart';
import 'models/user_data.dart';

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
    debugPrint('Notification!');
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
      home: const TopPage(),
    );
  }
}

class TopPage extends StatefulWidget {
  const TopPage({Key? key}) : super(key: key);

  @override
  State<TopPage> createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  late UserData user;
  DatabaseService ds = DatabaseService('');
  AuthenticationService as = AuthenticationService();

  Future<bool> _checkExists() async {
    return Future<bool>.delayed(const Duration(seconds: 1), () async {
      user = await ds.getUser();
      return await ds.famExists(user.famID);
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const AuthPage();
          } else {
            return FutureBuilder<bool>(
              future: _checkExists(),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.none:
                    return const Text('none');
                  case ConnectionState.waiting:
                    return const Scaffold(
                      body: Center(
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(),
                        )
                      )
                    );
                  case ConnectionState.active:
                    return const Text('');
                  case ConnectionState.done:
                    if (snapshot.data!) {
                      return MyHomePage(user: user, onLeave: () => setState((){}));
                    } else {
                      return JoinCreateGroupPage(user: user, onJoinOrCreate: () => setState((){}));
                    }
                }
              }
            );
          }
        }
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.user, required this.onLeave}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".
  final UserData user;
  final Function() onLeave;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final PageController _pageController = PageController();
  /* This app is made of two screens, the task view screen and the account screen
  * The task view screen holds all of the tasks that the group adds while the account screen holds data such as the
  * name of the group, tasks left, and options such as leaving.
  */
  late final List<Widget> _screens = [TaskViewPage(famID: widget.user.famID),
                                      AccountPage(famID: widget.user.famID, onLeave: widget.onLeave, location: widget.user.location)];

  late DatabaseService ds = DatabaseService(widget.user.famID);

  AuthenticationService auth = AuthenticationService();

  @override
  void initState() {
    super.initState();
    LocationCallbackHandler.initPlatformState(widget.user.location);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> getLocation () async {
    return (await ds.getUser()).location;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, // Allows keyboard to go over widgets
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset( // Icon at the top
              'assets/icon/icon_android.png',
              height: 35,
              fit: BoxFit.contain,
            ),
            const VerticalDivider(width: 5, color: Colors.transparent,),
            const Text(
              'Confrm!',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold
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
                      leading: const Icon(FontAwesomeIcons.personWalkingArrowRight),
                      title: const Text('Leave Group', style: TextStyle(fontSize: 14)),
                      onTap: () async {
                        Navigator.pop(context);
                        await ds.leaveUserFamily();
                        widget.onLeave();
                      }
                    ),
                    const Divider(thickness: 1),
                    ListTile(
                      leading: const Icon(FontAwesomeIcons.rightFromBracket),
                      title: const Text('Sign Out', style: TextStyle(fontSize: 14)),
                      onTap: () {
                        setState(() {
                          Navigator.pop(context);
                          LocationCallbackHandler.onStop();
                          auth.signOut();
                        });
                      }
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FutureBuilder<bool>(
                future: getLocation(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const CircularProgressIndicator();
                  } else {
                    return Hero(
                      tag: 'locationDrawer',
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        color: snapshot.data! ? Colors.green : Colors.blue,
                        child: Column(
                          children: [
                            Material(
                              color: Colors.transparent,
                              child: ListTile(
                                  leading: const Icon(FontAwesomeIcons.locationDot),
                                  title: const Text('Location', style: TextStyle(fontSize: 14)),
                                  onTap: () async {
                                    Navigator.of(context).push(
                                        HeroDialogRoute(builder: (context) {
                                          return LocationActivationWidget(
                                              locationEnabled: snapshot.data!,
                                              onActivate: () async {
                                                Navigator.pop(context);
                                                switch (await LocationCallbackHandler.onStart()) {
                                                  case LocationStart.notificationFail:
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must enable notifications')));
                                                    break;
                                                  case LocationStart.locationWhenInUseFail:
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must enable location when in use')));
                                                    break;
                                                  case LocationStart.locationAlwaysFail:
                                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('You must enable location always')));
                                                    break;
                                                  case LocationStart.success:
                                                    ds.updateUserLocation(true);
                                                    setState(() {});
                                                }
                                              },
                                              onDisable: () async {
                                                Navigator.pop(context);
                                                LocationCallbackHandler.onStop();
                                                ds.updateUserLocation(false);
                                                setState(() {});
                                              },
                                              heroTag: 'locationDrawer');
                                        }));
                                  }
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              )
            ),
          ]
        )
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView(
            controller: _pageController,
            children: _screens,
          ),
          Positioned(
            bottom: 30,
            child: SmoothPageIndicator(
              controller: _pageController,
              count: 2,
              effect: const WormEffect(
                activeDotColor: Colors.lightBlueAccent,
                spacing: 12
              ),
            )
          )
        ],
      ),
    );
  }

}