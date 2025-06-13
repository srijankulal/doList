import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:to_do_list/ToDo.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:to_do_list/const.dart';

// import 'package:flutter_config/flutter_config.dart';

void main() async {
  // WidgetsFlutterBinding.ensureInitialized(); // Required by FlutterConfig
  // await FlutterConfig.loadEnvVariables();
  Gemini.init(apiKey: Gemini_API_KEY);
  await Hive.initFlutter();
  var box = await Hive.openBox('box1');
  runApp(
      // DevicePreview(builder: (context) => const MainApp()),
      const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ToDoList(),
      theme: ThemeData(
        fontFamily: GoogleFonts.poppins().fontFamily,
      ),
    );
  }
}
