import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      //Evitar que se quite el esapacio del nudge
      body: SafeArea(
        child:Column(
          children: [
            Expanded(
              child: RiveAnimation.asset('animated_login_bear.riv'))
          ],
        ))

    );
  }
}