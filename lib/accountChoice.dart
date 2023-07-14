import 'package:flutter/material.dart';

import 'package:rkt/signup.dart';

class AccountChoice extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 50,
            ),
            const Row(
              children: [
                BackButton(),
              ],
            ),
            const SizedBox(
              height: 200,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpPage(isTeacher: true)));
                  },
                  child: const Text(
                    "Sign Up as a teacher",
                    style: TextStyle(fontSize: 50, color: Colors.white),
                  )),
            ),
            const SizedBox(
              height: 50,
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                SignUpPage(isTeacher: false)));
                  },
                  child: const Text("Sign Up as a parent",
                      style: TextStyle(fontSize: 50, color: Colors.white))),
            ),
          ],
        ),
      ),
    );
  }
}
