import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/firebase_auth_service.dart';
import '../widgets/customized_button.dart';
import '../widgets/customized_textfield.dart';
import 'login_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
  TextEditingController();

  String? selectedDepartment;
  String? selectedGroup;
  List<String> departments = [];
  List<String> groups = [];

  @override
  void initState() {
    super.initState();
    loadDepartments();
  }

  Future<void> loadDepartments() async {
    try {
      final departmentsSnapshot =
      await FirebaseFirestore.instance.collection('departments').get();

      setState(() {
        departments = departmentsSnapshot.docs
            .map((doc) => doc.data()['departmentName'] as String)
            .toList();
      });
    } catch (e) {
      print('Error loading departments: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load departments. Please try again later.'),
        ),
      );
    }
  }

  Future<void> loadGroups(String departmentName) async {
    try {
      final departmentsSnapshot = await FirebaseFirestore.instance
          .collection('departments')
          .where('departmentName', isEqualTo: departmentName)
          .get();

      if (departmentsSnapshot.docs.isNotEmpty) {
        final departmentData = departmentsSnapshot.docs[0].data();
        final groupsList = departmentData['groups'] ?? [];

        setState(() {
          groups = groupsList.cast<String>().toList();
          selectedGroup = null;
        });
      } else {
        print('Department not found.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Department not found. Please try again.'),
          ),
        );
      }
    } catch (e) {
      print('Error loading groups: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load groups. Please try again later.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0),
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: Color(0xff5aa087), width: 1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_sharp,
                              color: Color(0xff5aa087)),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text("Sign Up",
                          style: TextStyle(
                            color: Color(0xff5aa087),
                            fontSize: 60,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                    CustomizedTextfield(
                      myController: _usernameController,
                      hintText: "Full name",
                      isPassword: false,
                    ),
                    CustomizedTextfield(
                      myController: _emailController,
                      hintText: "Email",
                      isPassword: false,
                    ),
                    CustomizedTextfield(
                      myController: _passwordController,
                      hintText: "Password",
                      isPassword: true,
                    ),
                    CustomizedTextfield(
                      myController: _confirmPasswordController,
                      hintText: "Confirm Password",
                      isPassword: true,
                    ),
                    FractionallySizedBox(
                      widthFactor: 0.8,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Department',
                          hintText: 'Select a department',
                          border: OutlineInputBorder(),
                        ),
                        value: selectedDepartment,
                        onChanged: (value) {
                          setState(() {
                            selectedDepartment = value;
                            selectedGroup = null;
                            loadGroups(value!);
                          });
                        },
                        items: departments.map<DropdownMenuItem<String>>(
                              (String department) {
                            return DropdownMenuItem<String>(
                              value: department,
                              child: Text(department),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (selectedDepartment != null)
                      FractionallySizedBox(
                        widthFactor: 0.8,
                        child: DropdownButtonFormField<String>(
                          decoration: InputDecoration(
                            labelText: 'Group',
                            hintText: 'Select a group',
                            border: OutlineInputBorder(),
                          ),
                          value: selectedGroup,
                          onChanged: (value) {
                            setState(() {
                              selectedGroup = value;
                            });
                          },
                          items: groups.map<DropdownMenuItem<String>>(
                                (String group) {
                              return DropdownMenuItem<String>(
                                value: group,
                                child: Text(group),
                              );
                            },
                          ).toList(),
                        ),
                      ),
                    const SizedBox(height: 16),
                    CustomizedButton(
                      buttonText: "Register",
                      buttonColor: Color(0xff5aa087),
                      textColor: Colors.white,
                      onPressed: () async {
                        try {
                          await FirebaseAuthService().signUp(
                            _usernameController.text.trim(),
                            _emailController.text.trim(),
                            _passwordController.text.trim(),
                            selectedDepartment!,
                            selectedGroup!,
                          );

                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text(
                                "Your registration has been successfully completed. Now please login.",
                              ),
                              actions: [
                                ElevatedButton(
                                  child: const Text("Login Now",
                                      style: TextStyle(
                                          backgroundColor:
                                          Color(0xff5aa087))),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                        const LoginScreen(),
                                      ),
                                    );
                                  },
                                )
                              ],
                            ),
                          );
                        } on FirebaseAuthException catch (e) {
                          String errorMessage = '';
                          if (e.code == 'email-already-in-use') {
                            errorMessage =
                            'This email address is already registered. Please use a different email address.';
                          } else {
                            errorMessage = e.message ??
                                'An error occurred. Please try again later.';
                          }

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(errorMessage)),
                          );
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(48, 8, 8, 8.0),
                      child: Row(
                        children: [
                          const Flexible(
                            child: Text("Already have an account?",
                                style: TextStyle(
                                  color: Color(0xff1E232C),
                                  fontSize: 18,
                                )),
                          ),
                          Flexible(
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                );
                              },
                              child: const Text("  Login Now",
                                  style: TextStyle(
                                    color: Color(0xff5aa087),
                                    fontSize: 18,
                                  )),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
