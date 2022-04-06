import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:background_locator/background_locator.dart';
import 'package:background_locator/location_dto.dart';
import 'package:background_locator/settings/android_settings.dart';
import 'package:background_locator/settings/ios_settings.dart';
import 'package:background_locator/settings/locator_settings.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

import 'location_service.dart';
import 'notifications.dart';

class LocationCallbackHandler {
  static const Distance distance = Distance();

  static Future<void> initPlatformState(bool location) async {
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
    print(data.latitude);
    final double meter = distance(
        LatLng(data.latitude, data.longitude),
        LatLng(37.428864, -122.120046)
    );
    print(meter);
    if (meter < 20) {
      AwesomeNotifications().createNotification(
          content: NotificationContent(
              id: 10,
              channelKey: 'basic_channel',
              title: 'Simple Notification',
              body: 'Simple body'
          )
      );
      LocationServiceRepository myLocationCallbackRepository =
      LocationServiceRepository();
      await myLocationCallbackRepository.callback(data);
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
