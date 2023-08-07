import 'dart:convert';
import 'dart:html';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'package:html_editor_enhanced/html_editor.dart';
import 'package:rkt/content.dart';

import 'main.dart';
import 'package:pointer_interceptor/pointer_interceptor.dart';

var currentCategories = [];
final _formKey = GlobalKey<FormState>();
var _title = TextEditingController();
var _body = TextEditingController();
int _id = -1;
var initJson;
var files = [];


class TeacherNewPage extends StatefulWidget {
  TeacherNewPage.edit(index) {
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
            initJson = snapshot.data;
            print(initJson);
            if(!initJson.isEmpty){
              currentCategories = initJson[1];
              ageController.text = initJson[2].toString();
              initJson = initJson[0];
            }
            else{
              initJson = "[]";
            }


            print(currentCategories);

            return HtmlEditorExample(title: "title");
          } else {
            return const CircularProgressIndicator();
          }
        });
  }
}
var x = categories.length * 100;
class HtmlEditorExample extends StatefulWidget {
  HtmlEditorExample({required this.title});

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

  void updateCategory(String s){
    setState(() {
      print(s);
      categories.add(s);
      if(x+100>1300){
        x = 1300;
      }
      else{
        x+=100;
      }
      print(categories);
      Navigator.of(context).pop();
    });
  }

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
                  initialText: _id != -1 ? initJson : "",
                ),
                htmlToolbarOptions: HtmlToolbarOptions(
                  defaultToolbarButtons: [
                    StyleButtons(),
                    FontSettingButtons(),
                    FontButtons(),
                    ColorButtons(),
                    ListButtons(),
                    ParagraphButtons(),
                    InsertButtons()
                  ],
                  customToolbarButtons: [
                    Container(
                      width:  x,
                      height: 120,
                      child:
                          CategoryButton(scrollController: ScrollController()),
                    ),
                    AddCategory(updateCategory: updateCategory,),
                    AgeTextField(),

                  ],
                  toolbarPosition: ToolbarPosition.aboveEditor,
                  //by default
                  toolbarType: ToolbarType.nativeGrid,
                  //by default
                  dropdownMenuDirection: DropdownMenuDirection.down,

                  mediaUploadInterceptor:
                      (PlatformFile file, InsertFileType type) async {
                    oldName = file.name; //filename

                    print(file.extension); //file extension (eg jpeg or mp4)
                    try {
                      file = PlatformFile(
                          name:
                              "image-${DateTime.now().millisecondsSinceEpoch}.${file.extension!}",
                          bytes: file.bytes,
                          size: file.size);
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
                callbacks: Callbacks(onChangeContent: (String? changed) async {
                  if (imageAdded) {
                    await editName();
                  } else if (files.isNotEmpty) {
                    String text = await controller.getText();
                    for (int i = 0; i < files.length; i++) {
                      if (!text.contains(files[i].name)) {
                        print("file removed: ${files[i].name}");
                        files.removeAt(i);
                        break;
                      }
                    }
                  }
                }),
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
                        if (_formKey.currentState!.validate() && currentCategories.isNotEmpty && text.isNotEmpty) {

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
                            await addContent(getTitleRaw(total),total,currentCategories,int.tryParse(ageController.text));
                          }
                          else{
                            await editContent(_id, getTitleRaw(total),total,currentCategories,int.tryParse(ageController.text));
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
                        }

                        },
                      child: const Text("Submit",
                          style: TextStyle(color: Colors.white)),
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

  String replaceTag(String text, int index) {
    if (text.contains("style")) {
      RegExp exp = RegExp(r'width:\s*(.*?);');
      RegExpMatch? match = exp.firstMatch(text);
      String s = match![0].toString();
      text = text.replaceAll(s, "width: 200px");

      exp = RegExp(r'(data:image\/png;base64,)(.*)(?=style)');
      match = exp.firstMatch(text);
      s = match![0].toString();
      text = text.replaceAll(s, "");
      text = text.substring(0, text.indexOf("img src=") + 8) +
          '"' +
          files[index].name +
          text.substring(text.indexOf("img src=") + 8);
      return text;
    }
    RegExp exp = RegExp(r"data:image\/png;base64,([^>]+)");
    RegExpMatch? match = exp.firstMatch(text);
    String s = match![0].toString();
    text = text.replaceAll(s, "");
    text = text.substring(0, text.indexOf("img src=") + 8) +
        '"' +
        files[index].name +
        text.substring(text.indexOf("img src=") + 8);
    return text;
  }

  String? getTitleRaw(String s) {
    RegExp exp = RegExp('>(.*?)<');
    Iterable<RegExpMatch> matches = exp.allMatches(s);
    for (final m in matches) {
      if (m[0] != "") {
        return m[0]?.substring(1, m[0]!.length - 1);
      }
    }
    return "Failed";
  }
}

class AgeTextField extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _AgeTextField();
  }
}
var ageController = TextEditingController();
class _AgeTextField extends State<AgeTextField> {


  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 120,
        width: 60,
        child: Form(
          key: _formKey,
          child: TextFormField(
            controller: ageController,
            decoration: const InputDecoration(
              labelText: 'Age',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                print("null");
                return 'no text';
              } else if (int.tryParse(value) == null) {
                return 'number';
              }
              return null;
            },
          ),
        ));
  }
}

class CategoryButton extends StatelessWidget {
  ScrollController scrollController = ScrollController();

  CategoryButton({required ScrollController scrollController});

  @override
  Widget build(BuildContext context) {
    return Scrollbar(
        controller: scrollController,
        child: ListView.builder(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          itemBuilder: _getCategories,
          itemCount: categories.length,
        ));
  }

  Widget _getCategories(context, index) {
    return Category(
      context: context,
      index: index,
    );
  }
}

class Category extends StatefulWidget {
  var context;
  int index;

  Category({required this.context, required this.index});

  @override
  State<StatefulWidget> createState() {
    return _Category(context: context, index: index);
  }
}

class _Category extends State<Category> {
  var context;
  int index;
  bool added = false;

  _Category({required this.context, required this.index});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        if (currentCategories.contains(categories.elementAt(index))) {
          removeCategory();
        } else {
          addCategory();
        }
      },
      child: Row(
        children: [Text(categories.elementAt(index)), Icon(added ? Icons.check : null)],
      ),
    );
  }

  void removeCategory() {
    setState(() {
      currentCategories.remove(categories.elementAt(index));
      added = false;
    });
  }

  void addCategory() {
    setState(() {
      currentCategories.add(categories.elementAt(index));
      added = true;
    });
  }
}
class AddCategory extends StatefulWidget{
  final ValueChanged<String> updateCategory;
  AddCategory({required this.updateCategory});
  @override
  State<StatefulWidget> createState() {
    return _AddCategory(updateCategory: updateCategory);
  }
}
class _AddCategory extends State<AddCategory> {
  final ValueChanged<String> updateCategory;
  _AddCategory({required this.updateCategory});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      width: 130,
      child: Row(
        children: [
          TextButton(onPressed: () {
            _showAlertDialog(context);
          }, child: const Text("add category")),
          Icon(Icons.add)
        ],
      ),
    );
  }

  var key = GlobalKey<FormState>();

  Future<void> _showAlertDialog(BuildContext context) async {
    var _textEditingController = TextEditingController();
    final _key = GlobalKey<FormState>();
    return await showDialog(
        context: context,
        builder: (context) {

          return StatefulBuilder(builder: (context, setState) {
            return PointerInterceptor(
                child:AlertDialog(
              content: Form(
                  key: _key,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _textEditingController,

                        decoration: InputDecoration(hintText: "Please Enter Text"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter some text';
                          }
                          else if(categories.contains(value.toLowerCase())){
                            return "Category already exists";
                          }
                          return null;
                        },
                      ),

                    ],
                  )),
              title: Text("Add category"),
              actions: <Widget>[
                InkWell(
                  child: Text('Deny '),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                InkWell(
                  child: Text('Confirm'),
                  onTap: () {
                    if (_key.currentState!.validate()) {

                      print("doing stuff");
                      updateCategory(_textEditingController.text);

                    }
                  },
                ),
              ],
            ));
          });
        });
  }


}