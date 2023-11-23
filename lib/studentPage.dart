import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vr_speech_learning/taskView.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({super.key});

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  Future<Map<String, Map<String, String>>>? futureData;

  @override
  void initState() {
    super.initState();
    futureData = fetchTranscript();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Tugasan',
        ),
      ),
      body: FutureBuilder(
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
                      return data[key]["lessonTran"] == null || data[key]["lessonTran"] != ''
                          ? Container(
                              alignment: Alignment.center,
                              margin: const EdgeInsets.only(top: 15.0, right: 15.0, left: 15.0),
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
                              child: ListTile(
                                title: Text('${data[key]["lessonName"]}'),
                                trailing: _getTrailingAnswerStatus(data[key]["task_report"] ?? ''),
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => TaskView(
                                              recID: key,
                                            )),
                                  );
                                  setState(() {
                                    futureData = fetchTranscript();
                                  });
                                },
                              ),
                            )
                          : const Text('');
                    });
            }
          }),
    );
  }

  Widget _getTrailingAnswerStatus(String status) {
    if (status == 'correct') {
      return const Icon(
        Icons.check_circle,
        color: Colors.green,
      );
    } else {
      return const Text('');
    }
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

  Future<Map<String, Map<String, String>>> fetchTranscript() async {
    Map<String, Map<String, String>> fetchData = await getMapFromSP('Recordings');
    return fetchData;
  }
}
