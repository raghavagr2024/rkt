import 'dart:convert';
import 'dart:html';


import 'package:file_picker/file_picker.dart';
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
var files = [];
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
        future:getContentByID(_id),
        builder: (context, AsyncSnapshot<dynamic> snapshot) {
          if (snapshot.hasData) {
            initJson = snapshot.data;
            return HtmlEditorExample(title: "title");
          } else {
            return const CircularProgressIndicator();
          }
        });


  }
}






class HtmlEditorExample extends StatefulWidget {
  HtmlEditorExample({ required this.title});

  final String title;

  @override
  _HtmlEditorExampleState createState() => _HtmlEditorExampleState();
}

class _HtmlEditorExampleState extends State<HtmlEditorExample> {

  String oldName = "";
  String newName = "";
  bool imageAdded = false;
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
                  initialText: _id!=-1?initJson:"",
                ),

                htmlToolbarOptions:   HtmlToolbarOptions(
                  defaultToolbarButtons: [
                    StyleButtons(),
                    FontSettingButtons(),
                    FontButtons(),
                    ColorButtons(),
                    ListButtons(),
                    ParagraphButtons(),
                    InsertButtons()
                  ],
                  toolbarPosition: ToolbarPosition.aboveEditor, //by default
                  toolbarType: ToolbarType.nativeGrid, //by default
                  dropdownMenuDirection: DropdownMenuDirection.down,

                  mediaUploadInterceptor:
                      (PlatformFile file, InsertFileType type) async {

                    oldName = file.name;//filename

                    print(file.extension); //file extension (eg jpeg or mp4)
                    try {
                      file = PlatformFile(name: "image-${DateTime.now().millisecondsSinceEpoch}.${file.extension!}", bytes: file.bytes, size: file.size);
                      print('File renamed successfully!');
                    } catch (e) {
                      print('Failed to rename the file: $e');
                    }
                    files.add(file);
                    newName = file.name;

                    print(files.length);
                    imageAdded = true;

                    return true;
                  },


                ),


                callbacks: Callbacks(
                 onChangeContent: (String? changed) async {
                      if(imageAdded){
                        await editName();
                      }
                      else if(files.isNotEmpty){
                        String text = await controller.getText();
                        for(int i = 0; i < files.length;i++){
                          if(!text.contains(files[i].name)){
                            print("file removed: ${files[i].name}");
                            files.removeAt(i);
                            break;
                          }
                        }
                      }

                 }
                ),
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
                        String text = await controller.getText();
                        String total = "";
                        for(int i = 0; i<files.length;i++){
                            String temp = text.substring(0, text.indexOf('">')+2);
                            String ans = replaceTag(temp,i);
                            total += ans;
                            text = text.substring(text.indexOf('">')+2);
                            print(text);
                        }
                        total += text;

                        print(total);
                        print("total");
                        if(_id==-1){
                          await addContent(getTitleRaw(total),total);
                        }
                        else{
                          await editContent(_id, getTitleRaw(total),total);
                        }
                        print("after add content");
                        for(int i = 0; i<files.length;i++){
                          print(files[i].name);
                          await addFile(files[i].bytes, files[i].name);
                        }
                         print("done");
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
  Future<void> editName() async {
    print(oldName);
    print(newName);

    String text = await controller.getText();
    text = text.replaceFirst(oldName, newName);

    controller.setText(text);


    imageAdded = false;
  }

  String replaceTag(String text,int index){
    if(text.contains("style")){
      RegExp exp = RegExp(r'width:\s*(.*?);');
      RegExpMatch? match = exp.firstMatch(text);
      String s = match![0].toString();
      text = text.replaceAll(s, "width: 200px");

       exp = RegExp(r'(data:image\/png;base64,)(.*)(?=style)');
       match = exp.firstMatch(text);
       s = match![0].toString();
      text = text.replaceAll(s, "");
      text = text.substring(0,text.indexOf("img src=")+8) + '"'+files[index].name + text.substring(text.indexOf("img src=")+8);
      return text;
    }
    RegExp exp = RegExp(r"data:image\/png;base64,([^>]+)");
    RegExpMatch? match = exp.firstMatch(text);
    String s = match![0].toString();
    text = text.replaceAll(s, "");
    text = text.substring(0,text.indexOf("img src=")+8) + '"'+files[index].name + text.substring(text.indexOf("img src=")+8);
    return text;
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

class LinkButton extends StatelessWidget{
  @override
  Widget build(BuildContext context) {
    return IconButton(onPressed: (){
        pickFile();
    }, icon: Icon(Icons.link));
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      PlatformFile file = result.files.first;

      // Here, you can get the file information.
      print('File Name: ${file.name}');
      print('File Size: ${file.size}');
      print('File Path: ${file.bytes}');
      // You can handle the file as needed, like uploading it to a server or storing it locally.
    } else {
      // User canceled the file picking operation.
    }
  }

}