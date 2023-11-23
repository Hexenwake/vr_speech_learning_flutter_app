import 'package:flutter/material.dart';
import 'package:vr_speech_learning/teacherPage.dart';

import 'studentPage.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

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
          child: Text('SELAMAT DATANG',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              )),
        )),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
                flex: 2,
                child: Container(
                    alignment: Alignment.center,
                    child: const Text(
                      'Sila pilih peranan anda',
                      style: TextStyle(color: Colors.black54),
                    ))),
            Expanded(
              flex: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentPage()));
                },
                child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 15.0, right: 15.0, left: 15.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF161b33), width: 5.0, style: BorderStyle.solid),
                      color: const Color(0xFFF1dac4),
                      borderRadius: BorderRadius.circular(5.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF161b33),
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
                    child: const Text('PELAJAR',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ))),
              ),
            ),
            Expanded(
              flex: 10,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const TeacherPage()));
                },
                child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(bottom: 15.0, right: 15.0, left: 15.0),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF161b33), width: 5.0, style: BorderStyle.solid),
                      color: const Color(0xffa69cac),
                      borderRadius: BorderRadius.circular(5.0),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0xFF161b33),
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
                    child: const Text('IBU BAPA/ PENJAGA',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                        ))),
              ),
            ),
          ],
        ));
  }
}
