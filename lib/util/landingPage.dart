import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:vr_speech_learning/homePage.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final String url = 'http://endless-beagle-honestly.ngrok-free.app';

  @override
  void initState() {
    super.initState();
    checkServerStatus();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Future<void> checkServerStatus() async {
    bool isOnline = await isServerOnline(url);

    if (isOnline) {
      if (!context.mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage()));
    } else {
      await Future.delayed(const Duration(seconds: 5));
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Server Offline'),
          content: const Text('Please try again later.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
                checkServerStatus();
              },
            ),
          ],
        ),
      );
    }
  }

  Future<bool> isServerOnline(String url) async {
    try {
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 5));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
