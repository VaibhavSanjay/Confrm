import 'dart:async';

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:background_locator/location_dto.dart';
import 'package:latlong2/latlong.dart';

import 'location_service.dart';

class LocationCallbackHandler {
  static const Distance distance = Distance();

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
}
