import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../Services/authentication.dart';

class SignUpWidget extends StatefulWidget {
  const SignUpWidget({Key? key, required this.swap, required this.onSignUp}) : super(key: key);

  final Function() swap;
  final Function() onSignUp;

  @override
  State<SignUpWidget> createState() => _SignUpWidgetState();
}

class _SignUpWidgetState extends State<SignUpWidget> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  AuthenticationService auth = AuthenticationService();

  @override
  void dispose() {
    nameController.dispose();
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
            padding: EdgeInsets.only(top: 0.05 * MediaQuery.of(context).size.height, bottom: 10),
            child: Image.asset( // Icon at the top
                'assets/icon/icon_android.png',
                fit: BoxFit.contain,
                height: 0.2 * MediaQuery.of(context).size.height
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 8),
            child: Align(alignment: Alignment.centerLeft, child: Text('New Account', style: TextStyle(fontSize: 0.05 * MediaQuery.of(context).size.height, color: Colors.white, fontWeight: FontWeight.bold))),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, bottom: 20),
            child: Align(alignment: Alignment.centerLeft, child: Text('Create an account to get started.', style: TextStyle(fontSize: 0.03 * MediaQuery.of(context).size.height, color: Colors.white))),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
            child: Form(
              key: _formKey,
              child: TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Name/Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person)
                ),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
              ),
            ),
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
                  backgroundColor: Colors.blue,
                  minimumSize: const Size.fromHeight(50), // NEW
                ),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    SignResults res = await auth.signUp(nameController.text.trim(), emailController.text.trim(), passwordController.text.trim());

                    if (!mounted) return;
                    switch (res) {
                      case SignResults.emailInUse:
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An account with this email already exists')));
                        break;
                      case SignResults.weakPass:
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password too weak')));
                        break;
                      case SignResults.invalidEmail:
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invalid email')));
                        break;
                      case SignResults.fail:
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('An error occurred signing up')));
                        break;
                      case SignResults.success:
                        widget.onSignUp();
                        break;
                      default:
                        break;
                    }
                  }
                },
                icon: const Icon(FontAwesomeIcons.rightToBracket),
                label: const Text('Sign up', style: TextStyle(fontSize: 20))
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Already have an account? ", style: TextStyle(fontSize: 0.025 * MediaQuery.of(context).size.height)),
                  InkWell(
                      onTap: widget.swap,
                      child: Text('Sign in', style: TextStyle(fontSize: 0.025 * MediaQuery.of(context).size.height, fontWeight: FontWeight.bold))
                  )
                ]
            ),
          )
        ],
      ),
    );
  }
}
