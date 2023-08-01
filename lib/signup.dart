import 'package:flutter/material.dart';
import 'package:rkt/content.dart';
import 'package:rkt/login_user.dart';
import 'package:rkt/main.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Declare TextEditingController variables
late TextEditingController _email, _password, _pin;

class SignUpPage extends StatelessWidget {
  late bool isTeacher;

  SignUpPage({required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image:  DecorationImage(
            image: AssetImage("../../../lib/mainBackground2.jpeg"),
            fit: BoxFit.cover,
            opacity: 200
            )
        ),
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(height: 50),
            const Row(
              children: [
                BackButton(),
              ],
            ),
            const SizedBox(height: 20),
            EmailTextField(),
            const SizedBox(height: 20),
            PasswordTextField(),
            const SizedBox(height: 30),
            if (teacherSignup) ...[
              PinTextField(),
            ],
            const SizedBox(height: 30),
            LoginButton(isTeacher: isTeacher),
            const SizedBox(height: 30),
          ],
        ),
      ),
    ));
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: _email,
        decoration: InputDecoration(
          labelText: 'Email',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: _password,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Password',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}

class LoginButton extends StatelessWidget {
  late bool isTeacher;

  LoginButton({required this.isTeacher});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () async {
        
        if (teacherSignup && _pin.text == "54321") {
          await signUserUp(context);
        } else if (teacherSignup) {
          wrongPin(context);
          }
          else if(_password.text.length<6){
          addSignUpDialog(context, "password must be greater than 6 digits");
        }
        else if(!_email.text.contains("@")||!_email.text.contains(".com")){
          addSignUpDialog(context, "invalid email");
        }
        else{
          await signUserUp(context);
        }

      },
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.fromLTRB(60, 0, 60, 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: const Text("Sign up"),
    );
  }
  Future<void> addSignUpDialog(BuildContext context,String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title:   message==""?const Text('Please check your email for a confirmation email'):const Text("error signing up"),
          content:  SingleChildScrollView(
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
                if(message==""){
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                }
                else{
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> signUserUp(context) async {
    String response;
      if(isTeacher){
        response = await signUp(_email.text, _password.text,"teacher" );
      }
      else{
         response = await signUp(_email.text, _password.text,"parent" );
      }

      if(response.contains("error")){
        addSignUpDialog(context, "Some error has occured");
      }
      else{
        addSignUpDialog(context, "");
      }
  }
}

class PinTextField extends StatefulWidget {
  @override
  State<PinTextField> createState() => _PinTextField();
}

class _PinTextField extends State<PinTextField> {
  @override
  void initState() {
    super.initState();
    _pin = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextFormField(
        controller: _pin,
        obscureText: true,
        decoration: InputDecoration(
          labelText: 'Pin',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        ),
      ),
    );
  }
}

Future<void> wrongPin(
  BuildContext context,
) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Alert'),
        content: const SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('This is the incorrect pin'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('Ok'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
