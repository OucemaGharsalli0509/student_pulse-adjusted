import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/form_service.dart';


class FormScreen extends StatefulWidget {
  final String title;

  const FormScreen({Key? key, required this.title}) : super(key: key);

  @override
  _FormScreenState createState() => _FormScreenState();
}

class _FormScreenState extends State<FormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final _feedbackController = TextEditingController();
  String? _sentiment;
  bool _loading = false;
  final user = FirebaseAuth.instance.currentUser;
  List<String> _formQuestions = [];


  @override
  void initState() {
    super.initState();
    _loadFormQuestions();
  }



  Future<void> _loadFormQuestions() async {
    final questions = await FormService.loadFormQuestions(widget.title);
    setState(() {
      _formQuestions = questions;
    });
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        _loading = true;
        _sentiment = null;
      });

      final previousSubmission = await FirebaseFirestore.instance
          .collection('forms')
          .where('userId', isEqualTo: user!.uid)
          .where('title', isEqualTo: widget.title)
          .limit(1)
          .get();

      if (previousSubmission.docs.isNotEmpty) {
        setState(() {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You already submitted this feedback'),
            ),
          );
          _loading = false;
        });
      } else {
        await FormService.submitFeedback(
          _feedbackController.text,
              (sentiment) async {
            setState(() {
              _sentiment = sentiment;
              _loading = false;
            });
            String? newSentiment = sentiment;
            bool sentimentCorrected = false;

            while (!sentimentCorrected) {
              final dialogResponse = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Sentiment is $_sentiment. Is it correct?"),
                    actions: <Widget>[
                      TextButton(
                        child: Text("Yes"),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                      TextButton(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                    ],
                  );
                },
              );

              if (dialogResponse != null && dialogResponse == true) {
                sentimentCorrected = true;
              } else {
                final sentimentResponse = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Please select the correct sentiment"),
                      actions: <Widget>[
                        TextButton(
                          child: Text("Satisfied"),
                          onPressed: () {
                            Navigator.pop(context, "Satisfied");
                          },
                        ),
                        TextButton(
                          child: Text("Not satisfied"),
                          onPressed: () {
                            Navigator.pop(context, "Not satisfied");
                          },
                        ),
                      ],
                    );
                  },
                );

                if (sentimentResponse != null) {
                  newSentiment = sentimentResponse;
                  _sentiment = newSentiment;
                }
              }
            }

            final data = {
              'userId': user!.uid,
              'title': widget.title,
              'question': _formQuestions,
              'feedback': _feedbackController.text,
              'sentiment': newSentiment,
              'timestamp': FieldValue.serverTimestamp(),
            };

            // Save feedback and corrected sentiment to CSV file


            await FirebaseFirestore.instance
                .collection('forms')
                .add(data)
                .then((value) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Feedback submitted. Thank you!'),
                ),
              );
            });
            // Save feedback and corrected sentiment to CSV file
            await FormService.saveFeedbackSentimentFr(_feedbackController.text, newSentiment!);
          },
        );
      }
    }
  }


  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              ..._formQuestions.map((question) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children:[
                      SizedBox(height: 16.0),
                      Text('Question :' ,style: TextStyle(fontSize: 20.0,color: Color(0xff5aa087)),
                      ),
                      SizedBox(height: 16.0),
                      Text(
                        question,
                        style: const TextStyle(fontSize: 18.0),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _feedbackController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your feedback';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          hintText: 'Enter your Feedback',
                          labelText: 'Feedback',
                          border: OutlineInputBorder(),
                        ),
                        onSaved: (value){
                          _formData[question] = value;
                        },
                        maxLines: null,
                      ),
                    ],
                  ),
                );
              }).toList(),


              SizedBox(height: 16.0),
              new SizedBox(
                height: 60,
                child:
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xff5aa087),
                    textStyle: TextStyle(fontSize: 20.0),
                  ),
                  onPressed:
                  _loading ? null : _submit,
                  child: _loading
                      ? SpinKitThreeBounce(
                    color: Colors.white,
                    size: 20.0,
                  )
                      : Text('Submit your feedback'),
                ),
              ),
              SizedBox(height: 16.0),
              Text(
                'We predict that you are:',
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.0),
              if (_sentiment == 'Satisfied')
                Text(
                  '$_sentiment',
                  style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.green
                  ),
                  textAlign: TextAlign.center,
                ),
              if (_sentiment == 'Not satisfied')
                Text(
                  '$_sentiment',
                  style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.red
                  ),
                  textAlign: TextAlign.center,
                ),
              SizedBox(height: 20),
              _sentiment == 'Satisfied'
                  ? Image.asset(
                'images/Happy-bee.png',
                width: 200,
                height: 200,
              )
                  : _sentiment == 'Not satisfied'
                  ? Image.asset(
                'images/Angry-bee.png',
                width: 200,
                height: 200,
              )
                  : Container(),
            ],
          ),
        ),
      ),
    );
  }
}