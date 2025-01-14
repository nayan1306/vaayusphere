import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:vaayusphere/Api/fetchaqi.dart';
import 'package:vaayusphere/Api/fetchweather.dart';

class ApiDataProvider with ChangeNotifier {
  Map<String, dynamic>? _airQualityData;

  Map<String, dynamic>? get airQualityData => _airQualityData;

  Map<String, dynamic>? _weatherForecastData;

  Map<String, dynamic>? get weatherForecastData => _weatherForecastData;

  Future<void> fetchAndSetAirQualityData() async {
    try {
      _airQualityData = await fetchAirQualityData();
      notifyListeners(); // Notify listeners when data changes
    } catch (error) {
      log("Error fetching air quality data: $error");
    }
  }

  // weather data

  Future<void> fetchAndSetweatherForecastData() async {
    try {
      _weatherForecastData = await fetchWeatherData();
      notifyListeners(); // Notify listeners when data changes
    } catch (error) {
      log("Error fetching weather forecast data: $error");
    }
  }
}
