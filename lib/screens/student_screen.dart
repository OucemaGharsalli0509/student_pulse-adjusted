import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/student_screen_service.dart';
import '../utils.dart';
import 'form_screen.dart';


class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final StudentScreenService service = StudentScreenService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Feedback Analysis App "),
        centerTitle: true,
        backgroundColor: const Color(0xff2f887d),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 25.0, horizontal: 10.0),
                child: Text(
                  'Student Page',
                  style: SafeGoogleFont(
                    'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 1.5,
                    color: Color(0xff2f887d),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.2,
                child: Image.asset(
                  'assets/etudiant.png',
                  fit: BoxFit.cover,
                ),
              ),
              StreamBuilder<QuerySnapshot>(
                stream: service.getForms(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text('Something went wrong');
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  }

                  final formTitles = snapshot.data!.docs
                      .map((doc) => doc['title'] as String)
                      .toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    itemCount: formTitles.length,
                    itemBuilder: (BuildContext context, int index) {
                      final String title = formTitles[index];
                      return InkWell(
                        borderRadius: BorderRadius.circular(20),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FormScreen(
                                title: title,
                              ),
                            ),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.rate_review, size: 50, color: Color(0xff2f887d)),
                                SizedBox(height: 16),
                                Text(title, style: TextStyle(fontSize: 18, color: Color(0xff2f887d))),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              /*CustomizedButton(
                buttonText: "Create Form",
                buttonColor: const Color(0xff5aa087),
                textColor: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => FormBuilderScreen()),
                  );
                },
              ),*/
            ],
          ),
        ),
      ),
    );
  }
}
