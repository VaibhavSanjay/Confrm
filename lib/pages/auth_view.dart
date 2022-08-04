import 'package:flutter/material.dart';

import 'AuthPages/login.dart';
import 'AuthPages/sign_up.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key, required this.onPress}) : super(key: key);

  final Function() onPress;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: _isLogin? LoginWidget(swap: swap, onLogin: widget.onPress) :
      SignUpWidget(swap: swap, onSignUp: widget.onPress)
    );
  }

  void swap() => setState(() => _isLogin = !_isLogin);
}
