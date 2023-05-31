import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firebase_auth_service.dart';
import '../widgets/customized_button.dart';
import '../widgets/customized_textfield.dart';
import 'admin_screens/admin_home_screen.dart';
import 'forgot_passwor.dart';
import 'home_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Color(0xff5aa087), width: 1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_back_ios_sharp,
                                color: Color(0xff5aa087),
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              color: Color(0xff5aa087),
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: Image.asset(
                            'assets/login_img.jpg',
                            fit: BoxFit.cover,
                            scale: 2,
                            alignment: Alignment.centerRight,
                          ),
                        ),
                        CustomizedTextfield(
                          myController: _emailController,
                          hintText: "Enter your Email",
                          isPassword: false,
                        ),
                        CustomizedTextfield(
                          myController: _passwordController,
                          hintText: "Enter your Password",
                          isPassword: true,
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                    const ForgotPassword(),
                                  ),
                                );
                              },
                              child: const Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  color: Color(0xff5aa087),
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                        ),
                        CustomizedButton(
                          buttonText: "Login",
                          buttonColor: Color(0xff5aa087),
                          textColor: Colors.white,
                          onPressed: () async {
                            try {
                              bool isAdmin = await FirebaseAuthService().login(
                                _emailController.text.trim(),
                                _passwordController.text.trim(),
                              );
                              if (FirebaseAuth.instance.currentUser !=
                                  null) {
                                if (!mounted) return;

                                if (isAdmin) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                      const AdminHomeScreen(),
                                    ),
                                  );
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const HomeScreen(),
                                    ),
                                  );
                                }
                              }
                            } on FirebaseException catch (e) {
                              debugPrint("error is ${e.message}");

                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text(
                                    " Invalid Username or password. Please register again or make sure that username and password are correct",
                                  ),
                                  actions: [
                                    ElevatedButton(
                                      child: const Text("Register Now"),
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                            const SignUpScreen(),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(48, 8, 8, 8.0),
                          child: Row(
                            // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text(
                                "Don't have an account?",
                                style: TextStyle(
                                  color: Color(0xff1E232C),
                                  fontSize: 18,
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const SignUpScreen(),
                                    ),
                                  );
                                },
                                child: const Text(
                                  " Sign Up now ",
                                  style: TextStyle(
                                    color: Color(0xff5aa087),
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Add additional widgets as needed
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
