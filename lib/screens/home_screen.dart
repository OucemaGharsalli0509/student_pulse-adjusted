import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/firebase_auth_service.dart';
import '../widgets/customized_button.dart';
import '../widgets/customized_textfield.dart';
import 'login_screen.dart';
import 'student_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _idCardController = TextEditingController();
  final TextEditingController _groupController = TextEditingController();
  final String? username = FirebaseAuth.instance.currentUser?.displayName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Feedback Analysis App"),
        centerTitle: true,
        backgroundColor: const Color(0xff2f887d),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            SizedBox(
              height: 64.0,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  color: Color(0xff2f887d),
                ),
                child: Text(
                  "Welcome $username",
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            ListTile(
              hoverColor: const Color(0x665aa087),
              leading: const Icon(
                Icons.settings,
                color: Color(0xff2f887d),
              ),
              title: const Text(
                'Profile setting',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff2f887d),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // Navigate to the view feedback screen
              },
            ),
            ListTile(
              hoverColor: const Color(0x665aa087),
              leading: const Icon(
                Icons.logout,
                color: Color(0xff2f887d),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xff2f887d),
                ),
              ),
              onTap: () async {
                await FirebaseAuthService().logout();
                if (!mounted) return;
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                      return LoginScreen();
                    }));
                // Navigate to the add admin screen
              },
            ),
          ],
        ),
      ),
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
                        child: Image.asset(
                          'assets/quiterphoto .jpg',
                          fit: BoxFit.cover,
                          alignment: Alignment.centerRight,
                        ),
                      ),
                      CustomizedTextfield(
                        myController: _idCardController,
                        hintText: "Your ID card number",
                        isPassword: false,
                      ),
                      CustomizedTextfield(
                        myController: _groupController,
                        hintText: "Your group",
                        isPassword: false,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Image.asset(
                          'assets/iconeetudiant.png',
                          fit: BoxFit.cover,
                          alignment: Alignment.centerRight,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(49.0),
                        child: CustomizedButton(
                          buttonText: "Student",
                          buttonColor: const Color(0x665aa087),
                          textColor: const Color(0xff5aa087),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const StudentScreen(),
                              ),
                            );
                          },
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
    );
  }
}
