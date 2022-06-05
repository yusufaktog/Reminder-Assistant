import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:reminder_app/constants.dart';
import 'package:reminder_app/main.dart';
import 'package:reminder_app/model/task.dart';
import 'package:reminder_app/pages/task_card.dart';
import 'package:reminder_app/service/auth.dart';

import '../builders.dart';
import '../model/person.dart' as models;
import 'create_task.dart';

class AuthorizedPersonPage extends StatefulWidget {
  final models.Person person;

  const AuthorizedPersonPage({Key? key, required this.person}) : super(key: key);

  @override
  _AuthorizedPersonPageState createState() => _AuthorizedPersonPageState();
}

class _AuthorizedPersonPageState extends State<AuthorizedPersonPage> {
  final AuthService _authService = AuthService();

  var _selectedItem = "";
  var _selectedSortFieldName = "time";
  var _isDescending = false;
  final List<String> _dropDownMenuItems = List.of({"By Date (Asc)", "By Date (Desc)", "By Priority (Desc)", "By Priority (Asc)"});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: mainTheme.primaryColor,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        "Active Tasks",
                        style: mainTheme.textTheme.headline2,
                        textAlign: TextAlign.end,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                          alignment: Alignment.centerRight,
                          onPressed: () {
                            _authService.signOut().then((value) => switchPage(context, const ReminderApp()));
                          },
                          icon: const Icon(
                            Icons.logout,
                            color: Colors.red,
                          )),
                    )
                  ],
                ),
                Container(
                  width: double.infinity,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 10),
                  child: CustomDropDownMenu(
                    icon: const Icon(
                      Icons.sort_sharp,
                      size: 30,
                      color: Colors.white,
                    ),
                    onChanged: (dynamic value) async {
                      _selectedItem = value;
                      setState(() {
                        _dropDownMenuItems.remove(value);
                        _dropDownMenuItems.insert(0, value);
                        _selectedSortFieldName = convertSelectionToFieldName(_selectedItem);
                        _isDescending = _selectedItem.contains("Desc") ? true : false;
                      });
                    },
                    dropDownValue: _dropDownMenuItems.first,
                    items: _dropDownMenuItems,
                    dropDownColor: Colors.white,
                    itemTextStyle: mainTheme.textTheme.bodyText2,
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: mainTheme.backgroundColor,
        body: SingleChildScrollView(
          child: Column(
            children: [
              StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("People")
                      .doc(widget.person.id)
                      .collection("Tasks")
                      .orderBy(_selectedSortFieldName, descending: _isDescending)
                      .snapshots(),
                  builder: (context, snapshot) {
                    return snapshot.connectionState != ConnectionState.waiting
                        ? ListView.builder(
                            primary: false,
                            shrinkWrap: true,
                            itemCount: snapshot.data!.size,
                            itemBuilder: (context, index) {
                              var tasks = snapshot.data!.docs;

                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                                child: InkWell(
                                  onTap: () {},
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 16.0),
                                    child: TaskCard(
                                      task: Task(
                                          id: tasks[index]["id"],
                                          title: tasks[index]["title"],
                                          description: tasks[index]["description"],
                                          time: tasks[index]["time"],
                                          priority: convertPriorityToString(tasks[index]["priority"]),
                                          notificationId: tasks[index]["notificationId"],
                                          repetition: tasks[index]['repetition'],
                                          jop: tasks[index].data().toString().contains("jop") ? tasks[index]["jop"] : "none"),
                                    ),
                                  ),
                                ),
                              );
                            })
                        : const Center(
                            child: CircularProgressIndicator(),
                          );
                  }),
            ],
          ),
        ),
        bottomNavigationBar: FittedBox(
          fit: BoxFit.scaleDown,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Add Task",
                style: mainTheme.textTheme.headline6,
              ),
              IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const CreateTaskPage(),
                    ),
                  );
                },
                icon: Icon(Icons.add_box, size: 30, color: mainTheme.primaryColor),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
