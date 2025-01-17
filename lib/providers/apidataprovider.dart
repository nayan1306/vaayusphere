import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vaayusphere/Api/fetchaqi.dart';
import 'package:vaayusphere/Api/fetchweather.dart';

class ApiDataProvider with ChangeNotifier {
  // Air quality and weather data
  Map<String, dynamic>? _airQualityData;
  Map<String, dynamic>? _airQualityDataDetailed;
  Map<String, dynamic>? _weatherForecastData;
  Map<String, dynamic>? _weatherForecastDataDetailed;

  Map<String, dynamic>? get airQualityData => _airQualityData;
  Map<String, dynamic>? get airQualityDataDetailed => _airQualityDataDetailed;
  Map<String, dynamic>? get weatherForecastData => _weatherForecastData;
  Map<String, dynamic>? get weatherForecastDataDetailed =>
      _weatherForecastDataDetailed;

  // Location data
  Position? _currentLocation;

  Position? get currentLocation => _currentLocation;

  ApiDataProvider() {
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        log("Location services are disabled.");
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          log("Location permissions are denied.");
          return;
        }
      }

      _currentLocation = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      notifyListeners();
    } catch (error) {
      log("Error fetching location: $error");
    }
  }

  Future<void> updateLocation(double latitude, double longitude) async {
    _currentLocation = Position(
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      altitude: 0.0,
      accuracy: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      headingAccuracy: 0.0,
    );

    // Fetch new data based on the updated location
    await fetchAndSetAirQualityData();
    await fetchAndSetAirQualityDataDetailed();
    await fetchAndSetWeatherForecastData();
    await fetchAndSetWeatherForecastDataDetailed();

    notifyListeners(); // Notify listeners that the location has been updated
  }

  Future<void> fetchAndSetAirQualityData() async {
    try {
      if (_currentLocation == null) {
        log("Cannot fetch air quality data without location.");
        return;
      }
      _airQualityData = await fetchAirQualityData(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
      );
      notifyListeners(); // Notify listeners when data changes
    } catch (error) {
      log("Error fetching air quality data: $error");
    }
  }

  Future<void> fetchAndSetAirQualityDataDetailed() async {
    try {
      if (_currentLocation == null) {
        log("Cannot fetch air quality data without location.");
        return;
      }
      _airQualityDataDetailed = await fetchAirQualityDataDetailed(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
      );
      notifyListeners(); // Notify listeners when data changes
    } catch (error) {
      log("Error fetching air quality data: $error");
    }
  }

  Future<void> fetchAndSetWeatherForecastData() async {
    try {
      if (_currentLocation == null) {
        log("Cannot fetch weather forecast data without location.");
        return;
      }
      _weatherForecastData = await fetchWeatherData(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
      );
      notifyListeners(); // Notify listeners when data changes
    } catch (error) {
      log("Error fetching weather forecast data: $error");
    }
  }

  Future<void> fetchAndSetWeatherForecastDataDetailed() async {
    if (_currentLocation == null) {
      log("Cannot fetch weather forecast data without location.");
      return;
    }
    try {
      _weatherForecastDataDetailed = await fetchWeatherDataDetailed(
        latitude: _currentLocation!.latitude,
        longitude: _currentLocation!.longitude,
      );
      notifyListeners(); // Notify listeners when data changes
    } catch (error) {
      log("Error fetching detailed weather forecast data: $error");
    }
  }
}
