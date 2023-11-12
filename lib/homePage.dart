import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'studentPage_modi.dart';
import 'teacherPage.dart';

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
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => TeacherPage()));
                },
                child: const Text('Teacher Page')),
            ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => StudentPageModi()));
                },
                child: const Text('Student Page')),
          ],
        ),
      ),
    );
  }
}
