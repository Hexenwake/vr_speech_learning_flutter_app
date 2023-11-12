import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vr_speech_learning/teacherPage.dart';

import 'studentPage_modi.dart';

Future<List<String>> getUsersRecordings() async {
  Directory? directory = await getExternalStorageDirectory();
  final String dirPath = '${directory!.path}/Recordings';
  final myDir = Directory(dirPath);
  List<FileSystemEntity> recordings = myDir.listSync();
  List<String> recordString = recordings.map((recordings) => recordings.path).toList();
  return recordString;
}

Future<Map<String, String>> fetchTranscript() async {
  Map<String, String> fetchData = <String, String>{};
  List<String> recordings = await getUsersRecordings();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  for (var value in recordings) {
    if (prefs.getString(value) == null) {
      prefs.setString(value, 'no transcripts');
    }
    fetchData[value] = prefs.getString(value)!;
  }
  return fetchData;
}

// Future<Map<String, String>> fetchData() async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   String jsonData = prefs.getString('data')!;
//   Map<String, String> data = Map<String, String>.from(json.decode(jsonData));
//
//   return data;
// }

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
              color: Colors.black,
            )),
      )),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 8,
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => StudentPageModi()));
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
