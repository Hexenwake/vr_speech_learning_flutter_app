import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class correctAnswerDialog extends StatefulWidget {
  final String recName;
  const correctAnswerDialog({Key? key, required this.recName}) : super(key: key);

  @override
  State<correctAnswerDialog> createState() => _correctAnswerDialogState();
}

class _correctAnswerDialogState extends State<correctAnswerDialog> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 4), () async {
      var data = await fetchData();
      //reset answer status
      data[widget.recName]!['answerStatus'] = '';
      //save the task are answered correctly
      data[widget.recName]!['task_report'] = 'correct';

      saveMaptoSP(data, 'Recordings');
      setState(() {
        Navigator.of(context).pop();
      });
    });
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
      ),
      body: GestureDetector(
        onTap: () {
          Future.delayed(const Duration(seconds: 1), () async {
            var data = await fetchData();
            data[widget.recName]!['answerStatus'] = '';
            saveMaptoSP(data, 'Recordings');
            setState(() {
              Navigator.of(context).pop();
            });
          });
        },
        child: Column(
          children: [
            const Expanded(flex: 4, child: Text('')),
            Expanded(
              flex: 2,
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
                child: Row(
                  children: [
                    Expanded(flex: 1, child: Image.asset('assets/images/animated_celebrate.GIF')),
                    Expanded(
                      flex: 1,
                      child: Container(
                        alignment: Alignment.center,
                        child: const Text('GOODJOB',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.bold,
                            )),
                      ),
                    ),
                    Expanded(flex: 1, child: Image.asset('assets/images/animated_celebrate_flipped.gif')),
                  ],
                ),
              ),
            ),
            const Expanded(flex: 4, child: Text('')),
          ],
        ),
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
    // print(value);
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

  Future<Map<String, Map<String, String>>> fetchData() async {
    Map<String, Map<String, String>> fetchData = await getMapFromSP('Recordings');
    return fetchData;
  }
}
