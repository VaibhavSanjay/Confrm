import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:family_tasks/models/family_task_data.dart';
import 'package:flutter/material.dart';

class Notifications {
  static void initializeNotifications() {
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
              channelGroupKey: 'basic_channel_group',
              channelGroupName: 'Basic group')
        ],
        debug: true
    );
  }

  static void sendLocationNotification(TaskData td) {
    AwesomeNotifications().createNotification(
        content: NotificationContent(
            id: 10,
            channelKey: 'basic_channel',
            title: td.name,
            body: 'Remember to complete this task!'
        )
    );
  }

  static Future<bool> requestNotifications() async {
    var notifs = AwesomeNotifications();
    if (!(await notifs.isNotificationAllowed())) {
      await notifs.requestPermissionToSendNotifications();
    }
    return notifs.isNotificationAllowed();
  }

}