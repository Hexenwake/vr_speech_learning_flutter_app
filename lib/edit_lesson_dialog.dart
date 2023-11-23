import 'package:flutter/material.dart';

import 'util/helper.dart';

class EditLessonDialog extends StatefulWidget {
  final String lessonID;
  const EditLessonDialog({super.key, required this.lessonID});

  @override
  State<EditLessonDialog> createState() => _EditLessonDialogState();
}

class _EditLessonDialogState extends State<EditLessonDialog> {
  TextEditingController taskNameController = TextEditingController();
  TextEditingController taskDescController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setValue();
  }

  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;
    return AlertDialog(
      scrollable: true,
      title: const Text(
        'Sunting Pelajaran',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.brown),
      ),
      content: SizedBox(
        height: height * 0.35,
        width: width,
        child: Form(
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: taskNameController,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'Lesson Name',
                  hintStyle: const TextStyle(fontSize: 14),
                  icon: const Icon(Icons.list_rounded, color: Colors.brown),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              TextFormField(
                controller: taskDescController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 20,
                  ),
                  hintText: 'Description',
                  hintStyle: const TextStyle(fontSize: 14),
                  icon: const Icon(Icons.bubble_chart, color: Colors.brown),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.of(context, rootNavigator: true).pop();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey,
          ),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            final lessonName = taskNameController.text;
            final lessonDesc = taskDescController.text;
            _editLesson(lessonName: lessonName, lessonDesc: lessonDesc, lessonID: widget.lessonID);
            Navigator.of(context, rootNavigator: true).pop();
          },
          child: const Text('Save'),
        ),
      ],
    );
  }

  Future _editLesson({required String lessonName, required String lessonDesc, required String lessonID}) async {
    Map<String, Map<String, String>> old = await HelperFunc.getMapFromSP('Recordings');
    old[lessonID]!['lessonDesc'] = lessonDesc;
    old[lessonID]!['lessonName'] = lessonName;
    old[lessonID]!['lessonId'] = lessonID;

    await HelperFunc.saveMaptoSP(old, 'Recordings');
    _clearAll();
  }

  Future<Map<String, String>?> _getData(String lessonID) async {
    Map<String, Map<String, String>> old = await HelperFunc.getMapFromSP('Recordings');
    return old[lessonID];
  }

  Future<void> _setValue() async {
    var data = await _getData(widget.lessonID);
    taskNameController.text = data!['lessonName']!;
    taskDescController.text = data['lessonDesc']!;
  }

  void _clearAll() {
    taskNameController.text = '';
    taskDescController.text = '';
  }
}
