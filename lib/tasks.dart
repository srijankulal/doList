import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:hive_flutter/hive_flutter.dart';

class Tasks extends StatelessWidget {
  final String tasksnm; //tasks name
  final bool isDone; //check task done or not
  Function(bool?)? onChanged;
  Function(BuildContext)? deleteTask; //checkbox function
  Function(BuildContext)? editTask;

  Tasks(
      {super.key,
      required this.tasksnm,
      required this.isDone,
      this.onChanged,
      this.deleteTask,
      this.editTask});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 25, top: 25),
      child: Slidable(
        startActionPane: ActionPane(
          motion: StretchMotion(),
          children: [
            SlidableAction(
              onPressed: editTask,
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
              onPressed: deleteTask,
              icon: Icons.delete,
              backgroundColor: const Color.fromARGB(255, 220, 81, 71),
              borderRadius: BorderRadius.circular(12),
              padding: EdgeInsets.all(12),
            )
          ],
        ),
        child: Container(
          padding: EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              //checkbox

              Checkbox(
                  value: isDone,
                  onChanged: onChanged,
                  activeColor: Colors.cyanAccent),
              //text box
              Flexible(
                child: Text(
                  maxLines: tasksnm.length > 21 ? null : 1,
                  tasksnm,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    decoration: isDone
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    decorationColor: Colors.cyan,
                    decorationThickness: 2.8,
                  ),
                ),
              ),
            ],
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
