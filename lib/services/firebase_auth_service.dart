

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class FirebaseAuthService {
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future signUp(String displayName, String email, String password,String depatment,String group) async {
    // Check if user already exists in Firestore
    QuerySnapshot snapshot = await firestore
        .collection('users')
        .where('email', isEqualTo: email)
        .get();
    if (snapshot.docs.isNotEmpty) {
      throw FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'The email address is already in use by another account.');
    }

    // Create user in Firebase Authentication
    UserCredential authResult = await auth.createUserWithEmailAndPassword(
        email: email, password: password);

    // Update user's display name
    User? user = authResult.user;
    if (user != null) {
      await user.updateDisplayName(displayName);
    }

    // Save user in Firestore
    await firestore.collection('users').doc(user!.uid).set({
      'userId': user.uid ,
      'name': displayName,
      'email': email,
      'department':depatment,
      'group': group,
      'role': 'student',
    });
  }

  Future<bool> login(String email, String password) async {
    await auth.signInWithEmailAndPassword(email: email, password: password);

    // Retrieve user document from Firestore
    DocumentSnapshot userDoc = await firestore.collection('users').doc(auth.currentUser!.uid).get();

    // Check user role
    if (userDoc.exists && userDoc.get('role') == 'admin') {
      return true;
    } else {
      return false;
    }
  }
  Future<void> logout() async {
    await auth.signOut();
  }
}
