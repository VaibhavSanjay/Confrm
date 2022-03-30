import 'package:family_tasks/Services/database.dart';
import 'package:family_tasks/pages/Helpers/hero_dialogue_route.dart';
import 'package:flutter/material.dart';
import 'package:family_tasks/pages/account.dart';
import 'package:family_tasks/pages/task_view.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_circular_text/circular_text.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseService.initializeFirebase();
  runApp(const FamilyTasks());
}

class FamilyTasks extends StatelessWidget {
  const FamilyTasks({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Family Tasks',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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
  final GlobalKey<TaskViewPageState> _keyTaskView = GlobalKey(), _keyAccount = GlobalKey();
  late final List<Widget> _screens = [TaskViewPage(key: _keyTaskView),
                                      AccountPage(key: _keyAccount, onJoinOrCreate: _resetFamID, onLeave: _onLeave)];
  late SharedPreferences prefs;
  int _curPage = 0;
  bool _haveSetFamID = false;

  @override
  void initState() {
    super.initState();
    _initializePreference().whenComplete(_setFamID);
  }

  void _resetFamID(String famID) {
    prefs.setString('famID', famID);
    _setFamID();
    _pageController.animateToPage(0, curve: Curves.easeOut, duration: const Duration(milliseconds: 500));
  }

  void _onLeave() {
    prefs.remove('famID');
    _setFamID();
  }

  void _setFamID() {
    String? ID = prefs.getString('famID');
    _haveSetFamID = ID != null;
    if (!_haveSetFamID) {
      _pageController.animateToPage(1, duration: const Duration(milliseconds: 500), curve: Curves.easeOut);
    }
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

  void _onPageChanged(int index) {
    setState(() {
      _curPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset(
              'assets/icon/icon_android.png',
              height: 40,
              fit: BoxFit.contain,
            ),
            Container(
              padding: EdgeInsets.only(top: 220),
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
            )
          ],
        ),
        centerTitle: true,
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        color: _curPage == 0 ? Colors.lightBlue : Colors.deepPurple,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
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
              physics: _haveSetFamID ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics(),
            ),
          ),
        ),
      ),
      floatingActionButton: _haveSetFamID ? SpeedDial(
        spaceBetweenChildren: 12,
        heroTag: 'archive',
        child: const Icon(FontAwesomeIcons.bars),
        children: [
          SpeedDialChild(
            child: const Icon(Icons.add),
            backgroundColor: Colors.green,
            label: 'New Task',
            onTap: () async {
              _pageController.animateToPage(0,
                  curve: Curves.easeOut,
                  duration: const Duration(milliseconds: 500)
              );
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
                  Navigator.of(context).push(HeroDialogRoute(builder: (context) {
                    if (_keyTaskView.currentState != null) {
                      return _keyTaskView.currentState!.createArchiveCardList(
                          EdgeInsets.only(top: MediaQuery.of(context).size.height / 6, left: 30, right: 30,
                              bottom: MediaQuery.of(context).size.height / 6
                          )
                      );
                    }
                    return const SizedBox.shrink();
                  }));
                });
              }
          ),
          SpeedDialChild(
            backgroundColor: Colors.grey,
            child: _curPage == 0 ? const Icon(Icons.people) : const Icon(FontAwesomeIcons.clipboard),
            label: _curPage == 0 ? 'Family' : 'Tasks',
            onTap: () {
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