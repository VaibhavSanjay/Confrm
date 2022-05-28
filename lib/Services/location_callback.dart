import 'dart:async';
import 'dart:io';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_tasks/Services/database.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_android/shared_preferences_android.dart';
import 'package:shared_preferences_ios/shared_preferences_ios.dart';

import 'location_service.dart';
import 'notifications.dart';

import 'package:firebase_core/firebase_core.dart';

class LocationCallbackHandler {
  static const Distance distance = Distance();

  static Future<void> initPlatformState(bool location, String? famID) async {
    print('Initializing...');
    await BackgroundLocator.initialize();
    print('Initialization done');
    print('Running');
    print(await BackgroundLocator.isRegisterLocationUpdate());
    print(await BackgroundLocator.isServiceRunning());
    if (location && !await BackgroundLocator.isRegisterLocationUpdate()) {
      print('Reregister background locator');
      startLocator();
    }
  }

  static Future<void> initCallback(Map<dynamic, dynamic> params) async {
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    await myLocationCallbackRepository.init(params);
  }

  static Future<void> disposeCallback() async {
    LocationServiceRepository myLocationCallbackRepository =
    LocationServiceRepository();
    await myLocationCallbackRepository.dispose();
  }

  static Future<void> callback(LocationDto data) async {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isAndroid) SharedPreferencesAndroid.registerWith();
    if (Platform.isIOS) SharedPreferencesIOS.registerWith();
    await Firebase.initializeApp();
    SharedPreferences prefs = await SharedPreferences.getInstance();

    DatabaseService ds = DatabaseService(prefs.getString('famID'));
    DocumentSnapshot doc = await ds.getSingleSnapshot();
    Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;

    for (int i = 0; i < docData['data'].length; i++) {
      double meter = distance(
          LatLng(data.latitude, data.longitude),
          LatLng(docData['data'][i]['coords'][0].toDouble(), docData['data'][i]['coords'][1].toDouble())
      );

      if (meter < 20) {
        AwesomeNotifications().createNotification(
            content: NotificationContent(
                id: 10,
                channelKey: 'basic_channel',
                title: 'Task: ${docData['data'][i]['name']}',
                body: 'You have arrived at ${docData['data'][i]['location']}, so remember to finish your task!'
            )
        );
        LocationServiceRepository myLocationCallbackRepository =
        LocationServiceRepository();
        await myLocationCallbackRepository.callback(data);
      }
    }
  }

  static Future<void> notificationCallback() async {
    print('***notificationCallback');
  }

  static Future<bool> onStart() async {
    if (await Notifications.requestNotifications() && await checkLocationPermission()) {
      await startLocator();
      return true;
    } else {
      // show error
      return false;
    }
  }

  static Future<bool> checkLocationPermission() async {
    return await Permission.locationAlways.request().isGranted;
  }

  static Future<void> startLocator() async{
    Map<String, dynamic> data = {'countInit': 1};
    return await BackgroundLocator.registerLocationUpdate(callback,
        initCallback: initCallback,
        initDataCallback: data,
        disposeCallback: disposeCallback,
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
                notificationCallback)
        )
    );
  }

  static Future<void> onStop() async {
    BackgroundLocator.unRegisterLocationUpdate();
  }
}
