import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
  final List<String> _priorityItems = <String>['Minor', 'Medium', 'Major', 'Critical'];
  final List<String> _repetitionItems = <String>["No Repetition", "Hourly", "Daily", "Weekly", "Monthly", "Yearly"];
  final List<dynamic> _selectedPriorityItems = [];

  var _title = "";
  var _description = "";
  var _priority = "";
  var _repetition = "";
  var _cancelled = false;
  var _time = DateTime.now();

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
                    style: mainTheme.textTheme.headline3!,
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
                    style: mainTheme.textTheme.headline3!,
                    onChanged: (dynamic value) {
                      _description = value;
                    },
                    labelText: "Description",
                  ),
                ),
              ),
              Row(
                children: [
                  const SizedBox(width: 38),
                  Text(
                    "Priority",
                    style: mainTheme.textTheme.headline3,
                  ),
                  const SizedBox(width: 120),
                  Container(
                    alignment: AlignmentGeometry.lerp(Alignment.center, AlignmentDirectional.center, 1.0),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomDropDownMenu(
                      onChanged: (value) {
                        _priority = value;
                        setState(() {
                          _priorityItems.remove(value);
                          _priorityItems.insert(0, value);
                        });
                      },
                      items: _priorityItems,
                      dropDownValue: _priorityItems.first,
                      itemTextStyle: mainTheme.textTheme.headline5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 38),
                  Text("Time", style: mainTheme.textTheme.headline3),
                  const SizedBox(width: 0),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 110),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomTextButton(
                        text: "Open Time Picker",
                        textStyle: mainTheme.textTheme.headline4,
                        onPressed: () {
                          DatePicker.showDateTimePicker(
                            context,
                            currentTime: DateTime.now(),
                            maxTime: DateTime.now().add(const Duration(days: 365)),
                            minTime: DateTime.now(),
                            onCancel: () {
                              _cancelled = true;
                            },
                            onChanged: (DateTime? time) {},
                            onConfirm: (DateTime? time) {
                              _time = time!;
                              _cancelled = false;
                            },
                            showTitleActions: true,
                            theme: datePickerTheme,
                          );
                        }),
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 38),
                  Text("Repetition", style: mainTheme.textTheme.headline3),
                  const SizedBox(width: 80),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomDropDownMenu(
                      onChanged: (dynamic value) async {
                        _repetition = value;
                        setState(() {
                          _repetitionItems.remove(value);
                          _repetitionItems.insert(0, value);
                        });
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MultiSelect(
                                items: _getSelectedItemList(value),
                                allowMultipleSelection: _checkMultipleSelection(value),
                                onSubmit: () {
                                  _selectedPriorityItems.add(value);
                                  //Navigator.pop(context, _selectedPriorityItems);
                                  _selectedPriorityItems.forEach((element) {
                                    print(element);
                                  });
                                },
                                onCancel: () {
                                  Navigator.pop(context);
                                  _selectedPriorityItems.clear();
                                },
                                selectedItems: _selectedPriorityItems,
                                title: value,
                              );
                            });
                      },
                      dropDownValue: _repetitionItems.first,
                      items: _repetitionItems,
                      dropDownColor: Colors.white,
                      itemTextStyle: mainTheme.textTheme.headline5,
                      onTap: () {},
                    ),
                  ),
                ],
              ),
              CustomCard(
                  backGroundColor: mainTheme.primaryColor,
                  verticalMargin: 50,
                  horizontalMargin: 180,
                  padding: const EdgeInsets.all(12.0),
                  child: CustomTextButton(
                    onPressed: () {
                      if (_cancelled) {
                        Fluttertoast.showToast(
                            msg: "Please Choose Time...", fontSize: 25, timeInSecForIosWeb: 3, textColor: Colors.black, webPosition: "center");
                        return;
                      }
                    },
                    textStyle: mainTheme.textTheme.headline2,
                    text: "CREATE",
                  ),
                  borderRadius: 25),
            ],
          ),
        ),
      ),
    );
  }

  dynamic _getSelectedItemList(dynamic selectedItem) {
    switch (selectedItem) {
      case "Hourly":
        return <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];
      case "Weekly":
        return <String>["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
      case "Monthly":
        return <String>["January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"];
      case "Yearly":
        return <int>[1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
      default:
        return <String>["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
    }
  }

  bool _checkMultipleSelection(dynamic selectedItem) {
    switch (selectedItem) {
      case "Hourly":
      case "Yearly":
        return false;
      default:
        return true;
    }
  }
}
