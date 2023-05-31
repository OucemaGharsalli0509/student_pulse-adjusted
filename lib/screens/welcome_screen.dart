import 'package:flutter/material.dart';

import '../utils.dart';
import '../widgets/customized_button.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Welcome to our App'),
          centerTitle: true,
          backgroundColor: const Color(0xff2f887d),
        ),
        body: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Student Feedback Analysis App',
                style: SafeGoogleFont(
                  'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: Color(0xff2f887d),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.0),
              Image.asset(
                'assets/2pagephoto2 1.jpg',
                fit: BoxFit.cover,
                height: MediaQuery.of(context).size.height * 0.4,
              ),
              SizedBox(height: 16.0),
              Text(
                'Student Pulse',
                style: SafeGoogleFont(
                  'Poppins',
                  fontSize: 29,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: Color(0xff2f887d),
                ),
              ),
              SizedBox(height: 32.0),
              CustomizedButton(
                buttonText: "Get started",
                buttonColor: const Color(0xff5aa087),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
