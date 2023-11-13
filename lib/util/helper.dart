import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class HelperFunc {
  static Future<void> saveStringtoSP(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value.isNotEmpty && key.isNotEmpty) {
      prefs.setString(key, value);
    }
  }

  static Future<String> getStringFromSP(String key) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? value = prefs.getString(key);
    print(value);
    if (key.isEmpty || value == null) {
      return '';
    }
    return value;
  }

  static Future<void> saveMaptoSP(Map<String, Map<String, String>> map, String key) async {
    String jsonString = jsonEncode(map);
    await saveStringtoSP(key, jsonString);
  }

  static Future<Map<String, Map<String, String>>> getMapFromSP(String key) async {
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
}
