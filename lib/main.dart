import 'dart:isolate';
import 'dart:ui';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:family_tasks/Services/database.dart';
import 'package:family_tasks/pages/Helpers/hero_dialogue_route.dart';
import 'package:flutter/material.dart';
import 'package:family_tasks/pages/account.dart';
import 'package:family_tasks/pages/task_view.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_circular_text/circular_text.dart';
import 'package:permission_handler/permission_handler.dart';

import 'Services/location_callback.dart';
import 'Services/location_service.dart';

late SharedPreferences prefs; // Used to store family ID on the phone

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensure widget initialization
  await DatabaseService.initializeFirebase(); // Initialize Firebase Database
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
                                      AccountPage(key: _keyAccount, onJoinOrCreate: _resetFamID, onLeave: _onLeave)];
  int _curPage = 0;
  bool _haveSetFamID = false; // If the family ID exists

  ReceivePort port = ReceivePort();

  @override
  void initState() {
    super.initState();
    _initializePreference().whenComplete(_setFamID); // Initialize prefs and set the family ID
    if (IsolateNameServer.lookupPortByName(
        LocationServiceRepository.isolateName) !=
        null) {
      IsolateNameServer.removePortNameMapping(
          LocationServiceRepository.isolateName);
    }

    IsolateNameServer.registerPortWithName(
        port.sendPort, LocationServiceRepository.isolateName);

    port.listen( (dynamic data) async {
        await _newData(data);
      },
    );
    initPlatformState();
  }

  // Function called when the family ID is submitted
  void _resetFamID(String famID) {
    prefs.setString('famID', famID);
    _setFamID();
    _pageController.animateToPage(0, curve: Curves.easeOut, duration: const Duration(milliseconds: 500));
  }

  // When leaving the family
  void _onLeave() {
    prefs.remove('famID');
    _setFamID();
  }

  // Set the family ID and reset the widgets
  void _setFamID() {
    String? ID = prefs.getString('famID');
    _haveSetFamID = ID != null;
    // If no family ID, force user to set family ID
    if (!_haveSetFamID) {
      _pageController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    }
    // Set family ID in each widget
    TaskViewPageState.setFamID(ID);
    AccountPageState.setFamID(ID);
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

  Future<void> initPlatformState() async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    print('Initialization done');
    print('Running');
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
            TextButton(
              onPressed: _onStart, child: Text('start'),
            )
          ],
        ),
        centerTitle: true,
      ),
      body: AnimatedContainer( // The background is light blue on task view and purple on account
        duration: const Duration(milliseconds: 500),
        color: _curPage == 0 ? Colors.lightBlue : Colors.deepPurple,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            // Change gradient based on the current page
            decoration: _curPage == 0 ? const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.1, 0.3, 0.5, 0.7, 0.95, 0.99],
                  colors: [Colors.indigoAccent, Colors.blueAccent, Colors.blue, Colors.lightBlue, Colors.yellow, Colors.orangeAccent],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(27),
                  bottomLeft: Radius.circular(27),
                )
            ) : BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  stops: [0.2, 0.5, 0.7, 0.97, 0.99],
                  colors: [Colors.indigo, Colors.indigoAccent, Colors.blueAccent, Colors.white, Colors.white70],
                ),
                borderRadius: BorderRadius.only(
                  topRight: const Radius.circular(27),
                  bottomRight: const Radius.circular(27),
                  topLeft: _haveSetFamID ? Radius.zero : const Radius.circular(27),
                  bottomLeft: _haveSetFamID ? Radius.zero : const Radius.circular(27),
                )
            ),
            child: PageView(
              controller: _pageController,
              children: _screens,
              onPageChanged: _onPageChanged,
              // Scroll between pages only if you set the family ID
              physics: _haveSetFamID ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
            ),
          ),
        ),
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

  void _onStart() async {
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        // This is just a basic example. For real apps, you must show some
        // friendly dialog box before call the request method.
        // This is very important to not harm the user experience
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
    if (await _checkLocationPermission()) {
      await _startLocator();
    } else {
      // show error
    }
  }

  Future<bool> _checkLocationPermission() async {
    return await Permission.locationAlways.request().isGranted;
  }

  Future<void> _newData(LocationDto? data) async {
    if (data != null) {
      print('Got data in app!');
    }
    return;
  }

  Future<void> _startLocator() async{
    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(LocationCallbackHandler.callback,
        initCallback: LocationCallbackHandler.initCallback,
        initDataCallback: data,
        disposeCallback: LocationCallbackHandler.disposeCallback,
        iosSettings: const IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION, distanceFilter: 20),
        autoStop: false,
        androidSettings: const AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 60,
            distanceFilter: 20,
            client: LocationClient.google,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Location tracking',
                notificationTitle: 'Start Location Tracking',
                notificationMsg: 'You will be notified when you are close to a task location',
                notificationBigMsg:
                'You have activated the location settings option. When you are close to a location of a task, the app will notify you. You can turn this feature off at any time in the Confrm! app or in your settings.',
                notificationIconColor: Colors.blue,
                notificationTapCallback:
                LocationCallbackHandler.notificationCallback)));
  }
}