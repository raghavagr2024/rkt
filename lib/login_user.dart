import 'dart:developer';


import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:rkt/content.dart';




late TextEditingController _email, _password;
class LoginPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Column(
        children: <Widget>[
          SizedBox(height: 50,),
          Row(
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

        ],
      ),
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
          var ans = await sendCredentials();
          var result = jsonDecode(ans.body);

          if(result.toString()=="true"){
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ContentPage()));
          }
          else{
            addDialog(context);
          }





        },
        style: ElevatedButton.styleFrom(

            padding: const EdgeInsets.fromLTRB(60, 0, 60, 0)
        ),
        child: const Text("Log in")
    );
  }
  Future<void> addDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('AlertDialog Title'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Invalid Credentials'),

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

  Future<http.Response> sendCredentials() {
    print("in send credentials");
    return http.post(
      Uri.parse('http://localhost:8080/product/${_email.text}/${_password.text}'),
      headers: <String, String>{
    "Access-Control-Allow-Origin": "*"

    },
    );
  }


}



