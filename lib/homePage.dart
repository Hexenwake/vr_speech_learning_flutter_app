import 'package:flutter/material.dart';
import 'package:vr_speech_learning/teacherPage.dart';

import 'studentPage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Center(
        child: Text('WELCOME TO VIRTUAL SPEECH APP',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
      )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StudentPage()));
              },
              child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 15.0, bottom: 15.0, right: 15.0, left: 15.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        // color: const Color(0xFF1C1C1C),
                        width: 2.0,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(10.0),
                    // color: const Color(0xFFD0C9C0),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(8.0, 5.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.5, // shadow direction: bottom right
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: const Text('Children',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ))),
            ),
          ),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherPage()));
              },
              child: Container(
                  alignment: Alignment.center,
                  margin: const EdgeInsets.only(top: 15.0, bottom: 15.0, right: 15.0, left: 15.0),
                  decoration: BoxDecoration(
                    border: Border.all(
                        // color: const Color(0xFF1C1C1C),
                        width: 2.0,
                        style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(10.0),
                    // color: const Color(0xFFD0C9C0),
                    boxShadow: const [
                      BoxShadow(
                        offset: Offset(8.0, 5.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.5, // shadow direction: bottom right
                      ),
                      BoxShadow(
                        color: Colors.white,
                        offset: Offset(0.0, 0.0),
                        blurRadius: 0.0,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: const Text('Parents',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ))),
            ),
          ),
        ],
      ),
    );
  }
}
