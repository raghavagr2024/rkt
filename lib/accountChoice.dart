import 'package:flutter/material.dart';
import 'package:rkt/content.dart';
import 'package:rkt/login_user.dart';
import 'package:rkt/signUpTeacher.dart';
import 'package:rkt/signup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AccountChoice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 200,
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SignUpTeacherPage()));
                },
                child: const Text(
                  "Sign Up as a teacher",
                  style: TextStyle(fontSize: 30),
                )),
            const SizedBox(
              height: 50,
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUpPage()));
                },
                child: const Text("Sign Up as a parent",
                    style: TextStyle(fontSize: 30))),
          ],
        ),
      ),
    );
  }
}
