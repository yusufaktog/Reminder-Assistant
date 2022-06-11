import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:reminder_app/model/person.dart';

class PersonService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> createPerson(Person person, String password) async {
    await _auth.createUserWithEmailAndPassword(email: person.email, password: password).then((value) async => await _firestore
        .collection("People")
        .doc(_auth.currentUser!.uid)
        .set({'id': _auth.currentUser!.uid, 'name': person.name, 'email': person.email}));
  }
}
