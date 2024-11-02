import 'package:flutter/material.dart';
import 'package:to_do_list/ToDo.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  var box = await Hive.openBox('box1');
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ToDoList(),
      theme: ThemeData(
        fontFamily: 'Outfit-Regular',
      ),
    );
  }
}
