import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:student_pulse/screens/admin_screens/question_screens/manage_form_question_screen.dart';
import 'package:student_pulse/screens/login_screen.dart';
import '../../services/firebase_auth_service.dart';
import 'manage_accounts_screen.dart';
import 'stats_screens/stats_screen.dart';

class AdminHomeScreen extends StatefulWidget {
  const AdminHomeScreen({Key? key}) : super(key: key);

  @override
  State<AdminHomeScreen> createState() => _AdminHomeScreenState();
}

class _AdminHomeScreenState extends State<AdminHomeScreen> {
  final username = FirebaseAuth.instance.currentUser?.displayName;

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
                Navigator.push(context, MaterialPageRoute(builder: (context) {
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StatsScreen()),
                      );
                    },
                    child: buildCard(
                      icon: Icons.query_stats,
                      color: const Color(0xff2f887d),
                      text: 'View stats',
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageAccountsScreen(),
                        ),
                      );
                    },
                    child: buildCard(
                      icon: Icons.manage_accounts_outlined,
                      color: const Color(0xff2f887d),
                      text: 'Manage accounts',
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageFormQuestionsScreen(),
                        ),
                      );
                    },
                    child: buildCard(
                      icon: Icons.question_answer_outlined,
                      color: const Color(0xff2f887d),
                      text: 'Manage form questions',
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      await FirebaseAuthService().logout();
                      if (!mounted) return;
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return LoginScreen();
                      }));
                      // Navigate to the add admin screen
                    },
                    child: buildCard(
                      icon: Icons.logout,
                      color: Colors.deepOrange,
                      text: 'Logout',
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildCard({required IconData icon, required Color color, required String text}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: color),
            const SizedBox(height: 16),
            Text(
              text,
              style: TextStyle(fontSize: 18, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
