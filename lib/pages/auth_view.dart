import 'package:flutter/material.dart';

import 'AuthPages/login.dart';
import 'AuthPages/sign_up.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key}) : super(key: key);

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _isLogin? LoginWidget(swap: swap) : SignUpWidget(swap: swap)
    );
  }

  void swap() => setState(() => _isLogin = !_isLogin);
}
