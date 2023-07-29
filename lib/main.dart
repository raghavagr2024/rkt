import 'package:flutter/material.dart';
import 'package:rkt/accountChoice.dart';
import 'package:rkt/login_user.dart';

import 'package:supabase_flutter/supabase_flutter.dart';
final supabase = Supabase.instance.client;
Future<void> main() async {
  await Supabase.initialize(
    url: 'https://fqblcjjyxmyelgnwoyru.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZxYmxjamp5eG15ZWxnbndveXJ1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODc1NjgwNzYsImV4cCI6MjAwMzE0NDA3Nn0.xpsBchAJfqv_f97qL2boxvBMpBzs9zBQqZ3dFs8kBAI',
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    String welcomeMessage = "Welcome!";
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "RKT Balmukund",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ), 
        elevation: 8,
      ),
      body: Container(
        decoration: const BoxDecoration(
          image:  DecorationImage(
            image: AssetImage("../../../lib/mainBackground2.jpeg"),
            fit: BoxFit.cover,
            opacity: 200
            )
        ),
        child:Center(
          child: Column(
            children: [
              const SizedBox(
                height: 50,
              ),   
              Container(
                margin: const EdgeInsets.only(bottom: 150),
                child: 
                Text(
                  welcomeMessage,
                  style: const TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => AccountChoice()));
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.only(right: 24.0, left: 24.0, bottom: 12, top: 12), // Set padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Set border radius
                    ),
                    elevation: 3,
                    
                  ),
                  child:
                  const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.person_add,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                    "Sign Up",
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  )])),
              const SizedBox(
                height: 50,
              ),
            
              TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => LoginPage()));
                  },

                  style: TextButton.styleFrom(
                    foregroundColor: Colors.blue,
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 31.0, vertical: 12.0), // Set padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0), // Set border radius
                    ),
                    elevation: 3,
                  ),
                  child: 
                  const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.login,
                      color: Colors.white,
                    ),
                    SizedBox(width: 8),
                    Text(
                    "Log In",
                    style: TextStyle(fontSize: 20, color: Colors.white, fontWeight: FontWeight.bold),
                  )])),

                  
    
            ],
          ),
        ),
      ),
      
    );

    
  }
}
