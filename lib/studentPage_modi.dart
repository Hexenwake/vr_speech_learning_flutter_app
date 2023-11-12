import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vr_speech_learning/taskView.dart';

class StudentPageModi extends StatefulWidget {
  const StudentPageModi({Key? key}) : super(key: key);

  @override
  State<StudentPageModi> createState() => _StudentPageModiState();
}

class _StudentPageModiState extends State<StudentPageModi> {
  Future<Map<String, Map<String, String>>>? futureData;

  void initState() {
    super.initState();
    futureData = fetchTranscript();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3.0),
          child: Container(
            color: Colors.black,
            height: 2.5,
          ),
        ),
        title: const Text(
          'Tasks',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: FutureBuilder(
            future: futureData,
            builder: (context, AsyncSnapshot<Map<String, Map<String, String>>> snapshot) {
              switch (snapshot.connectionState) {
                case ConnectionState.none:
                case ConnectionState.waiting:
                case ConnectionState.active:
                  return Container(
                    alignment: Alignment.center,
                    child: const Text("Loading"),
                  );
                case ConnectionState.done:
                  if (snapshot.hasError) {
                    return Container(
                      alignment: Alignment.center,
                      child: Text("Error: ${snapshot.error}"),
                    );
                  }
                  Map data = snapshot.data!;
                  var keysList = data.keys.toList();

                  return ListView.builder(
                      reverse: false,
                      itemCount: data.length,
                      itemBuilder: (context, int index) {
                        var key = keysList[index];
                        return Container(
                          alignment: Alignment.center,
                          margin: const EdgeInsets.only(bottom: 15.0, right: 5.0, left: 5.0),
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
                          child: ListTile(
                            title: Text('${data[key]["lessonName"]}'),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => TaskView(
                                          recName: key,
                                        )),
                              );
                            },
                          ),
                        );
                      });
              }
            }),
      ),
    );
  }

  Future<void> saveStringtoSP(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value.isNotEmpty && key.isNotEmpty) {
      prefs.setString(key, value);
    }
  }

  Future<String> getStringFromSP(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(key);
    print(value);
    if (key.isEmpty || value == null) {
      return '';
    }
    return value;
  }

  Future<void> saveMaptoSP(Map<String, Map<String, String>> map, String key) async {
    String jsonString = jsonEncode(map);
    await saveStringtoSP(key, jsonString);
  }

  Future<Map<String, Map<String, String>>> getMapFromSP(String key) async {
    String string = await getStringFromSP(key);
    if (string.isNotEmpty) {
      Map<String, dynamic> jsonMap = Map.castFrom(json.decode(string));
      Map<String, Map<String, String>> resultMap = {};
      jsonMap.forEach((key, value) {
        resultMap[key] = Map<String, String>.from(value);
      });
      return resultMap;
    } else {
      return {};
    }
  }

  // Future<List<String>> getUsersRecordings() async {
  //   Directory? directory = await getExternalStorageDirectory();
  //   final String dirPath = '${directory!.path}/Recordings';
  //   final myDir = Directory(dirPath);
  //   if (await myDir.exists() == false) {
  //     myDir.create();
  //   }
  //   List<FileSystemEntity> recordings = myDir.listSync();
  //   List<String> recordString = recordings.map((recordings) => recordings.path).toList();
  //   return recordString;
  // }

  Future<Map<String, Map<String, String>>> fetchTranscript() async {
    Map<String, Map<String, String>> fetchData = await getMapFromSP('Recordings');
    return fetchData;
  }
}
