import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:vr_speech_learning/ReportPage.dart';

import 'add_lesson_dialog.dart';
import 'util/helper.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({Key? key}) : super(key: key);

  @override
  State<TeacherPage> createState() => _TeacherPage();
}

class _TeacherPage extends State<TeacherPage> {
  bool _isRecording = false;
  AudioRecorder record = AudioRecorder();
  Future<Map<String, Map<String, String>>>? future2;

  @override
  void initState() {
    super.initState();
    future2 = fetchTranscript();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Add Your Lesson Here',
        ),
        actions: [
          PopupMenuButton(onSelected: (result) {
            if (result == 0) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReportPage()));
            }
          }, itemBuilder: (BuildContext context) {
            return [const PopupMenuItem(value: 0, child: Text('Report'))];
          })
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: FutureBuilder(
            future: future2,
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
                          border: Border.all(color: Color(0xFF1C1C1C), width: 2.0, style: BorderStyle.solid),
                          borderRadius: BorderRadius.circular(10.0),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0xFF1C1C1C),
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
                        child: ExpansionTile(
                          title: Text(data[key]["lessonName"]),
                          subtitle: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Description: ${data[key]["lessonDesc"]}'),
                            ],
                          ),
                          trailing: const Icon(
                            Icons.arrow_drop_down,
                          ),
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Divider(thickness: 4, color: Colors.black),
                                Container(
                                  margin: const EdgeInsets.only(bottom: 15.0, right: 5.0, left: 5.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                          flex: 6,
                                          child: Column(
                                            children: [
                                              Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: Text(data[key]['path'] == null ? 'No Recording Yet' : 'Play ${data[key]['lessonName']}')),
                                              Container(
                                                  alignment: Alignment.centerLeft,
                                                  child: data[key]['lessonTran'] == null ? const Text('') : Text(data[key]['lessonTran']))
                                            ],
                                          )),
                                      Expanded(
                                        flex: 4,
                                        child: Container(
                                          alignment: Alignment.centerRight,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              data[key]['path'] == null
                                                  ? const SizedBox(
                                                      height: 30,
                                                      width: 30,
                                                    )
                                                  : SizedBox(
                                                      height: 30,
                                                      width: 30,
                                                      child: FloatingActionButton(
                                                        onPressed: () {
                                                          _uploadAudio(File(data[key]['path']), data[key]['lessonId'], context);
                                                        },
                                                        child: const Icon(Icons.upload),
                                                      ),
                                                    ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              AssetsAudioPlayer.withId(index.toString()).builderIsPlaying(builder: (context, isPlaying) {
                                                return data[key]['path'] == null
                                                    ? const SizedBox(
                                                        height: 30,
                                                        width: 30,
                                                      )
                                                    : SizedBox(
                                                        height: 30,
                                                        width: 30,
                                                        child: FloatingActionButton(
                                                          onPressed: () {
                                                            isPlaying
                                                                ? AssetsAudioPlayer.withId(index.toString()).pause()
                                                                : AssetsAudioPlayer.withId(index.toString()).open(
                                                                    Audio.file(data[key]['path']),
                                                                    autoStart: true,
                                                                    showNotification: false,
                                                                  );
                                                          },
                                                          child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
                                                        ),
                                                      );
                                              }),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              SizedBox(
                                                height: 30,
                                                width: 30,
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    if (_isRecording) {
                                                      _stopRecording(key);
                                                    } else {
                                                      _startRecording(key);
                                                    }
                                                  },
                                                  child: Icon(_isRecording ? Icons.stop : Icons.mic),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const Divider(thickness: 4, color: Colors.black),
                                data[key]['imgPath'] == null
                                    ? Column(
                                        children: [
                                          FloatingActionButton(
                                            onPressed: () {
                                              _showImageSourceDialog(key);
                                            },
                                            child: const Icon(Icons.add),
                                          ),
                                          const Text('Add Photos'),
                                        ],
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8.0),
                                            child: Image.file(
                                              File(data[key]['imgPath']),
                                              fit: BoxFit.fill,
                                              height: 150.0,
                                              width: 120.0,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5,
                                          ),
                                          Column(
                                            children: [
                                              SizedBox(
                                                height: 30,
                                                width: 30,
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    _showImageSourceDialog(key);
                                                  },
                                                  child: const Icon(Icons.edit),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              SizedBox(
                                                height: 30,
                                                width: 30,
                                                child: FloatingActionButton(
                                                  onPressed: () {
                                                    _deletePhoto(key);
                                                  },
                                                  child: const Icon(Icons.delete),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                Container(
                                  padding: const EdgeInsets.all(5),
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all(Colors.red)),
                                    child: const Text(
                                      'Delete Lesson',
                                    ),
                                    onPressed: () {
                                      _deleteLesson(data[key]['lessonId']);
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
              }
            }),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddLessonDialog()),
          );

          setState(() {
            future2 = fetchTranscript();
          });
        },
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: const Color(0xFF1f5c70),
          child: Row(
            children: <Widget>[
              PopupMenuButton(onSelected: (result) {
                if (result == 0) {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => ReportPage()));
                }
              }, itemBuilder: (BuildContext context) {
                return [const PopupMenuItem(value: 0, child: Text('Report'))];
              })
            ],
          )),
    );
  }

  Future<void> _startRecording(String fileName) async {
    setState(() {
      record = AudioRecorder();
    });
    final Directory? directory = await getExternalStorageDirectory();
    final String dirPath = '${directory!.path}/Recordings';
    final String filePath = '${directory.path}/Recordings/$fileName.m4a';
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

  Future<void> _stopRecording(String lessonId) async {
    final path = await record.stop();
    Map<String, Map<String, String>> map = await HelperFunc.getMapFromSP('Recordings');
    map[lessonId]!["path"] = path!;

    HelperFunc.saveMaptoSP(map, 'Recordings');

    setState(() {
      _isRecording = false;
      future2 = fetchTranscript();
      record.dispose();
    });
  }

  Future<void> _showImageSourceDialog(String lessonId) async {
    bool isCamera = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text("Camera"),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Gallery"),
            ),
          ],
        ),
      ),
    );

    if (isCamera) {
      _addImage(ImageSource.camera, lessonId);
    } else {
      _addImage(ImageSource.gallery, lessonId);
    }
  }

  Future<void> _addImage(ImageSource source, String lessonId) async {
    XFile? pickedFile = await ImagePicker().pickImage(
      source: source,
      maxHeight: 200,
      maxWidth: 200,
    );

    if (pickedFile != null) {
      Map<String, Map<String, String>> map = await HelperFunc.getMapFromSP('Recordings');
      map[lessonId]!["imgPath"] = pickedFile.path;
      HelperFunc.saveMaptoSP(map, 'Recordings');

      setState(() {
        future2 = fetchTranscript();
      });
    }
  }

  Future<void> _deletePhoto(String lessonId) async {
    Map<String, Map<String, String>> map = await HelperFunc.getMapFromSP('Recordings');
    map[lessonId]!.remove('imgPath');
    HelperFunc.saveMaptoSP(map, 'Recordings');

    setState(() {
      future2 = fetchTranscript();
    });
  }

  Future<void> _deleteLesson(String lessonId) async {
    Map<String, Map<String, String>> map = await HelperFunc.getMapFromSP('Recordings');
    _deleteRecording(map[lessonId]!['path']);
    map.remove(lessonId);
    HelperFunc.saveMaptoSP(map, 'Recordings');

    setState(() {
      future2 = fetchTranscript();
    });
  }

  Future<void> _deleteRecording(String? path) async {
    final file = File(path!);

    if (await file.exists()) {
      await file.delete();
    } else {
      print('File does not exist');
    }
  }

  Future<void> _uploadAudio(File file, String lessonId, context) async {
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
    Map<String, Map<String, String>> map = await HelperFunc.getMapFromSP('Recordings');
    map[lessonId]!['lessonTran'] = transcript;
    await HelperFunc.saveMaptoSP(map, 'Recordings');
    setState(() {
      future2 = fetchTranscript();
    });
    // print(transcript);
  }

  Future<List<String>> getUsersRecordings() async {
    Directory? directory = await getExternalStorageDirectory();
    final String dirPath = '${directory!.path}/Recordings';
    final myDir = Directory(dirPath);
    if (await myDir.exists() == false) {
      myDir.create();
    }
    List<FileSystemEntity> recordings = myDir.listSync();
    List<String> recordString = recordings.map((recordings) => recordings.path).toList();
    return recordString;
  }

  Future<Map<String, Map<String, String>>> fetchTranscript() async {
    Map<String, Map<String, String>> fetchData = await HelperFunc.getMapFromSP('Recordings');
    return fetchData;
  }
}
