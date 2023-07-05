
import 'package:flutter/material.dart';

class ContentPage extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        children: [
          SizedBox(height: 200,),
          Text("The user has been logged in successfully",style: TextStyle(fontSize: 30),)
        ],
      ),

    );
  }

}