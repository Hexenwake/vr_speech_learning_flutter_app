import 'package:flutter/material.dart';

import 'util/landingPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Virtual Speech Learning',
      theme: ThemeData(
        useMaterial3: false,
        // textTheme: GoogleFonts.oswaldTextTheme().apply(fontSizeFactor: 1.1, fontSizeDelta: 2.0),
        textTheme: Theme.of(context).textTheme.apply(
              fontSizeFactor: 1.1,
              fontSizeDelta: 1.0,
            ),
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0d0c1d)),
      ),
      home: const LandingPage(),
    );
  }
}
