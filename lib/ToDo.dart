import 'package:hive_flutter/hive_flutter.dart';
import 'package:to_do_list/tasks.dart';
import 'package:flutter/material.dart';

class ToDoList extends StatefulWidget {
  const ToDoList({super.key});

  @override
  State<ToDoList> createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  String taskst = '';
  dataBase db = dataBase();
  //refer box
  final _box = Hive.box('box1');

  @override
  void initState() {
    if (_box.get('ListData') == null) {
      db.initally();
    } else {
      db.loadTasks();
    }
    super.initState();
  }

//change task status
  void changeTaskStatus(bool? status, int index) {
    setState(() {
      db.tklist[index][1] = !db.tklist[index][1];
      db.updatData(); //change status by inversing the status
    });
  }

  void addTask(String taskst) {
    setState(() {
      String taskName = taskst.trim();
      if (taskName.isNotEmpty) {
        if (taskName.length < 500) {
          db.tklist.add([taskName, false]);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task is too long'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      }
      db.updatData();
    });
  }

  void edit(String taskst, int index) {
    setState(() {
      String taskName = taskst.trim();
      if (taskName.isNotEmpty) {
        if (taskName.length < 500) {
          db.tklist[index][0] = taskName;
          db.tklist[index][1] = false;
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Task is too long to edit'),
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        db.tklist.removeAt(index);
      }
      db.updatData();
    });
  }

  void deleteTask(int index) {
    setState(() {
      db.tklist.removeAt(index);
      db.updatData();
    });
  }

  void editTask(int index) {
    setState(() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Edit Task',
                style: TextStyle(
                  color: Colors.cyanAccent,
                  fontSize: 30,
                )),
            backgroundColor: Colors.black,
            content: TextField(
              style: TextStyle(color: Colors.white),
              controller: TextEditingController(text: db.tklist[index][0]),
              onChanged: (value) {
                taskst = value;
              },
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  edit(taskst, index);
                  Navigator.of(context).pop();
                },
                child: Text('Add',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    )),
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[900],
      appBar: AppBar(
        title: Text('ToDoList App',
            style: TextStyle(
              color: Colors.cyanAccent,
              fontSize: 30,
            )),
        centerTitle: true,
        backgroundColor: Colors.black,
      ),
      body: db.tklist.isEmpty //check if list is empty conditional
          ? Center(
              child: Text('No Tasks , do something!!',
                  style: TextStyle(
                    color: Colors.cyanAccent,
                    fontSize: 20,
                  )),
            )
          : ListView.builder(
              itemCount: db.tklist.length,
              itemBuilder: (context, index) {
                return Tasks(
                  tasksnm: db.tklist[index][0],
                  isDone: db.tklist[index][1],
                  onChanged: (status) {
                    changeTaskStatus(status, index);
                  },
                  deleteTask: (context) {
                    deleteTask(index);
                  },
                  editTask: (context) {
                    editTask(index);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Add Task',
                    style: TextStyle(
                      color: Colors.cyanAccent,
                      fontSize: 30,
                    )),
                backgroundColor: Colors.black,
                content: TextField(
                  maxLines: taskst.isEmpty ? 1 : null,
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    taskst = value;
                  },
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {
                      addTask(taskst);
                      Navigator.of(context).pop();
                    },
                    child: Text('Add',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 20,
                        )),
                  ),
                ],
              );
            },
          ),
        },
        backgroundColor: Colors.cyanAccent,
        child: Icon(Icons.add),
      ),
    );
  }
}
