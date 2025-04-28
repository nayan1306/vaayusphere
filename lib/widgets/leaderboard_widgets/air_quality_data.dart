import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// Models for air pollution data
class AirQualityData {
  final String city;
  final String country;
  final double aqi;
  final String status;

  AirQualityData({
    required this.city,
    required this.country,
    required this.aqi,
    required this.status,
  });

  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    return AirQualityData(
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      aqi: (json['aqi'] is int)
          ? (json['aqi'] as int).toDouble()
          : (json['aqi'] is double)
              ? json['aqi']
              : 0.0,
      status: getAqiStatus((json['aqi'] is int)
          ? (json['aqi'] as int).toDouble()
          : (json['aqi'] is double)
              ? json['aqi']
              : 0.0),
    );
  }

  static String getAqiStatus(double aqi) {
    if (aqi <= 50) return 'Good';
    if (aqi <= 100) return 'Moderate';
    if (aqi <= 150) return 'Unhealthy for Sensitive Groups';
    if (aqi <= 200) return 'Unhealthy';
    if (aqi <= 300) return 'Very Unhealthy';
    return 'Hazardous';
  }

  static Color getAqiColor(double aqi) {
    if (aqi <= 50) return Colors.green;
    if (aqi <= 100) return const Color.fromARGB(255, 204, 184, 0);
    if (aqi <= 150) return Colors.orange;
    if (aqi <= 200) return Colors.red;
    if (aqi <= 300) return Colors.purple;
    return Colors.brown;
  }
}

class AirQualityService {
  // Option to use mock data if API fails
  static bool useMockData = true;

  // OpenAQ API - Free public API for air quality data
  static const String baseUrl = 'https://api.openaq.org/v2';

  // Get most polluted cities
  static Future<List<AirQualityData>> getMostPollutedCities() async {
    if (useMockData) {
      return _getMockCitiesData();
    }

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/locations?limit=50&page=1&sort=desc&order_by=lastValue'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        List<AirQualityData> cities = [];

        for (var item in results) {
          // Extract necessary info from OpenAQ response
          if (item['parameters'] != null && item['parameters'].isNotEmpty) {
            var pm25Param = (item['parameters'] as List).firstWhere(
                (param) => param['parameter'] == 'pm25',
                orElse: () => null);

            if (pm25Param != null && pm25Param['lastValue'] != null) {
              cities.add(AirQualityData(
                city: item['name'] ?? '',
                country: item['country'] ?? '',
                aqi: pm25Param['lastValue'].toDouble(),
                status: AirQualityData.getAqiStatus(
                    pm25Param['lastValue'].toDouble()),
              ));
            }
          }
        }

        // Sort by AQI (highest first)
        cities.sort((a, b) => b.aqi.compareTo(a.aqi));
        return cities;
      } else {
        throw Exception(
            'Failed to load pollution data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching pollution data: $e');
      return _getMockCitiesData(); // Return mock data on error
    }
  }

  // Get countries ordered by pollution level
  static Future<List<AirQualityData>> getCountriesByPollution() async {
    if (useMockData) {
      return _getMockCountriesData();
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/countries?limit=100&page=1'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] as List;

        // First get country names
        List<String> countryNames =
            results.map((item) => item['name'] as String).toList();

        // Now get average AQI for each country
        List<AirQualityData> countries = [];

        for (var country in countryNames) {
          final countryDataResponse = await http.get(
            Uri.parse(
                '$baseUrl/measurements?country=$country&parameter=pm25&limit=1&sort=desc'),
            headers: {'Accept': 'application/json'},
          );

          if (countryDataResponse.statusCode == 200) {
            final countryData = json.decode(countryDataResponse.body);
            final countryResults = countryData['results'] as List;

            if (countryResults.isNotEmpty &&
                countryResults[0]['value'] != null) {
              double aqi = countryResults[0]['value'].toDouble();
              countries.add(AirQualityData(
                city: '',
                country: country,
                aqi: aqi,
                status: AirQualityData.getAqiStatus(aqi),
              ));
            }
          }
        }

        // Sort by AQI (highest first)
        countries.sort((a, b) => b.aqi.compareTo(a.aqi));
        return countries;
      } else {
        throw Exception('Failed to load country data: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching country data: $e');
      return _getMockCountriesData(); // Return mock data on error
    }
  }

  // Mock data for cities
  static List<AirQualityData> _getMockCitiesData() {
    return [
      AirQualityData(
          city: 'Delhi',
          country: 'India',
          aqi: 187.0,
          status: AirQualityData.getAqiStatus(187.0)),
      AirQualityData(
          city: 'Lahore',
          country: 'Pakistan',
          aqi: 175.0,
          status: AirQualityData.getAqiStatus(175.0)),
      AirQualityData(
          city: 'Dhaka',
          country: 'Bangladesh',
          aqi: 163.0,
          status: AirQualityData.getAqiStatus(163.0)),
      AirQualityData(
          city: 'Beijing',
          country: 'China',
          aqi: 154.0,
          status: AirQualityData.getAqiStatus(154.0)),
      AirQualityData(
          city: 'Mumbai',
          country: 'India',
          aqi: 144.0,
          status: AirQualityData.getAqiStatus(144.0)),
      AirQualityData(
          city: 'Jakarta',
          country: 'Indonesia',
          aqi: 135.0,
          status: AirQualityData.getAqiStatus(135.0)),
      AirQualityData(
          city: 'Shanghai',
          country: 'China',
          aqi: 127.0,
          status: AirQualityData.getAqiStatus(127.0)),
      AirQualityData(
          city: 'Karachi',
          country: 'Pakistan',
          aqi: 124.0,
          status: AirQualityData.getAqiStatus(124.0)),
      AirQualityData(
          city: 'Kolkata',
          country: 'India',
          aqi: 119.0,
          status: AirQualityData.getAqiStatus(119.0)),
      AirQualityData(
          city: 'Bangkok',
          country: 'Thailand',
          aqi: 108.0,
          status: AirQualityData.getAqiStatus(108.0)),
      AirQualityData(
          city: 'Mexico City',
          country: 'Mexico',
          aqi: 103.0,
          status: AirQualityData.getAqiStatus(103.0)),
      AirQualityData(
          city: 'Seoul',
          country: 'South Korea',
          aqi: 98.0,
          status: AirQualityData.getAqiStatus(98.0)),
      AirQualityData(
          city: 'Los Angeles',
          country: 'United States',
          aqi: 87.0,
          status: AirQualityData.getAqiStatus(87.0)),
      AirQualityData(
          city: 'Cairo',
          country: 'Egypt',
          aqi: 83.0,
          status: AirQualityData.getAqiStatus(83.0)),
      AirQualityData(
          city: 'Paris',
          country: 'France',
          aqi: 62.0,
          status: AirQualityData.getAqiStatus(62.0)),
      AirQualityData(
          city: 'London',
          country: 'United Kingdom',
          aqi: 48.0,
          status: AirQualityData.getAqiStatus(48.0)),
      AirQualityData(
          city: 'Berlin',
          country: 'Germany',
          aqi: 43.0,
          status: AirQualityData.getAqiStatus(43.0)),
      AirQualityData(
          city: 'Sydney',
          country: 'Australia',
          aqi: 32.0,
          status: AirQualityData.getAqiStatus(32.0)),
      AirQualityData(
          city: 'Auckland',
          country: 'New Zealand',
          aqi: 21.0,
          status: AirQualityData.getAqiStatus(21.0)),
      AirQualityData(
          city: 'Helsinki',
          country: 'Finland',
          aqi: 18.0,
          status: AirQualityData.getAqiStatus(18.0)),
    ];
  }

  // Mock data for countries
  static List<AirQualityData> _getMockCountriesData() {
    return [
      AirQualityData(
          city: '',
          country: 'India',
          aqi: 156.0,
          status: AirQualityData.getAqiStatus(156.0)),
      AirQualityData(
          city: '',
          country: 'China',
          aqi: 151.0,
          status: AirQualityData.getAqiStatus(151.0)),
      AirQualityData(
          city: '',
          country: 'Pakistan',
          aqi: 139.0,
          status: AirQualityData.getAqiStatus(139.0)),
      AirQualityData(
          city: '',
          country: 'Bangladesh',
          aqi: 137.0,
          status: AirQualityData.getAqiStatus(137.0)),
      AirQualityData(
          city: '',
          country: 'Indonesia',
          aqi: 112.0,
          status: AirQualityData.getAqiStatus(112.0)),
      AirQualityData(
          city: '',
          country: 'Vietnam',
          aqi: 103.0,
          status: AirQualityData.getAqiStatus(103.0)),
      AirQualityData(
          city: '',
          country: 'Thailand',
          aqi: 98.0,
          status: AirQualityData.getAqiStatus(98.0)),
      AirQualityData(
          city: '',
          country: 'Mexico',
          aqi: 94.0,
          status: AirQualityData.getAqiStatus(94.0)),
      AirQualityData(
          city: '',
          country: 'Iran',
          aqi: 91.0,
          status: AirQualityData.getAqiStatus(91.0)),
      AirQualityData(
          city: '',
          country: 'United States',
          aqi: 88.0,
          status: AirQualityData.getAqiStatus(88.0)),
      AirQualityData(
          city: '',
          country: 'Brazil',
          aqi: 83.0,
          status: AirQualityData.getAqiStatus(83.0)),
      AirQualityData(
          city: '',
          country: 'Nigeria',
          aqi: 79.0,
          status: AirQualityData.getAqiStatus(79.0)),
      AirQualityData(
          city: '',
          country: 'Japan',
          aqi: 76.0,
          status: AirQualityData.getAqiStatus(76.0)),
      AirQualityData(
          city: '',
          country: 'Egypt',
          aqi: 73.0,
          status: AirQualityData.getAqiStatus(73.0)),
      AirQualityData(
          city: '',
          country: 'Germany',
          aqi: 65.0,
          status: AirQualityData.getAqiStatus(65.0)),
      AirQualityData(
          city: '',
          country: 'United Kingdom',
          aqi: 61.0,
          status: AirQualityData.getAqiStatus(61.0)),
      AirQualityData(
          city: '',
          country: 'France',
          aqi: 59.0,
          status: AirQualityData.getAqiStatus(59.0)),
      AirQualityData(
          city: '',
          country: 'Italy',
          aqi: 57.0,
          status: AirQualityData.getAqiStatus(57.0)),
      AirQualityData(
          city: '',
          country: 'Canada',
          aqi: 47.0,
          status: AirQualityData.getAqiStatus(47.0)),
      AirQualityData(
          city: '',
          country: 'Australia',
          aqi: 38.0,
          status: AirQualityData.getAqiStatus(38.0)),
      AirQualityData(
          city: '',
          country: 'Sweden',
          aqi: 29.0,
          status: AirQualityData.getAqiStatus(29.0)),
      AirQualityData(
          city: '',
          country: 'New Zealand',
          aqi: 21.0,
          status: AirQualityData.getAqiStatus(21.0)),
      AirQualityData(
          city: '',
          country: 'Finland',
          aqi: 18.0,
          status: AirQualityData.getAqiStatus(18.0)),
      AirQualityData(
          city: '',
          country: 'Norway',
          aqi: 16.0,
          status: AirQualityData.getAqiStatus(16.0)),
      AirQualityData(
          city: '',
          country: 'Iceland',
          aqi: 11.0,
          status: AirQualityData.getAqiStatus(11.0)),
    ];
  }
}
