import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:vaayusphere/Api/fetchaqi.dart';

class ApiDataProvider with ChangeNotifier {
  Map<String, dynamic>? _airQualityData;

  Map<String, dynamic>? get airQualityData => _airQualityData;

  Future<void> fetchAndSetAirQualityData() async {
    try {
      _airQualityData = await fetchAirQualityData();
      notifyListeners(); // Notify listeners when data changes
    } catch (error) {
      log("Error fetching air quality data: $error");
    }
  }
}
