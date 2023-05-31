import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';

class FormService {
  static Future<List<String>> loadFormQuestions(String title) async {
    try {
      // Retrieve the document snapshot for the form with the given title
      final snapshot = await FirebaseFirestore.instance
          .collection('form_questions')
          .where('title', isEqualTo: title)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        // Extract the questions from the form document
        final questions = snapshot.docs.first.data()['questions'];
        return List<String>.from(questions);
      }
    } catch (e) {
      print('Error loading form questions: $e');
    }
    return [];
  }

  static Future<void> submitFeedback(
       String feedback, Function(String?) onSentimentUpdated) async {
    try {
      // Analyze the sentiment of the feedback using an API
      final response = await http.post(
        Uri.parse('http://localhost:8000/predict_sentiment'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'text': feedback}),
      );
      final sentiment = jsonDecode(response.body);

      // Save the form data and sentiment in Firebase

      onSentimentUpdated(sentiment);
    } catch (e) {
      print('Error submitting feedback: $e');
    }
  }
  static Future<void> saveFeedbackSentimentFr(
      String feedback, String sentiment) async {
    try {
      await http.post(
          Uri.parse('http://localhost:8000/save_feedback_sentiment_fr'),
          headers:{'Content-Type': 'application/json'},
          body: jsonEncode({
            'text': feedback,
            'sentiment': sentiment,
          }));
    }catch(e){

    print('error : $e');
    }

    }
  }
