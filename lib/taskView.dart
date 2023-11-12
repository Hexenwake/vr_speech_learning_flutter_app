import 'dart:convert';
import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TaskView extends StatefulWidget {
  final String recName;
  const TaskView({Key? key, required this.recName}) : super(key: key);

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  bool _isRecording = false;
  bool _isLoading = false;
  AudioRecorder record = AudioRecorder();
  late Future<String> congratulateAudioPath;
  late Future<Map<String, String>?> futureData;
  final dio = Dio();

  @override
  void initState() {
    // TODO: implement initState
    futureData = fetchData(widget.recName);
    congratulateAudioPath = _getCongratulateAudioPath();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: futureData,
        builder: (context, AsyncSnapshot<Map<String, String>?> snapshot) {
          Map<String, String>? data = snapshot.data;
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
              if (data!['answerStatus'] == 'Correct') {
                return FutureBuilder(
                    future: congratulateAudioPath,
                    builder: (context, AsyncSnapshot audioSnapshot) {
                      if (audioSnapshot.data == null) {
                        return Container(
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(),
                        );
                      }

                      String audio = audioSnapshot.data;
                      AssetsAudioPlayer.withId(audio).open(
                        Audio.file(audio),
                        autoStart: true,
                        showNotification: false,
                      );

                      return Scaffold(
                        appBar: AppBar(
                          title: const Text(''),
                        ),
                        body: GestureDetector(
                          onTap: () {
                            Navigator.of(context).pop();
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
                                      const Expanded(
                                        flex: 1,
                                        child: Text('GOODJOB',
                                            style: TextStyle(
                                              fontSize: 25,
                                              fontWeight: FontWeight.bold,
                                            )),
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
                      // }
                    });
              }
              return Scaffold(
                appBar: AppBar(title: Text(data["lessonName"]!)),
                body: ModalProgressHUD(
                  inAsyncCall: _isLoading,
                  child: Center(
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            flex: 6,
                            child: data['imgPath'] == null
                                ? Text(data['lessonTran']?.toUpperCase() ?? 'No Transcript',
                                    style: const TextStyle(
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ))
                                : Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 8,
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Image.file(
                                              File(data['imgPath']!),
                                              fit: BoxFit.fill,
                                              // height: 300.0,
                                              // width: 230.0,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Text(data['lessonTran']?.toUpperCase() ?? 'No Transcript',
                                              style: const TextStyle(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                              )),
                                        ),
                                      ],
                                    ),
                                  ),
                          ),
                          Expanded(
                            flex: 2,
                            child: SizedBox(
                                height: 50,
                                width: 50,
                                child: AssetsAudioPlayer.withId(widget.recName).builderIsPlaying(builder: (context, isPlaying) {
                                  return FloatingActionButton(
                                    onPressed: () {
                                      isPlaying
                                          ? AssetsAudioPlayer.withId(widget.recName.toString()).pause()
                                          : AssetsAudioPlayer.withId(widget.recName.toString()).open(
                                              Audio.file(data['path']!),
                                              autoStart: true,
                                              showNotification: false,
                                            );
                                    },
                                    child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                                  );
                                })),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Text(data['answerStatus'] ?? ''),
                                SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: FloatingActionButton(
                                    backgroundColor: _isRecording ? Colors.red : Colors.green,
                                    onPressed: () {
                                      if (_isRecording) {
                                        _stopRecording(widget.recName, context);
                                      } else {
                                        _startRecording(widget.recName);
                                      }
                                    },
                                    child: Icon(_isRecording ? Icons.stop : Icons.mic),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
          }
        });
  }

  // Future showCongratulatoryDialog(BuildContext context) async {
  //   await AssetsAudioPlayer.withId(widget.recName.toString()).open(
  //     Audio.file(await congratulateAudioPath),
  //     autoStart: true,
  //     showNotification: false,
  //   );
  //
  //   return showPlatformDialog(context);
  // }

  Future<String> _getCongratulateAudioPath() async {
    final Directory? directory = await getExternalStorageDirectory();
    final String dirPath = '${directory!.path}/download';
    final String filePath = '${directory.path}/download/congratulation.mp3';
    bool isDirectoryExist = await Directory(dirPath).exists();
    if (!isDirectoryExist) {
      Directory(dirPath).create();
    }
    bool isFileExist = await File(filePath).exists();
    if (!isFileExist) {
      await downloadAudio();
    }
    return filePath;
  }

  Future<void> downloadAudio() async {
    Response response;
    final Directory? directory = await getExternalStorageDirectory();
    final String dirPath = '${directory!.path}/download/congratulation.mp3';
    response = await dio.download(
      "https://bass-equipped-crane.ngrok-free.app/download",
      dirPath,
    );

    if (response.statusCode == 200) {
      print('Audio downloaded successfully.');
    } else {
      print('Failed to download audio. Status code: ${response.statusCode}');
    }
  }

  Future<void> _startRecording(String fileName) async {
    setState(() {
      record = AudioRecorder();
    });
    final Directory? directory = await getExternalStorageDirectory();
    final String dirPath = '${directory!.path}/Submission';
    final String filePath = '${directory.path}/Submission/$fileName.m4a';
    if (await record.hasPermission()) {
      bool isDirectoryCreated = await Directory(dirPath).exists();
      if (!isDirectoryCreated) {
        Directory(dirPath).create().then((Directory directory) {
          print(directory.path);
        });
      }
      // Start recording to file
      await record.start(const RecordConfig(), path: filePath);
      setState(() {
        _isRecording = true;
      });
    }
  }

  Future<void> _stopRecording(String lessonId, context) async {
    setState(() {
      _isLoading = true;
    });
    final path = await record.stop();
    record.dispose();

    await Future.delayed(const Duration(seconds: 2));
    String answer = await _uploadAudio(File(path!), context);
    Map<String, Map<String, String>> map = await getMapFromSP('Recordings');

    if (map[lessonId]!['lessonTran']! == answer) {
      String answerStatus = 'Correct';
      map[lessonId]!["answerStatus"] = answerStatus;
      saveMaptoSP(map, 'Recordings');
    } else {
      String answerStatus = 'Wrong';
      map[lessonId]!["answerStatus"] = answerStatus;
      saveMaptoSP(map, 'Recordings');
    }

    setState(() {
      _isRecording = false;
      _isLoading = false;
      futureData = fetchData(widget.recName);
    });
  }

  Future<String> _uploadAudio(File file, context) async {
    final request = http.MultipartRequest('POST', Uri.https('bass-equipped-crane.ngrok-free.app', '/upload'));
    String filename = file.path.split('/').last;
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
    return transcript;
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

  Future<Map<String, String>?> fetchData(String recName) async {
    Map<String, Map<String, String>> fetchData = await getMapFromSP('Recordings');
    return fetchData[recName];
  }
}
