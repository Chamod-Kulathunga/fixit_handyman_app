import 'dart:convert';

import 'package:flutter/services.dart';

class LocalDataService {
  static const String _providersPath = 'assets/data/providers.json';

  Future<Map<String, dynamic>> loadProvidersData() async {
    final jsonString = await rootBundle.loadString(_providersPath);

    final decodedData = jsonDecode(jsonString);

    if (decodedData is! Map<String, dynamic>) {
      throw const FormatException('Invalid providers JSON format.');
    }

    return decodedData;
  }
}
