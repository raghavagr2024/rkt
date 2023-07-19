import 'dart:convert';


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:html_editor_enhanced/html_editor.dart';
import 'package:rkt/content.dart';


import 'main.dart';



var _title = TextEditingController();
var _body = TextEditingController();
int _id = -1;
var initJson;
class TeacherNewPage extends StatefulWidget {
  TeacherNewPage.edit(index){
    _id = index;
  }
  TeacherNewPage();




  @override
  State<StatefulWidget> createState() {

    return _TeacherNewPage();
  }
}

class _TeacherNewPage extends State<TeacherNewPage> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<dynamic>(
        future: getContentByID(_id),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            initJson = jsonDecode(snapshot.data);
            return HtmlEditorExample(title: "title");
          } else {
            return const CircularProgressIndicator();
          }
        });


  }
}

////////Find a way to get initial text loaded




class HtmlEditorExample extends StatefulWidget {
  HtmlEditorExample({ required this.title});

  final String title;

  @override
  _HtmlEditorExampleState createState() => _HtmlEditorExampleState();
}

class _HtmlEditorExampleState extends State<HtmlEditorExample> {


  final HtmlEditorController controller = HtmlEditorController();
  final ScrollController scrollController = ScrollController();
  @override
  Widget build(BuildContext context) {

    return GestureDetector(
      onTap: () {
        if (!kIsWeb) {
          controller.clearFocus();
        }
      },
      child: Scaffold(

        floatingActionButton: FloatingActionButton(
          onPressed: () {
            controller.toggleCodeView();
          },
          child: Text(r'<\>',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        ),
        body: SingleChildScrollView(

          controller: scrollController,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[

              HtmlEditor(
                controller: controller,

                htmlEditorOptions: HtmlEditorOptions(
                  hint: 'Your text here...',
                  shouldEnsureVisible: true,
                  initialText: _id!=-1?initJson[0]['Body']:"",
                ),

                htmlToolbarOptions:  const HtmlToolbarOptions(

                  toolbarPosition: ToolbarPosition.aboveEditor, //by default
                  toolbarType: ToolbarType.nativeGrid, //by default
                  dropdownMenuDirection: DropdownMenuDirection.down

                ),
                //otherOptions: const OtherOptions(height: 550),
              ),




              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    TextButton(
                      style: TextButton.styleFrom(
                          backgroundColor:
                          Theme.of(context).colorScheme.secondary),
                      onPressed: () async {
                        if(_id==-1){
                          await addContent(getTitleRaw(await controller.getText()),await controller.getText());
                        }
                        else{
                          await editContent(_id, getTitleRaw(await controller.getText()),await controller.getText());
                        }
                          SchedulerBinding.instance.addPostFrameCallback((_) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => ContentPage(isTeacher: true)));
                          });
                      },
                      child: const Text("Submit",style: TextStyle(color: Colors.white)),
                    ),


                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? getTitleRaw(String s){
    RegExp exp = RegExp('>(.*?)<');
    Iterable<RegExpMatch> matches = exp.allMatches(s);
    for(final m in matches){
      if(m[0] != ""){
        return m[0]?.substring(1,m[0]!.length-1);
      }
    }
    return "Failed";
  }
}