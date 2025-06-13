import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Tasks extends StatefulWidget {
  final String tasksnm;
  final bool isDone; //check task done or not
  final Function(bool?)? onChanged;
  final Function(BuildContext)? deleteTask; //checkbox function
  final Function(BuildContext)? editTask;

  Tasks(
      {super.key,
      required this.tasksnm,
      required this.isDone,
      this.onChanged,
      this.deleteTask,
      this.editTask});

  @override
  State<Tasks> createState() => _TasksState();
}

class _TasksState extends State<Tasks> {
  Color bgcolor = Colors.black; // Default color
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25, top: 25),
      child: Slidable(
        startActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: widget.editTask,
              icon: Icons.edit,
              backgroundColor: const Color.fromARGB(255, 100, 225, 104),
              borderRadius: BorderRadius.circular(12),
              padding: EdgeInsets.all(12),
            )
          ],
        ),
        endActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: widget.deleteTask,
              icon: Icons.delete,
              backgroundColor: const Color.fromARGB(255, 220, 81, 71),
              borderRadius: BorderRadius.circular(12),
              padding: EdgeInsets.all(12),
            )
          ],
        ),
        child: GestureDetector(
          onDoubleTap: () {
            isSelected
                ? setState(() {
                    bgcolor = Colors.black;
                    isSelected = false;
                  })
                : setState(() {
                    bgcolor = Colors.greenAccent;
                    isSelected = true;
                  });
          },
          child: isSelected
              ? AnimatedContainer(
                  duration: Duration(milliseconds: 1000),
                  curve: Curves.easeInOut,
                  padding: EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: bgcolor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      AnimatedRotation(
                        duration: Duration(milliseconds: 1000),
                        turns: isSelected ? 1 : 0,
                        child: IconButton.filled(
                            onPressed: () {}, icon: Icon(Icons.auto_awesome)),
                      ),
                      SizedBox(width: 10),
                      AnimatedOpacity(
                        duration: Duration(milliseconds: 800),
                        opacity: isSelected ? 1.0 : 0.0,
                        child: Text("Chat with Task"),
                      )
                    ],
                  ),
                )
              : Container(
                  padding: EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: bgcolor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Checkbox(
                          value: widget.isDone,
                          onChanged: widget.onChanged,
                          activeColor: Colors.cyanAccent),
                      //text box
                      Text(
                        widget.tasksnm,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          decoration: widget.isDone
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: Colors.cyan,
                          decorationThickness: 2.8,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class dataBase {
  final _box = Hive.box('box1'); //box like a database
  List tklist = [];

  void initally() {
    tklist.add(['Welcome to the app!!', false]);
    tklist.add(['Hello', false]);
  }

  void loadTasks() {
    tklist = _box.get('ListData'); //ListData is key value
  }

  void updatData() {
    _box.put('ListData', tklist);
  }
}
