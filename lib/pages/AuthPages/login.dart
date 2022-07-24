import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Services/authentication.dart';

class LoginWidget extends StatefulWidget {
  const LoginWidget({Key? key, required this.swap}) : super(key: key);

  final Function() swap;

  @override
  State<LoginWidget> createState() => _LoginWidgetState();
}

class _LoginWidgetState extends State<LoginWidget> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  AuthenticationService auth = AuthenticationService();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue,
              Colors.white,
            ],
          )
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 50, bottom: 10),
            child: Image.asset( // Icon at the top
              'assets/icon/icon_android.png',
              fit: BoxFit.contain,
              height: 150
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Align(alignment: Alignment.centerLeft, child: Text('Welcome', style: TextStyle(fontSize: 40, color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          const Padding(
            padding: EdgeInsets.only(left: 16, bottom: 30),
            child: Align(alignment: Alignment.centerLeft, child: Text('Enter your email address and password.', style: TextStyle(fontSize: 17, color: Colors.white))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email)
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: TextField(
              controller: passwordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock)
              ),
              obscureText: true,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16),
            child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  primary: Colors.blue,
                  minimumSize: const Size.fromHeight(50), // NEW
                ),
                onPressed: () async {
                  SignResults res = await auth.signIn(emailController.text.trim(), passwordController.text.trim());
                  switch (res) {
                    case SignResults.noUser:
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User does not exist')));
                      break;
                    case SignResults.wrongPass:
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Incorrect Password')));
                      break;
                    case SignResults.invalidEmail:
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid Email')));
                      break;
                    case SignResults.fail:
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred signing in')));
                      break;
                    default:
                      break;
                  }
                },
                icon: const Icon(FontAwesomeIcons.rightToBracket),
                label: const Text('Sign in', style: TextStyle(fontSize: 20))
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don't have an account? ", style: TextStyle(fontSize: 16)),
                InkWell(
                  child: const Text('Sign up', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  onTap: widget.swap
                )
              ]
            ),
          )
        ],
      ),
    );
  }
}
