import 'package:flutter/material.dart';

import 'homePage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'VR_Speech_Learning',
      theme: ThemeData(
        // textTheme: GoogleFonts.oswaldTextTheme().apply(fontSizeFactor: 1.1, fontSizeDelta: 2.0),
        textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: 1.1,
              fontSizeDelta: 1.0,
            ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1f5c70)),
      ),
      home: const MyHomePage(),
    );
  }
}
