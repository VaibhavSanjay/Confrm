import 'package:flutter/material.dart';
import 'dart:math';

import '../../models/user_data.dart';

class UserDataHelper {
  static Color getRandomColor() {
    return Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }

  static Widget avatarFromUserData(UserData user, double radius) {
    return CircleAvatar(
        radius: radius,
        backgroundColor: user.color,
        child: Text(
          user.initials,
          style: TextStyle(fontSize: radius, color: user.color.computeLuminance() > 0.5 ? Colors.black : Colors.white),
          overflow: TextOverflow.fade, softWrap: false,
        )
    );
  }

  static Widget avatarColumnFromUserData(UserData user, double radius, Color textColor) {
    return Column(
      children: [
        avatarFromUserData(user, radius),
        Divider(
          height: radius * 1/4,
          color: Colors.transparent
        ),
        Text(user.name, style: TextStyle(fontSize: radius * 2/5, color: textColor), overflow: TextOverflow.ellipsis)
      ],
    );
  }

  static Widget avatarStack(List<UserData> users, double radius, Color emptyColor, Widget emptyWidget) {
    int length = min(3, users.length);
    return Stack(
      alignment: Alignment.centerRight,
      children: length > 0 ? List.generate(
          length,
              (index) => Positioned(
            top: 5,
            right: (length - index - 1) * (2/3 * radius) + 5,
            child: avatarFromUserData(users[index], radius)
          )
      ) : [
        Positioned(
          top: 5,
          right: 5,
          child: CircleAvatar(
              radius: radius,
              backgroundColor: emptyColor,
              child: emptyWidget
          ),
        )
      ],
    );
  }
}