import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:background_locator_2/background_locator.dart';
import 'package:background_locator_2/location_dto.dart';
import 'package:background_locator_2/settings/android_settings.dart';
import 'package:background_locator_2/settings/ios_settings.dart';
import 'package:background_locator_2/settings/locator_settings.dart';
import 'package:family_tasks/Services/authentication.dart';
import 'package:family_tasks/Services/database.dart';
import 'package:family_tasks/models/family_task_data.dart';
import 'package:family_tasks/pages/Helpers/constants.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import 'notifications.dart';

import 'package:firebase_core/firebase_core.dart';

enum LocationStart {
  success,
  notificationFail,
  locationWhenInUseFail,
  locationAlwaysFail
}

class LocationCallbackHandler {
  static const Distance distance = Distance();

  static Future<void> initPlatformState(bool location) async {
    debugPrint('Initializing...');
    await BackgroundLocator.initialize();
    debugPrint('Initialization done');
    debugPrint('Running');
    if (location && !await BackgroundLocator.isRegisterLocationUpdate()) {
      debugPrint('Reregister background locator');
      onStart();
    }
  }

  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    debugPrint('init locator');
  }

  static Future<void> disposeCallback() async {
    debugPrint('dispose locator');
  }

  static Future<void> callback(LocationDto data) async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();

    DatabaseService ds = DatabaseService((await DatabaseService('').getUser()).famID);
    AuthenticationService auth = AuthenticationService();
    FamilyTaskData ftd = await ds.getSingleSnapshot();
    List<TaskData> taskData = ftd.tasks;

    print(data.latitude);

    for (int i = 0; i < taskData.length; i++) {
      if (taskData[i].coords.isNotEmpty) {
        double meter = distance(
            LatLng(data.latitude, data.longitude),
            LatLng(taskData[i].coords[0], taskData[i].coords[1])
        );

        // (taskData[i].lastRem.add(const Duration(hours: 1)).isBefore(DateTime.now()))
        if (meter < alertDistance && !taskData[i].reminded.contains(auth.id!)) {
          taskData[i].lastRem = DateTime.now();
          taskData[i].reminded.add(auth.id!);
          ds.updateTaskData(taskData);

          AwesomeNotifications().createNotification(
              content: NotificationContent(
                  id: 10,
                  channelKey: 'basic_channel',
                  title: 'Reminder to complete "${taskData[i].name}"',
                  body: 'You have arrived at ${taskData[i].location}, so remember to finish your task!',
                  wakeUpScreen: true
              )
          );

        }
      }
    }
  }

  static Future<void> notificationCallback() async {
    debugPrint('***notificationCallback');
  }

  static Future<LocationStart> onStart() async {
    debugPrint('Locator Starting.');
    if (await Notifications.requestNotifications()) {
      Future.delayed(const Duration(seconds: 1));
      LocationStart status = await checkLocationPermission();
      if (status == LocationStart.success) {
        await startLocator();
      }
      return status;
    } else {
      return LocationStart.notificationFail;
    }
  }

  static Future<LocationStart> checkLocationPermission() async {
    debugPrint('Requesting Location Permission.');
    if (await Permission.locationWhenInUse.request().isGranted) {
      return await Permission.locationAlways
          .request()
          .isGranted ? LocationStart.success : LocationStart.locationAlwaysFail;
    } else {
      return LocationStart.locationWhenInUseFail;
    }
  }

  static startLocator() async {
    BackgroundLocator.registerLocationUpdate(callback,
        initCallback: initCallback,
        disposeCallback: disposeCallback,
        iosSettings: const IOSSettings(
            accuracy: LocationAccuracy.NAVIGATION, distanceFilter: filterDistance),
        autoStop: false,
        androidSettings: const AndroidSettings(
            accuracy: LocationAccuracy.NAVIGATION,
            interval: 15,
            distanceFilter: filterDistance,
            client: LocationClient.google,
            androidNotificationSettings: AndroidNotificationSettings(
                notificationChannelName: 'Background Location Notifications',
                notificationTitle: 'Background Location Notifications',
                notificationMsg: 'You will be notified when you are close to a task location.',
                notificationBigMsg:
                'You have activated the location settings option. When you are close to the location of a task, the app will notify you even'
                    'when the app is closed. You can turn this feature off at any time in the Confrm! app or in your settings.',
                notificationIconColor: Colors.blue,
                notificationTapCallback:
                notificationCallback)
        )
    );
  }

  static Future<void> onStop() async {
    BackgroundLocator.unRegisterLocationUpdate();
  }
}
