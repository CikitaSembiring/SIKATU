import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Sekarang ini tidak akan merah lagi
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sikatu/screens/main_screen.dart';
import 'package:sikatu/screens/splash_screen.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // --- 1. Navigasi ---
  static void _navigateToHome(BuildContext context) {
    if (!context.mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
    );
  }

  // --- 2. Sign Out (Untuk Settings Screen) ---
  static Future<void> signOut(BuildContext context) async {
    try {
      await _auth.signOut();
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      await FacebookAuth.instance.logOut();

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const SplashScreen()),
            (route) => false,
      );
    } catch (e) {
      print("Error signing out: $e");
    }
  }

  // --- 3. Forgot Password (Untuk Login Screen) ---
  static Future<bool> sendPasswordResetEmail({
    required BuildContext context,
    required String email,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Link reset password dikirim ke email.'), backgroundColor: Colors.green),
        );
      }
      return true;
    } on FirebaseAuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Gagal mengirim email.'), backgroundColor: Colors.red),
        );
      }
      return false;
    }
  }

  // --- 4. Update Profile (Untuk Edit Profile Screen) ---
  static Future<bool> updateDisplayName(String newName) async {
    try {
      await _auth.currentUser?.updateDisplayName(newName);
      await _auth.currentUser?.reload();
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<String?> uploadProfileImage(XFile imageFile) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return null;

      String filePath = 'profile_pics/${user.uid}.${imageFile.path.split('.').last}';
      File file = File(imageFile.path);

      UploadTask uploadTask = _storage.ref().child(filePath).putFile(file);
      TaskSnapshot snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  static Future<bool> updateUserData({
    DateTime? dateOfBirth,
    String? country,
    String? username,
    String? email,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null) return false;

      Map<String, dynamic> dataToUpdate = {};
      if (username != null) dataToUpdate['username'] = username;
      if (email != null) dataToUpdate['email'] = email;
      if (dateOfBirth != null) dataToUpdate['dateOfBirth'] = Timestamp.fromDate(dateOfBirth);
      if (country != null) dataToUpdate['country'] = country;

      if (dataToUpdate.isNotEmpty) {
        await _db.collection('users').doc(user.uid).set(
            dataToUpdate,
            SetOptions(merge: true)
        );
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  // --- 5. Sign Up & Login (Untuk Login & Sign Up Screen) ---
  static Future<void> signUpWithEmail({
    required BuildContext context,
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        await updateDisplayName(username);
        await updateUserData(username: username, email: email);

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Akun berhasil dibuat!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Gagal mendaftar'), backgroundColor: Colors.red),
      );
    }
  }

  static Future<void> signInWithEmail({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _navigateToHome(context);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Gagal login'), backgroundColor: Colors.red),
      );
    }
  }

  static Future<void> signInWithGoogle({required BuildContext context}) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser == true) {
        await _db.collection('users').doc(userCredential.user!.uid).set({
          'username': userCredential.user!.displayName,
          'email': userCredential.user!.email,
          'createdAt': Timestamp.now(),
        });
      }
      _navigateToHome(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Google gagal')));
    }
  }

  static Future<void> signInWithFacebook({required BuildContext context}) async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential = FacebookAuthProvider.credential(accessToken.token);

        UserCredential userCredential = await _auth.signInWithCredential(credential);

        if (userCredential.additionalUserInfo?.isNewUser == true) {
          await _db.collection('users').doc(userCredential.user!.uid).set({
            'username': userCredential.user!.displayName,
            'email': userCredential.user!.email,
            'createdAt': Timestamp.now(),
          });
        }
        _navigateToHome(context);
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Login Facebook gagal')));
    }
  }
}