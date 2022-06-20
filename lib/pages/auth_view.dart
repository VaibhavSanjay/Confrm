import 'package:flutter/material.dart';

import 'AuthPages/login.dart';
import 'AuthPages/sign_up.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({Key? key, required this.onLogin}) : super(key: key);

  final Function() onLogin;

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;

  @override
  Widget build(BuildContext context) {
    return _isLogin? LoginWidget(swap: swap, onLogin: widget.onLogin) : SignUpWidget(swap: swap, onLogin: widget.onLogin);
  }

  void swap() => setState(() => _isLogin = !_isLogin);
}
