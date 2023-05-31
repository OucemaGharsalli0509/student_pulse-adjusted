import 'package:cloud_firestore/cloud_firestore.dart';

class StudentScreenService {
  final CollectionReference formsCollection =
  FirebaseFirestore.instance.collection('form_questions');

  Stream<QuerySnapshot> getForms() {
    return formsCollection.snapshots();
  }
}
