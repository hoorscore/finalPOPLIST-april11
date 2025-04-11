import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TaskSim extends StatefulWidget {
  @override
  _TaskSimState createState() => _TaskSimState();
}

class _TaskSimState extends State<TaskSim> {
  final _auth = FirebaseAuth.instance;
  User? signedInUser; // استخدم User? بدلاً من late لتجنب الأخطاء

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        setState(() {
          signedInUser = user;
        });
        print(signedInUser!.email);
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("TaskSim"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "مرحبا",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (signedInUser != null) // عرض البريد الإلكتروني إذا كان المستخدم مسجل دخول
              Text(
                "البريد الإلكتروني: ${signedInUser!.email}",
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
          ],
        ),
      ),
    );
  }
}
