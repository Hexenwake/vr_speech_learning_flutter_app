import 'dart:convert';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudentPage extends StatefulWidget {
  const StudentPage({Key? key}) : super(key: key);

  @override
  State<StudentPage> createState() => _StudentPageState();
}

class _StudentPageState extends State<StudentPage> {
  bool _isRecording = false;
  late Future<Map<String, String>> futureListing;
  late Future<Map<String, String>> studentRecordings;
  AudioRecorder record = AudioRecorder();

  @override
  void initState() {
    super.initState();
    futureListing = fetchTranscript();
    studentRecordings = fetchTranscriptStudent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks'),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
                future: futureListing,
                builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
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
                      Map<String, String> myMap = snapshot.data!;
                      var keysList = myMap.keys.toList();

                      return ListView.builder(
                        reverse: false,
                        itemCount: myMap.length,
                        itemBuilder: (context, int index) {
                          AssetsAudioPlayer.withId(index.toString());
                          var lessonFilename = keysList[index].split('/').last;
                          return ExpansionTile(
                            title: Text('Lesson ${index + 1}'),
                            trailing: const Icon(
                              Icons.arrow_drop_down,
                            ),
                            // subtitle: Text('${myMap[keysList[index]]}'),
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                alignment: Alignment.center,
                                child: Column(
                                  children: [
                                    ListTile(
                                      subtitle: Text('${myMap[keysList[index]]}'),
                                      trailing: AssetsAudioPlayer.withId(index.toString()).builderIsPlaying(builder: (context, isPlaying) {
                                        return IconButton(
                                          onPressed: () {
                                            isPlaying
                                                ? AssetsAudioPlayer.withId(index.toString()).pause()
                                                : AssetsAudioPlayer.withId(index.toString()).open(
                                                    Audio.file(keysList[index]),
                                                    autoStart: true,
                                                    showNotification: false,
                                                  );
                                          },
                                          icon: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                                        );
                                      }),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        if (_isRecording) {
                                          _stopRecording();
                                        } else {
                                          _startRecording(keysList[index].split('/').last);
                                        }
                                      },
                                      child: Text(_isRecording ? 'Stop' : 'Start'),
                                    ),
                                    FutureBuilder(
                                        future: studentRecordings,
                                        builder: (context, AsyncSnapshot<Map<String, String>> snapshot) {
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
                                              Map<String, String> data = snapshot.data!;
                                              Map<String, String> filename = {};

                                              data.forEach((key, value) {
                                                filename[key.split('/').last] = value;
                                              });
                                              var keysListSub = filename.keys.toList();

                                              if (filename.containsKey(lessonFilename)) {
                                                print(filename[lessonFilename]);
                                                print(myMap[keysList[index]]);
                                                print(index);
                                                //null checking
                                                if (filename[lessonFilename] == null) {
                                                  filename[lessonFilename] = 'Waiting for Submission Upload';
                                                }

                                                if (myMap[keysList[index]] == null) {
                                                  myMap[keysList[index]] = 'Waiting for Lesson Upload';
                                                }
                                                return Column(
                                                  children: [
                                                    ListTile(
                                                        title: const Text('Submitted'),
                                                        subtitle: Text('Transcript ${filename[lessonFilename]}'),
                                                        trailing: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            AssetsAudioPlayer.withId(lessonFilename).builderIsPlaying(builder: (context, isPlaying2) {
                                                              return IconButton(
                                                                onPressed: () {
                                                                  isPlaying2
                                                                      ? AssetsAudioPlayer.withId(lessonFilename).pause()
                                                                      : AssetsAudioPlayer.withId(lessonFilename).open(
                                                                          Audio.file(data.keys.elementAt(keysListSub.indexOf(lessonFilename))),
                                                                          autoStart: true,
                                                                          showNotification: false,
                                                                        );
                                                                },
                                                                icon: Icon(isPlaying2 ? Icons.pause : Icons.play_arrow),
                                                              );
                                                            }),
                                                            IconButton(
                                                                onPressed: () {
                                                                  setState(() {
                                                                    uploadAudio(File(data.keys.elementAt(keysListSub.indexOf(lessonFilename))),
                                                                        lessonFilename, context);
                                                                  });
                                                                },
                                                                icon: const Icon(Icons.upload)),
                                                          ],
                                                        )),
                                                    if (filename[lessonFilename]!.contains(myMap[keysList[index]]!)) ...{
                                                      // Expanded(child: ),
                                                      Column(
                                                        children: [
                                                          IconButton(
                                                              onPressed: () {},
                                                              icon: const Icon(
                                                                Icons.verified,
                                                                color: Colors.green,
                                                              )),
                                                          const Text(
                                                            'Passed',
                                                            style: TextStyle(color: Colors.green),
                                                          ),
                                                        ],
                                                      )
                                                    } else ...{
                                                      // Expanded(child: ),
                                                      Column(
                                                        children: [
                                                          IconButton(
                                                              onPressed: () {},
                                                              icon: const Icon(
                                                                Icons.error,
                                                                color: Colors.red,
                                                              )),
                                                          const Text(
                                                            'Not Passed Yet',
                                                            style: TextStyle(color: Colors.red),
                                                          ),
                                                        ],
                                                      )
                                                      // print(filename[lessonFilename]);
                                                    }
                                                  ],
                                                );
                                              } else {
                                                return const Text('Not taken');
                                              }
                                          }
                                        }),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                  }
                }),
          )
        ],
      ),
    );
  }

  // Widget studentRecording(
  //     BuildContext context, Map<String, String> myMap, int index) {
  //   var keysList = myMap.keys.toList();
  //   // print(keysList);
  //   // print(index);
  //   var lessonFilename = keysList[index].split('/').last;
  //   print('$lessonFilename $index');
  //
  //
  // }

  Future<void> _startRecording(String filename) async {
    setState(() {
      record = AudioRecorder();
    });
    final Directory? directory = await getExternalStorageDirectory();
    final String dirPath = '${directory!.path}/Submission';
    final String fileName = filename;
    final String filePath = '${directory.path}/Submission/$fileName';
    if (await record.hasPermission()) {
      bool isDirectoryCreated = await Directory(dirPath).exists();
      if (!isDirectoryCreated) {
        Directory(dirPath).create().then((Directory directory) {
          if (kDebugMode) {
            print(directory.path);
          }
        });
      }
      // Start recording to file
      await record.start(const RecordConfig(), path: filePath);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording() async {
    final path = await record.stop();

    setState(() {
      _isRecording = false;
      studentRecordings = fetchTranscriptStudent();
      record.dispose();
    });
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

  Future<void> saveMaptoSP(Map<String, String> map, String key) async {
    String jsonString = jsonEncode(map);
    await saveStringtoSP(key, jsonString);
  }

  Future<Map<String, String>> getMapFromSP(String key) async {
    String string = await getStringFromSP(key);
    if (string.isNotEmpty) {
      Map<String, String> data = Map.castFrom(json.decode(string));
      // print(jsonDecode(string));
      return data;
    } else {
      return {};
    }
  }

  Future<List<String>> getTeacherRecordings() async {
    Directory? directory = await getExternalStorageDirectory();
    final String dirPath = '${directory!.path}/Recordings';
    final myDir = Directory(dirPath);
    List<FileSystemEntity> recordings = myDir.listSync();
    List<String> recordString = recordings.map((recordings) => recordings.path).toList();
    return recordString;
  }

  Future<Map<String, String>> fetchTranscript() async {
    Map<String, String> fetchData = await getMapFromSP('Teacher');
    List<String> recordings = await getTeacherRecordings();

    for (var value in recordings) {
      if (fetchData[value] == null) {
        fetchData[value] = 'No Transcript';
      }
      // fetchData[value] = prefs.getString(value)!;
    }
    return fetchData;
  }

  Future<List<String>> getStudentRecordings() async {
    Directory? directory = await getExternalStorageDirectory();
    final String dirPath = '${directory!.path}/Submission';
    final myDir = Directory(dirPath);

    if (await myDir.exists() == false) {
      myDir.create();
    }
    List<FileSystemEntity> recordings = myDir.listSync();
    List<String> recordString = recordings.map((recordings) => recordings.path).toList();
    return recordString;
  }

  Future<Map<String, String>> fetchTranscriptStudent() async {
    Map<String, String> fetchData = await getMapFromSP('Student');
    List<String> recordings = await getStudentRecordings();

    for (var value in recordings) {
      if (fetchData[value] == null) {
        fetchData[value] = 'No Transcript';
      }
      // fetchData[value] = prefs.getString(value)!;
    }
    return fetchData;
  }

  Future<void> uploadAudio(File file, String filename, context) async {
    final request = http.MultipartRequest("POST", Uri.http("192.168.0.154:5000", "/upload"));

    request.files.add(
      http.MultipartFile(
        'files',
        file.readAsBytes().asStream(),
        file.lengthSync(),
        filename: filename,
      ),
    );

    final headers = {"Content-type": "multipart/form-data"};
    request.headers.addAll(headers);

    var res = await request.send();
    var response = await http.Response.fromStream(res);
    String transcript = response.body;
    var fetchData = await getMapFromSP('Student');
    fetchData[file.path] = transcript;
    await saveMaptoSP(fetchData, 'Student');
    setState(() {
      studentRecordings = fetchTranscriptStudent();
    });
    // print(transcript);
  }
}
