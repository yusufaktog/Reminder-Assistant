import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> signIn(String email, String password) async {
    var user = await _auth.signInWithEmailAndPassword(email: email, password: password);
    await SharedPreferences.getInstance().then((value) => value.setString("uid", _auth.currentUser!.uid)).catchError((b) {});
    return user.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await SharedPreferences.getInstance().then((value) => value.remove("uid"));
  }
}
