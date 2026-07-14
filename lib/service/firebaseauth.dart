import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount googleUser = await _googleSignIn.authenticate();

      final GoogleSignInAuthentication googleAuth = googleUser.authentication;

      // ponytail: only idToken available in google_sign_in 7.x accessToken is separate
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      return await _auth.signInWithCredential(credential);
    } catch (e) {
      print('Google Sign-In Error: $e');
      return null;
    }
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  User? get currentUser => _auth.currentUser;

  /// Saves a completed ride's statistics to the cloud under the user's profile.
  Future<void> saveRideStats({
    required double maxSpeed,
    required double averageSpeed,
    required double distance,
  }) async {
    // Firestore removed for now
  }

  /// Streams the cumulative lifetime statistics for the current user.
  Stream<Map<String, double>> getLifetimeStats() {
    return Stream.value({'maxSpeed': 0.0, 'averageSpeed': 0.0, 'distance': 0.0});
  }
}
