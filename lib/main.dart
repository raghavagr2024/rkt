import 'dart:convert';
import 'dart:developer';
import 'dart:html';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:dio/dio.dart' as dio;
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:rkt/account_choice.dart';
import 'package:rkt/login_user.dart';
import 'package:http/http.dart' as http;
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
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 200,
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => AccountChoice()));
                },
                child: const Text(
                  "sign up",
                  style: TextStyle(fontSize: 30),
                )),
            const SizedBox(
              height: 50,
            ),
            TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                },
                child: const Text("Log in", style: TextStyle(fontSize: 30))),
          ],
        ),
      ),
    );
  }
}

Future<http.Response> addContent(var title, var body) {
  log("in addContent");
  return http.post(
    Uri.parse('https://rkt-backend-production.vercel.app/api/db/content'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(
        <String, String>{'title': title, 'body': body}),
  );
}

Future<dynamic> addFile(List<int> file, String fileName) async {
  log("in addFile");
  final dio = Dio();
  FormData formData = FormData.fromMap({
    "file": MultipartFile.fromBytes(
      file,
      filename: fileName,
      contentType: new MediaType("image", "jpeg"),
    )
  });
  var response = await dio.post("https://rkt-backend-production.vercel.app/api/db/upload/images",data: formData);
  return response.data;
}

Future<http.Response> editContent(var id, var title, var body) {
  log("in edit Content");
  return http.put(
    Uri.parse('https://rkt-backend-production.vercel.app/api/db/content/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode({'title': title, 'body': body}),
  );
}

Future<http.Response> deleteContent(var id) {
  log("in delete Content");

  return http.delete(
    Uri.parse('https://rkt-backend-production.vercel.app/api/db/content/delete/$id'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
}

Future<dynamic> getContent() async {
  log("in get db");
  var ans =  await http.get(Uri.parse('https://rkt-backend-production.vercel.app/api/db/content'));

  return ans.body;

}
Future<String> getContentByID(var id) async {
  log("in get db");
  var ans =  await http.get(Uri.parse('https://rkt-backend-production.vercel.app/api/db/content/$id'));
  print(ans.body);
  if(ans.body=="[]"){
    print("in null");
    return "[]";
  }
  String temp = jsonDecode(ans.body)[0]["Body"];
  int max = (countOccurences(temp, "img"));
  int count = 0;
  while(count<max){
    RegExp exp = RegExp(r'image-(.*?)"');
    RegExpMatch? match = exp.firstMatch(temp);
    String s = match![0].toString();

    s = s.substring(0,s.length-1);

    temp = temp.replaceAll(s, await getFileURL(s));
    count++;
  }
  print(temp);
  return temp;



}

Future<String> getFileURL(String s) async {
  log("in get db");
  var ans =  await http.get(Uri.parse('https://rkt-backend-production.vercel.app/api/db/upload/images/$s'));
  print("ans");
  var body = jsonDecode(ans.body);
  String url = body["signedUrl"];
  print(url);
  return url;
}


int countOccurences(mainString, search) {
  int lInx = 0;
  int count =0;
  while(lInx != -1){
    lInx = mainString.indexOf(search,lInx);
    if( lInx != -1){
      count++;
      lInx+=  search.length as int;
    }
  }
  return count;
}







