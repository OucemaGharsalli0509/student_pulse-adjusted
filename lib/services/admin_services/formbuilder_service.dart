import 'package:cloud_firestore/cloud_firestore.dart';

class FormBuilderService {
  static Future<void> addForm(String title, List<String> questions) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('form_questions')
        .where('title', isEqualTo: title)
        .get();
    if (snapshot.docs.isNotEmpty) {
      // Show an error message if a document with the same title already exists
      throw Exception('A form with the same title already exists.');
    } else {
      // Add the form to the database if the title is unique
      await FirebaseFirestore.instance
          .collection('form_questions')
          .add({'title': title, 'questions': questions});
    }
  }
}
