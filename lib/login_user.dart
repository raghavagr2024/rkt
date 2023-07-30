



import 'package:flutter/material.dart';
import 'package:rkt/accountChoice.dart';

import 'package:rkt/content.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'main.dart';




late TextEditingController _email, _password;
class LoginPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      body: Container (
        decoration: const BoxDecoration(
          image:  DecorationImage(
            image: AssetImage("../../../lib/mainBackground2.jpeg"),
            fit: BoxFit.cover,
            opacity: 200
            )
        ),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 50,),
          const Row(
            children: [
              BackButton(),
            ],
          ),
          const SizedBox(height: 20),
          EmailTextField(),
          const SizedBox(height: 20),
          PasswordTextField(),
          const SizedBox(height:30),
          LoginButton(),
          const SizedBox(height: 30),
          
          SizedBox(
            height: 50,
            child: TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AccountChoice()));
                },
                child: const Text(
                  "Don't have an account? Sign up here",
                  style: TextStyle(fontSize: 20),
                )),
          ),

        ],
      ),
      
    )
    );
  }

}
class EmailTextField extends StatefulWidget{
  @override
  State<EmailTextField> createState() => _EmailTextField();
}
class _EmailTextField extends State<EmailTextField>{

  @override
  void initState(){
    super.initState();
    _email = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    return Center (
        child: SizedBox(
          width: 250,
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
          
          
        )

       
    );
  }

}
class PasswordTextField extends StatefulWidget{
  @override
  State<PasswordTextField> createState() => _PasswordTextField();
}
class _PasswordTextField extends State<PasswordTextField>{

  @override
  void initState(){
    super.initState();
    _password = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    return Center (
        child: SizedBox(
          width: 250,
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
        )
    );
  }

}

class LoginButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
        onPressed: () async {
          await login(context);





        },
        style: ElevatedButton.styleFrom(

            padding: const EdgeInsets.fromLTRB(60, 0, 60, 0)
        ),
        child: const Text("Log in")
    );

    
  }
  Future<void> addLoginDialog(BuildContext context, String message) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
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
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> login(context) async {

    try{

      await supabase.auth.signInWithPassword(
        email: _email.text,
        password: _password.text,
      );
      Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ContentPage(isTeacher: true,)));
    }
    on AuthException catch(e){
      addLoginDialog(context,e.message);

    }


  }



}



