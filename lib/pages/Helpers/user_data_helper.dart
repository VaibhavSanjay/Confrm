import 'package:flutter/material.dart';
import 'dart:math';

import '../../models/user_data.dart';

class UserDataHelper {
  static Widget avatarFromUserData(UserData user, double radius) {
    return CircleAvatar(
        radius: radius,
        backgroundColor: Colors.grey,
        child: Text(
          user.initials,
          style: TextStyle(fontSize: radius, color: Colors.white),
          overflow: TextOverflow.fade, softWrap: false,
        )
    );
  }

  static Widget avatarColumnFromUserData(UserData user, double radius) {
    return Column(
      children: [
        avatarFromUserData(user, radius),
        Divider(
          height: radius * 1/4,
          color: Colors.transparent
        ),
        Text(user.name, style: TextStyle(fontSize: radius * 2/5, color: Colors.white), overflow: TextOverflow.ellipsis)
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