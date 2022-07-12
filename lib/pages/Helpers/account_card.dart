import 'package:auto_size_text/auto_size_text.dart';
import 'package:family_tasks/pages/Helpers/user_data_helper.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../models/family_task_data.dart';
import '../../models/user_data.dart';

class ContributeCard extends StatelessWidget {
  const ContributeCard({Key? key, required this.users, required this.tasksCompleted, required this.curUser}) : super(key: key);

  final List<UserData> users;
  final List<int> tasksCompleted;
  final int curUser;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 175,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('THE STATS', style: TextStyle(fontSize: 15, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                  Divider(color: Colors.transparent, height: 5),
                  AutoSizeText("Contributions", maxLines: 1,style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                  Divider(color: Colors.transparent, height: 5),
                  Text('See who checks off the most tasks', style: TextStyle(fontSize: 12, color: Colors.grey))
                ],
              ),
            ),
            const VerticalDivider(
              width: 12,
              color: Colors.transparent
            ),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 0,
                      centerSpaceRadius: 20,
                      sections: List.generate(users.length, (i) {
                        final isCurrentUser = i == curUser;
                        final fontSize = isCurrentUser ? 18.0 : 14.0;
                        final radius = isCurrentUser ? 50.0 : 40.0;
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
                  ),
                ),
              ),
            ),
          ],
        ),
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('THE STATS', style: TextStyle(fontSize: 15, color: Colors.blueGrey, fontWeight: FontWeight.bold)),
                  Divider(color: Colors.transparent, height: 5),
                  AutoSizeText("Your Week", maxLines: 1,style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),),
                  Divider(color: Colors.transparent, height: 5),
                  Text('Visualize your effort over the past week', style: TextStyle(fontSize: 12, color: Colors.grey))
                ],
              ),
            ),
            const VerticalDivider(
                width: 4,
                color: Colors.transparent
            ),
            SizedBox(
              width: 200,
              height: 200,
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
                            CircleAvatar(radius: 4, backgroundColor: Colors.cyan),
                            VerticalDivider(width: 6),
                            Text('Group', style: TextStyle(color: Colors.grey))
                          ],
                        ),
                        const VerticalDivider(width: 10,),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            CircleAvatar(radius: 4, backgroundColor: Colors.cyanAccent),
                            VerticalDivider(width: 3),
                            Text('You', style: TextStyle(color: Colors.grey))
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
                                      color: Colors.black,
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
                                    color: Colors.cyan,
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
          ],
        ),
      ),
    );
  }
}

class TaskStatusCard extends StatelessWidget {
  const TaskStatusCard({Key? key, required this.task}) : super(key: key);

  final TaskData task;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}


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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
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
                padding: const EdgeInsets.all(5.0),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
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


