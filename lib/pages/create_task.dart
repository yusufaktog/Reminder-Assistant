import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:reminder_app/service/notification.dart';
import 'package:reminder_app/service/task.dart';

import '../builders.dart';
import '../constants.dart';
import '../model/task.dart';

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
  var _time = DateTime.now();
  var _initialTimeText = "Open Time Picker";

  final List<String> _errors = [];
  final TaskService _taskService = TaskService();
  final NotificationService _notificationService = NotificationService();

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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Priority",
                    style: mainTheme.textTheme.headline3,
                  ),
                  const SizedBox(width: 130),
                  Container(
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Time", style: mainTheme.textTheme.headline3),
                  const SizedBox(width: 70),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomTextButton(
                        text: _initialTimeText,
                        textStyle: mainTheme.textTheme.headline4,
                        onPressed: () {
                          DatePicker.showDateTimePicker(
                            context,
                            currentTime: DateTime.now(),
                            maxTime: DateTime.now().add(const Duration(days: 365)),
                            minTime: DateTime.now(),
                            onCancel: () {
                              _errors.add(timeError);
                            },
                            onChanged: (DateTime? time) {},
                            onConfirm: (DateTime? time) {
                              _time = time!;

                              _errors.remove(timeError);
                              setState(() {
                                _initialTimeText = _time.toString().split('.')[0];
                              });
                            },
                            showTitleActions: true,
                            theme: datePickerTheme,
                          );
                        }),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Repetition", style: mainTheme.textTheme.headline3),
                  const SizedBox(width: 50),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomDropDownMenu(
                      onChanged: (dynamic value) async {
                        _repetition = value;
                        setState(() {
                          _repetitionItems.remove(value);
                          _repetitionItems.insert(0, value);
                        });
                        if (_repetition == "No Repetition") {
                          return;
                        }
                        await showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return MultiSelect(
                                items: _getSelectedItemList(value),
                                allowMultipleSelection: _checkMultipleSelection(value),
                                onSubmit: () {
                                  Navigator.pop(context);
                                  _errors.remove(repetitionError);
                                },
                                onCancel: () {
                                  Navigator.pop(context);
                                  _selectedPriorityItems.clear();
                                  _errors.add(repetitionError);
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
                      onTap: (value) {
                        _repetition = value;
                        if (_repetition == "No Repetition") {
                          _errors.remove(repetitionError);
                        }
                      },
                    ),
                  ),
                ],
              ),
              CustomCard(
                  backGroundColor: mainTheme.primaryColor,
                  verticalMargin: 30,
                  horizontalMargin: 130,
                  padding: const EdgeInsets.all(8.0),
                  child: CustomTextButton(
                    onPressed: () {
                      if (_errors.isNotEmpty) {
                        for (var error in _errors) {
                          Fluttertoast.showToast(
                              msg: error,
                              backgroundColor: mainTheme.backgroundColor,
                              fontSize: 20,
                              timeInSecForIosWeb: 3,
                              textColor: Colors.black,
                              webPosition: "center");
                        }
                        return;
                      }

                      _taskService.createTask(Task(
                          priority: _priority,
                          description: _description,
                          notificationId: createRandomNotificationId(),
                          time: _time.toString().split('.')[0],
                          title: _title));
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
