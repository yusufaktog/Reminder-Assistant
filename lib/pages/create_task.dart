import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:reminder_app/service/notification.dart';
import 'package:reminder_app/service/task.dart';

import '../builders.dart';
import '../constants.dart';
import '../model/task.dart';

class CreateTaskPage extends StatefulWidget {
  const CreateTaskPage({Key? key}) : super(key: key);

  @override
  _CreateTaskPageState createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final List<String> _priorityItems = List.of(TaskPriority.items);
  final List<String> _repetitionItems = List.of(Repetition.items);
  final List<String> _jobItems = List.of(Job.items);

  final TextEditingController _phoneTextEditingController = TextEditingController();

  var _title = "";
  var _description = "";
  var _priority = "";
  var _repetition = Repetition.none;
  var _time = DateTime.now();
  var _initialTimeText = initialTimeText;
  var _job = Job.none;
  var _jopFields = [];
  var _timeButtonDisabled = false;
  var _phoneNumber = "+90 ";
  var _subject = "";
  var _body = "";
  var _emailAddress = "";
  var _url = "";

  final Set<String> _errors = {};
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
                    style: mainTheme.textTheme.headline5!,
                    onChanged: (value) {
                      setState(() {
                        _title = value;
                      });
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
                    style: mainTheme.textTheme.headline5!,
                    onChanged: (value) {
                      setState(() {
                        _description = value;
                      });
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
                    style: mainTheme.textTheme.headline5,
                  ),
                  const SizedBox(width: 120),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomDropDownMenu(
                      onChanged: (value) {
                        setState(() {
                          _priority = value;
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
                  Text("Repetition", style: mainTheme.textTheme.headline5),
                  const SizedBox(width: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomDropDownMenu(
                      onChanged: (dynamic value) async {
                        setState(() {
                          _repetition = value;
                          _repetitionItems.remove(value);
                          _repetitionItems.insert(0, value);

                          if (_repetition == Repetition.minutely || _repetition == Repetition.hourly) {
                            showToastMessage(
                                "With : $_repetition, Repeat interval automatically starts at creation time "
                                "Thus, no need to set a start time",
                                Colors.red,
                                16);
                            _timeButtonDisabled = true;
                          } else {
                            _timeButtonDisabled = false;
                          }
                          setState(() {
                            _timeButtonDisabled ? _initialTimeText = DateTime.now().toString().split('.')[0] : _initialTimeText = initialTimeText;
                          });
                        });
                      },
                      dropDownValue: _repetitionItems.first,
                      items: _repetitionItems,
                      dropDownColor: Colors.white,
                      itemTextStyle: mainTheme.textTheme.headline5,
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Time", style: mainTheme.textTheme.headline5),
                  const SizedBox(width: 70),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomTextButton(
                        text: _initialTimeText,
                        textStyle: mainTheme.textTheme.headline5,
                        onPressed: () {
                          if (_timeButtonDisabled) {
                            showToastMessage(ErrorString.timeAndRepetitionMissMatch, Colors.black, 16);
                            return;
                          }
                          DatePicker.showDateTimePicker(context,
                              currentTime: DateTime.now().add(const Duration(minutes: 1)),
                              maxTime: DateTime.now().add(const Duration(days: 365)),
                              minTime: DateTime.now().add(const Duration(minutes: 1)), onCancel: () {
                            setState(() {
                              _initialTimeText = initialTimeText;
                            });
                          }, onChanged: (DateTime? time) {
                            _time = time!;

                            setState(() {
                              _initialTimeText = _time.toString().split(microSecondsSeparator)[0];
                            });
                          }, onConfirm: (DateTime? time) {
                            _time = time!;

                            setState(() {
                              _initialTimeText = _time.toString().split(microSecondsSeparator)[0];
                            });
                          }, showTitleActions: true, theme: datePickerTheme);
                        }),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Attached Job", style: mainTheme.textTheme.headline5),
                  const SizedBox(width: 40),
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: CustomDropDownMenu(
                        onChanged: (dynamic value) async {
                          _job = value;
                          setState(() {
                            _jobItems.remove(value);
                            _jobItems.insert(0, value);
                            _jopFields = createDialogElements(_job);
                          });
                        },
                        dropDownValue: _jobItems.first,
                        items: _jobItems,
                        dropDownColor: Colors.white,
                        itemTextStyle: mainTheme.textTheme.headline5),
                  ),
                ],
              ),
              _jopFields.contains("Phone Number")
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: CustomUnderlinedTextField(
                        keyboardType: TextInputType.phone,
                        onChanged: (value) {
                          _phoneNumber = value;
                        },
                        style: mainTheme.textTheme.headline5!,
                        labelText: "Phone Number",
                        textEditingController: _phoneTextEditingController,
                      ))
                  : emptyWidget,
              _jopFields.contains("Email Address")
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: CustomUnderlinedTextField(
                          keyboardType: TextInputType.emailAddress,
                          onChanged: (value) {
                            _emailAddress = value;
                          },
                          style: mainTheme.textTheme.headline5!,
                          labelText: "Email Address"))
                  : emptyWidget,
              _jopFields.contains("Subject")
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: CustomUnderlinedTextField(
                          onChanged: (value) {
                            _subject = value;
                          },
                          style: mainTheme.textTheme.headline5!,
                          labelText: "Subject"))
                  : emptyWidget,
              _jopFields.contains("Body")
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: CustomUnderlinedTextField(
                          onChanged: (value) {
                            _body = value;
                          },
                          style: mainTheme.textTheme.headline5!,
                          labelText: "Body"))
                  : emptyWidget,
              _jopFields.contains("Url")
                  ? Container(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: CustomUnderlinedTextField(
                          keyboardType: TextInputType.url,
                          onChanged: (value) {
                            _url = value;
                          },
                          style: mainTheme.textTheme.headline5!,
                          labelText: "Url"))
                  : emptyWidget,
              CustomCard(
                  backGroundColor: mainTheme.primaryColor,
                  verticalMargin: 30,
                  horizontalMargin: 130,
                  padding: const EdgeInsets.all(4.0),
                  child: CustomTextButton(
                    onPressed: () async {
                      if (_description.isEmpty) {
                        _errors.add(createErrorInfo(FieldName.description));
                      }
                      if (_title.isEmpty) {
                        _errors.add(createErrorInfo(FieldName.title));
                      }
                      if (_initialTimeText == initialTimeText) {
                        _errors.add(ErrorString.time);
                      }

                      int _notificationId = (createRandomNotificationId() / 1000).toInt();
                      // fit to 2^32
                      while (_notificationId >= 0x7fffffff) {
                        _notificationId = (_notificationId * Random().nextDouble()).toInt();
                      }

                      if (_errors.isNotEmpty) {
                        for (var error in _errors) {
                          showToastMessage(error, mainTheme.primaryColor, 16);
                        }
                        _errors.clear();
                        return;
                      }
                      String _taskId = await _taskService.createTask(Task(
                          priority: _priority,
                          description: _description,
                          notificationId: _notificationId,
                          time: _time.toString().split('.')[0],
                          title: _title,
                          repetition: _repetition));

                      await _taskService.getDocRef(_taskId).update({
                        'job': _job,
                        if (_url.isNotEmpty) 'url': _url,
                        if (_body.isNotEmpty) 'body': _body,
                        if (_phoneNumber.isNotEmpty) 'phoneNumber': _phoneNumber,
                        if (_subject.isNotEmpty) 'subject': _subject,
                        if (_emailAddress.isNotEmpty) 'emailAddress': _emailAddress
                      });

                      if (_repetition == Repetition.none) {
                        _notificationService.createScheduledNotificationWithNoRepetition(_title, _description, _notificationId, _time, _taskId);
                      } else if (_repetition == Repetition.minutely || _repetition == Repetition.hourly) {
                        _notificationService.createScheduledNotificationWithRepeatInterval(
                            _title, _description, _notificationId, RepeatInterval.everyMinute, _taskId);
                      } else {
                        _notificationService.createCustomScheduledNotification(_title, _description, _notificationId, _time, _repetition, _taskId);
                      }
                      _errors.clear();
                      Navigator.of(context).pop();
                      showToastMessage("Task successfully created", Colors.black, 20);
                    },
                    textStyle: mainTheme.textTheme.headline2,
                    text: "CREATE",
                  ),
                  borderRadius: 20),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _phoneTextEditingController.text = "(+90) ";
    _errors.clear();
  }
}
