import 'package:auto_size_text/auto_size_text.dart';
import 'package:family_tasks/pages/Helpers/user_data_helper.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

import '../../models/family_task_data.dart';
import '../../models/user_data.dart';
import 'constants.dart';
import 'hero_dialogue_route.dart';

Widget _getTimeText(Duration dur) {
  Duration duration = dur.abs();
  String time;
  String text;

  if (duration.compareTo(const Duration(hours: 1)) < 0) {
    time = '${duration.inMinutes}';
    text = duration.inMinutes == 1 ? 'minute' : 'minutes';
  } else if (duration.compareTo(const Duration(days: 3)) < 0) {
    time = '${duration.inHours}';
    text = duration.inHours == 1 ? 'hour' : 'hours';
  } else {
    time = '${duration.inDays}';
    text = 'days';
  }

  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(time, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),),
      Text(text)
    ],
  );
}

class ContributeCard extends StatelessWidget {
  const ContributeCard({Key? key, required this.users, required this.tasksCompleted, required this.curUser}) : super(key: key);

  final List<UserData> users;
  final List<int> tasksCompleted;
  final int curUser;

  bool _tasksDone() {
    return tasksCompleted.any((element) => element != 0);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.lightBlue,
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: Align(
              alignment: Alignment.center,
              child: _tasksDone() ? PieChart(
                PieChartData(
                  sectionsSpace: 0,
                  centerSpaceRadius: 20,
                  sections: List.generate(users.length, (i) {
                    final isCurrentUser = i == curUser;
                    final fontSize = isCurrentUser ? 18.0 : 14.0;
                    final radius = isCurrentUser ? 80.0 : 65.0;
                    final widgetSize = isCurrentUser ? 20.0 : 15.0;
                    return PieChartSectionData(
                      badgePositionPercentageOffset: .93,
                      titlePositionPercentageOffset: 0.3,
                      value: tasksCompleted[i].toDouble(),
                      title: tasksCompleted[i].toString(),
                      color: users[i].color,
                      radius: radius,
                      titleStyle: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: users[i].color.computeLuminance() > 0.5 ? Colors.black : Colors.white
                      ),
                      badgeWidget: Container(
                        width: widgetSize * 2,
                        height: widgetSize * 2,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: Colors.black.withOpacity(.5),
                              offset: const Offset(3, 3),
                              blurRadius: 3,
                            ),
                          ],
                        ),
                        child: UserDataHelper.avatarFromUserData(users[i], widgetSize)
                      )
                    );
                  })
                )
              ) : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    AutoSizeText('No one has completed tasks!', maxLines: 1,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25), textAlign: TextAlign.center,),
                    AutoSizeText('Tasks in the archive count to your contributions!', maxLines: 1,
                        style: TextStyle(color: Colors.white), textAlign: TextAlign.center,)
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.1, 0.5, 0.95],
                  colors: [
                    Colors.lightBlue,
                    Colors.blue,
                    Colors.blueAccent
                  ],
                )
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('THE STATS', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
                  Divider(color: Colors.transparent, height: 5),
                  AutoSizeText("Contributions", maxLines: 1,style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),),
                  Divider(color: Colors.transparent, height: 5),
                  Text('See who checks off the most tasks', style: TextStyle(fontSize: 12, color: Colors.white))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DaysCard extends StatelessWidget {
  const DaysCard({Key? key, required this.dayTasks, required this.userDayTasks}) : super(key: key);

  final List<int> dayTasks;
  final List<int> userDayTasks;

  Widget getTitles(double value, TitleMeta meta) {
    const style = TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 14,
      color: Colors.white
    );
    Widget text;
    switch (value.toInt()) {
      case 0:
        text = const Text('Mo', style: style);
        break;
      case 1:
        text = const Text('Tu', style: style);
        break;
      case 2:
        text = const Text('We', style: style);
        break;
      case 3:
        text = const Text('Th', style: style);
        break;
      case 4:
        text = const Text('Fr', style: style);
        break;
      case 5:
        text = const Text('Sa', style: style);
        break;
      case 6:
        text = const Text('Su', style: style);
        break;
      default:
        text = const Text('', style: style);
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 16,
      child: text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.lightBlue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 36, right: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircleAvatar(radius: 4, backgroundColor: Colors.white),
                          VerticalDivider(width: 6),
                          Text('Group', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                        ],
                      ),
                      const VerticalDivider(width: 10,),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          CircleAvatar(radius: 4, backgroundColor: Colors.cyanAccent),
                          VerticalDivider(width: 3),
                          Text('You', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold))
                        ],
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: BarChart(
                      BarChartData(
                          gridData: FlGridData(show: false),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          titlesData: FlTitlesData(
                            show: true,
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: getTitles,
                                reservedSize: 38,
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: false,
                              ),
                            ),
                          ),
                          barTouchData: BarTouchData(
                            enabled: false,
                            touchTooltipData: BarTouchTooltipData(
                              tooltipBgColor: Colors.transparent,
                              tooltipPadding: const EdgeInsets.all(0),
                              tooltipMargin: 8,
                              getTooltipItem: (
                                  BarChartGroupData group,
                                  int groupIndex,
                                  BarChartRodData rod,
                                  int rodIndex,
                                  ) {
                                return BarTooltipItem(
                                  rod.toY.round().toString(),
                                  const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              },
                            ),
                          ),
                          barGroups: List.generate(7, (i) {
                            return BarChartGroupData(
                              x: i,
                              showingTooltipIndicators: [0],
                              barRods: [
                                BarChartRodData(
                                  toY: dayTasks[i].toDouble(),
                                  color: Colors.white,
                                  rodStackItems: [
                                    BarChartRodStackItem(0, userDayTasks[i].toDouble(), Colors.cyanAccent)
                                  ]
                                )
                              ]
                            );
                          })
                      )
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(bottomLeft: Radius.circular(15), bottomRight: Radius.circular(15)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.1, 0.5, 0.95],
                    colors: [
                      Colors.lightBlue,
                      Colors.blue,
                      Colors.blueAccent
                    ],
                  )
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: const [
                    Text('THE STATS', style: TextStyle(fontSize: 15, color: Colors.white, fontWeight: FontWeight.bold)),
                    Divider(color: Colors.transparent, height: 5),
                    AutoSizeText("Your Week", maxLines: 1,style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),),
                    Divider(color: Colors.transparent, height: 5),
                    Text('Visualize your effort over the past week', style: TextStyle(fontSize: 12, color: Colors.white))
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CaughtUpStatusCard extends StatelessWidget {
  const CaughtUpStatusCard({Key? key, required this.tasks}) : super(key: key);

  final List<TaskData> tasks;

  // A helper function to get the icon data based on a task type
  IconData _getIconForTaskType(TaskType tt) {
    switch (tt) {
      case TaskType.garbage:
        return FontAwesomeIcons.trash;
      case TaskType.cleaning:
        return FontAwesomeIcons.soap;
      case TaskType.cooking:
        return FontAwesomeIcons.utensils;
      case TaskType.shopping:
        return FontAwesomeIcons.cartShopping;
      case TaskType.other:
        return FontAwesomeIcons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.blue,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('UP NEXT', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
                        Divider(height: 5, color: Colors.transparent,),
                        AutoSizeText('Closest Deadlines', maxLines: 1, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 10, color: Colors.transparent),
                  const Icon(Icons.check, size: 60, color: Colors.greenAccent),
                ],
              ),
              const Divider(height: 20, color: Colors.transparent,),
              tasks.isNotEmpty ? ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, i) => ListTile(
                      iconColor: Colors.cyanAccent,
                      leading: Icon(_getIconForTaskType(tasks[i].taskType)),
                      textColor: Colors.white,
                      title: Text(tasks[i].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text('${daysOfWeek[tasks[i].due.toLocal().weekday]}, '
                          '${DateFormat('h:mm a').format(tasks[i].due.toLocal())}'),
                      trailing: _getTimeText(DateTime.now().difference(tasks[i].due))
                  ),
                  separatorBuilder: (context, i) => const Divider(height: 5, color: Colors.white),
                  itemCount: tasks.length
              ) : const Center(child: Text('You have no pending tasks.', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)))
            ],

          )
      ),
    );
  }
}


class LateStatusCard extends StatelessWidget {
  const LateStatusCard({Key? key, required this.tasks}) : super(key: key);

  final List<TaskData> tasks;

  // A helper function to get the icon data based on a task type
  IconData _getIconForTaskType(TaskType tt) {
    switch (tt) {
      case TaskType.garbage:
        return FontAwesomeIcons.trash;
      case TaskType.cleaning:
        return FontAwesomeIcons.soap;
      case TaskType.cooking:
        return FontAwesomeIcons.utensils;
      case TaskType.shopping:
        return FontAwesomeIcons.cartShopping;
      case TaskType.other:
        return FontAwesomeIcons.star;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      color: Colors.pink[700],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('ATTENTION', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),),
                        Divider(height: 5, color: Colors.transparent,),
                        AutoSizeText('Overdue Tasks', maxLines: 1, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 30),),
                      ],
                    ),
                  ),
                  const VerticalDivider(width: 10, color: Colors.transparent),
                  IntrinsicWidth(
                    child: Stack(
                      alignment: Alignment.centerRight,
                      children: [
                        const Icon(FontAwesomeIcons.fire, size: 60, color: Colors.deepOrangeAccent),
                        Positioned(
                          right: 0,
                          bottom: 15,
                          child: Card(
                              color: Colors.amber,
                              shape: const CircleBorder(),
                              child: Align(
                                alignment: Alignment.center,
                                child: Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Text('${tasks.length}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25)),
                                ),)
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 20, color: Colors.transparent,),
              ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemBuilder: (context, i) => ListTile(
                      iconColor: Colors.yellow,
                      leading: Icon(_getIconForTaskType(tasks[i].taskType)),
                      textColor: Colors.white,
                      title: Text(tasks[i].name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: Text('${daysOfWeek[tasks[i].due.toLocal().weekday]}, '
                          '${DateFormat('h:mm a').format(tasks[i].due.toLocal())}'),
                      trailing: _getTimeText(DateTime.now().difference(tasks[i].due))
                  ),
                  separatorBuilder: (context, i) => const Divider(height: 5, color: Colors.white),
                  itemCount: tasks.length
              )
            ],

          )
      ),
    );
  }
}

class LocationActivationWidget extends StatelessWidget {
  const LocationActivationWidget({Key? key, required this.locationEnabled, required this.onActivate, required this.onDisable, required this.heroTag}) : super(key: key);

  final bool locationEnabled;
  final Function() onActivate;
  final Function() onDisable;
  final String heroTag;

  @override
  Widget build(BuildContext context) {
    double height = locationEnabled ? 285.0 : 440.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: MediaQuery.of(context).size.height/2 - height/2),
      child: Hero(
          tag: heroTag,
          createRectTween: (begin, end) {
            return CustomRectTween(begin: begin, end: end);
          },
          child: locationEnabled ? LocationInfo(
              bgColor: Colors.green,
              iconBgColor: Colors.green,
              icon: const Icon(Icons.check, color: Colors.lightGreen, size: 80),
              title: 'Activated',
              subtitle: 'You will receive notifications whenever you\'re near a task. Click "Disable" to disable location tracking (you can always activate it again later).',
              confirmText: 'Disable',
              onCancel: () {
                Navigator.of(context).pop();
              },
              onConfirm: onDisable
          ) : LocationInfo(
              bgColor: Colors.blue,
              iconBgColor: Colors.green,
              icon: const Icon(FontAwesomeIcons.earthAmericas, size: 80, color: Colors.blue),
              title: 'Use your location',
              subtitle: 'Confrm! would like to remind you to complete tasks when you are near a task location. To receive alerts, press activate and allow Confrm! to access location data at all times.',
              subtitle2: 'Confrm! only uses location data to provide alerts. It does not store, collect or share your immediate location data. This feature can be deactivated at any time in the account menu.',
              confirmText: 'Activate',
              onCancel: () {
                Navigator.of(context).pop();
              },
              onConfirm: onActivate
          )
      ),
    );
  }
}


class LocationInfo extends StatelessWidget {
  const LocationInfo({Key? key, required this.bgColor, required this.icon, required this.title,
    required this.subtitle, required this.confirmText, required this.onCancel, required this.onConfirm,
    required this.iconBgColor, this.subtitle2}) : super(key: key);

  final Color bgColor;
  final Color iconBgColor;
  final Icon icon;
  final String title;
  final String subtitle;
  final String? subtitle2;
  final String confirmText;
  final Function() onCancel;
  final Function() onConfirm;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: CustomScrollView(
          physics: const NeverScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    mainAxisSize: MainAxisSize.min,
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
                          padding: const EdgeInsets.only(left: 8, right: 8, top: 15),
                          child: Text(subtitle, style: const TextStyle(fontSize: 14), textAlign: TextAlign.left,)
                      ),
                      subtitle2 != null ? Container(
                          padding: const EdgeInsets.only(left: 8, right: 8, top: 25),
                          child: Text(subtitle2!, style: const TextStyle(fontSize: 14), textAlign: TextAlign.left,)
                      ) : const SizedBox.shrink(),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                          onPressed: onCancel,
                          child: const Text('Cancel')
                      ),
                      TextButton(
                          onPressed: onConfirm,
                          child: Text(confirmText)
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        )
    );
  }
}


