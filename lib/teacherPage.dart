import 'dart:io';

import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:vr_speech_learning/ReportPage.dart';
import 'package:vr_speech_learning/edit_lesson_dialog.dart';

import 'add_lesson_dialog.dart';
import 'util/helper.dart';

class TeacherPage extends StatefulWidget {
  const TeacherPage({super.key});

  @override
  State<TeacherPage> createState() => _TeacherPage();
}

class _TeacherPage extends State<TeacherPage> {
  bool _isRecording = false;
  bool _isLoading = false;
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
          'TOPIK PEMBELAJARAN',
        ),
        actions: [
          PopupMenuButton(onSelected: (result) {
            if (result == 0) {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ReportPage()));
            }
            // if (result == 1) {
            //   Navigator.of(context).push(MaterialPageRoute(builder: (context) => const TestPage()));
            // }
          }, itemBuilder: (BuildContext context) {
            return [
              const PopupMenuItem(value: 0, child: Text('Laporan')),
              // const PopupMenuItem(
              //   value: 1,
              //   child: Text('Test'),
              // ),
            ];
          })
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: _isLoading,
        child: Container(
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
                            border: Border.all(color: const Color(0xFF161b33), width: 5.0, style: BorderStyle.solid),
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
                          child: ExpansionTile(
                            backgroundColor: const Color(0xFFf1dac4),
                            collapsedBackgroundColor: const Color(0xFF474973),
                            collapsedTextColor: Colors.white,
                            textColor: const Color(0xff0d0c1d),
                            title: Text(data[key]["lessonName"]),
                            subtitle: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Huraian: ${data[key]["lessonDesc"]}'),
                              ],
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: FloatingActionButton(
                                    onPressed: () async {
                                      await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => EditLessonDialog(lessonID: key)),
                                      );

                                      setState(() {
                                        future2 = fetchTranscript();
                                      });
                                    },
                                    child: const Icon(Icons.edit_document),
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_drop_down,
                                ),
                              ],
                            ),
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Divider(thickness: 4, color: Color(0xFF161b33)),
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 15.0, right: 5.0, left: 5.0),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                            flex: 6,
                                            child: Column(
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: Container(
                                                      alignment: Alignment.centerLeft,
                                                      child: Text(data[key]['path'] == null ? 'Belum ada rakaman suara' : 'Rakaman sudah dibuat')),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8.0),
                                                  child: Container(
                                                      alignment: Alignment.centerLeft,
                                                      child: data[key]['lessonTran'] == null
                                                          ? const Text('')
                                                          : Text('Transkrip: ${data[key]['lessonTran']}')),
                                                )
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
                                  if (data[key]['lessonTran'] == null || data[key]['lessonTran'] == '') ...[
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.warning,
                                          color: Colors.red,
                                        ),
                                        Text(
                                          'Transkrip kosong, sila tekan upload',
                                          style: TextStyle(fontSize: 14, color: Colors.red),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const Divider(thickness: 4, color: Color(0xFF161b33)),
                                  data[key]['imgPath'] == null
                                      ? Column(
                                          children: [
                                            FloatingActionButton(
                                              onPressed: () {
                                                _showImageSourceDialog(key);
                                              },
                                              child: const Icon(Icons.add),
                                            ),
                                            const Text('Tambah Gambar'),
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
                                        'PADAM TOPIK',
                                      ),
                                      onPressed: () {
                                        _deleteLesson(data[key]['lessonId']);
                                      },
                                    ),
                                  ),
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
          color: const Color(0xFF474973),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              IconButton(
                onPressed: () {
                  setState(() {
                    future2 = fetchTranscript();
                  });
                },
                icon: const Icon(
                  Icons.refresh,
                  color: Colors.white,
                ),
              ),
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
              child: const Text("Kamera"),
            ),
            const SizedBox(
              height: 20,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text("Galeri"),
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
    setState(() {
      _isLoading = true;
    });

    final request = http.MultipartRequest('POST', Uri.https('endless-beagle-honestly.ngrok-free.app', '/upload'));
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
    var response = await http.Response.fromStream(res).timeout(const Duration(seconds: 5));
    if (response.statusCode == 200) {
      String transcript = response.body;
      Map<String, Map<String, String>> map = await HelperFunc.getMapFromSP('Recordings');
      map[lessonId]!['lessonTran'] = transcript;
      await HelperFunc.saveMaptoSP(map, 'Recordings');
      setState(() {
        future2 = fetchTranscript();
        _isLoading = false;
      });
    } else {
      await Future.delayed(const Duration(seconds: 3));
      showOfflinePopup();
    }
  }

  void showOfflinePopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Server Error'),
        content: const Text('Please try again later.'),
        actions: <Widget>[
          ElevatedButton(
            onPressed: () {
              setState(() {
                _isLoading = false;
              });
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Back'),
          ),
        ],
      ),
    );
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
