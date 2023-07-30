import 'package:flutter/material.dart';

import 'package:rkt/content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late TextEditingController _email, _password;

class SignUpPage extends StatelessWidget {
  late bool isTeacher;

  SignUpPage({required this.isTeacher});
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        children: <Widget>[
          const SizedBox(
            height: 50,
          ),
          const Row(
            children: [
              BackButton(),
            ],
          ),
          const SizedBox(height: 20),
          EmailTextField(),
          const SizedBox(height: 100),
          PasswordTextField(),
          const SizedBox(height: 150),
          SizedBox(
            height: 100,
            width: 350,
            child: LoginButton(
              isTeacher: isTeacher,
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class EmailTextField extends StatefulWidget {
  @override
  State<EmailTextField> createState() => _EmailTextField();
}

class _EmailTextField extends State<EmailTextField> {
  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
      width: 500,
      child: TextFormField(
        controller: _email,
        decoration: const InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(),
          ),
        ),
      ),
    ));
  }
}

class PasswordTextField extends StatefulWidget {
  @override
  State<PasswordTextField> createState() => _PasswordTextField();
}

class _PasswordTextField extends State<PasswordTextField> {
  @override
  void initState() {
    super.initState();
    _password = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: SizedBox(
      width: 500,
      child: TextFormField(
        controller: _password,
        obscureText: true,
        decoration: const InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(),
          ),
        ),
      ),
    ));
  }
}

class LoginButton extends StatelessWidget {
  late bool isTeacher;
  LoginButton({required this.isTeacher});
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          await signup(context);
        },
        style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.fromLTRB(60, 0, 60, 0)),
        child: const Text(
          "Sign up",
          style: TextStyle(fontSize: 50),
        ));
  }

  Future<void> addSignUpDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                _email.clear();
                _password.clear();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> signup(context) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.auth.signUp(
        email: _email.text,
        password: _password.text,
      );
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => ContentPage(
                    isTeacher: isTeacher,
                  )));
    } on AuthException catch (e) {
      addSignUpDialog(context, e.message);
    }
  }
}
