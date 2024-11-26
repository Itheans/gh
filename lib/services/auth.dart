import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  getCurrentUser() async {
    return await _auth.currentUser;
  }

  Future SignOut() async {
    await FirebaseAuth.instance.signOut();
  }

  signInWithGoogle(BuildContext context) async {
    final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    final GoogleSignInAccount? googleSignInAccount =
        await googleSignIn.signIn();
    final GoogleSignInAuthentication? googleSignInAuthentication =
        await googleSignInAccount?.authentication;

    final AuthCredential credential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication?.idToken,
      accessToken: googleSignInAuthentication?.accessToken,
    );

    UserCredential result = await firebaseAuth.signInWithCredential(credential);
    User? userdetails = result.user;
    if (result != null) {
      Map<String, dynamic> userInfoMap = {
        "email": userdetails!.email,
        "username": userdetails.displayName,
        "imgUrl": userdetails.photoURL,
        "id": userdetails.uid,
      };
      await DatabaseMethods()
          .addUser(userdetails.uid, userInfoMap)
          .then((value) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => BottomNav()));
      });
    }
  }
}

class DatabaseMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(String uid, Map<String, dynamic> userInfo) async {
    try {
      await _firestore.collection('users').doc(uid).set(userInfo);
    } catch (e) {
      print("Error adding user: $e");
    }
  }
}

class BottomNav extends StatefulWidget {
  @override
  _BottomNavState createState() => _BottomNavState();
}

class _BottomNavState extends State<BottomNav> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Bottom Navigation")),
      body: Center(
        child: Text("Selected Index: $_selectedIndex"),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign Up')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            AuthMethods().signInWithGoogle(context);
          },
          child: Text('Sign Up with Google'),
        ),
      ),
    );
  }
}
