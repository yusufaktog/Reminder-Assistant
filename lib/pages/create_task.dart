import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../builders.dart';
import '../constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: options);

  runApp(MaterialApp(
    home: const CreateTaskPage(),
    debugShowCheckedModeBanner: false,
    theme: mainTheme,
  ));
}

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({Key? key}) : super(key: key);

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  var _title = "";
  var _description = "";
  var _priority = "";
  final List<String> _items = <String>['Minor', 'Medium', 'Major', 'Critical'];
  var _dropDownValue = 'Minor';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: mainTheme.backgroundColor,
        appBar: AppBar(backgroundColor: mainTheme.primaryColor, centerTitle: true, title: const Text("Create Task")),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: CustomUnderlinedTextField(
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                    onChanged: (value) {
                      _title = value;
                    },
                    labelText: "Title",
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
                  child: CustomUnderlinedTextField(
                    style: const TextStyle(color: Colors.black, fontSize: 20),
                    onChanged: (value) {
                      _description = value;
                    },
                    labelText: "Description",
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 38.0),
                alignment: AlignmentGeometry.lerp(Alignment.center, AlignmentDirectional.centerStart, 1.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                  child: CustomDropDownMenu(
                    onChanged: (value) {
                      _priority = value;
                      setState(() {
                        _dropDownValue = _priority;
                        _items.remove(_dropDownValue);
                        _items.insert(0, _dropDownValue);
                      });
                    },
                    items: _items,
                    textStyle: const TextStyle(color: Colors.black, fontSize: 20),
                    dropDownValue: _dropDownValue,
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
