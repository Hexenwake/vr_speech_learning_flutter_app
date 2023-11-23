import 'package:flutter/material.dart';

import 'util/helper.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late Future<Map<String, Map<String, String>>> reportData;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    reportData = fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 15.0, right: 6.0, left: 6.0),
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
          child: FutureBuilder(
              future: reportData,
              builder: (BuildContext context, AsyncSnapshot<Map<String, Map<String, String>>> snapshot) {
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

                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          const Row(
                            children: [
                              Expanded(flex: 6, child: Text('Nama Topic')),
                              Expanded(flex: 1, child: Text('|')),
                              Expanded(flex: 3, child: Text('Status')),
                            ],
                          ),
                          const Divider(thickness: 2, color: Color(0xFF1C1C1C)),
                          ListView.builder(
                            shrinkWrap: true,
                            reverse: false,
                            itemCount: data.length,
                            itemBuilder: (context, int index) {
                              var key = keysList[index];
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        flex: 6,
                                        child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: Text(
                                              data[key]['lessonName'],
                                              // style: TextStyle(color: Colors.black),
                                            )),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: Container(
                                            alignment: Alignment.centerLeft,
                                            child: const Text(
                                              '|',
                                              // style: TextStyle(color: Colors.black),
                                            )),
                                      ),
                                      Expanded(
                                          flex: 3,
                                          child: Container(alignment: Alignment.centerLeft, child: Text(data[key]['task_report'] ?? 'Not Taken'))),
                                    ],
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    );
                }
              }),
        ),
      ),
    );
  }

  Future<Map<String, Map<String, String>>> fetchData() async {
    var fetchedData = await HelperFunc.getMapFromSP('Recordings');
    return fetchedData;
  }
}
