import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchAirQualityData({
  required double latitude,
  required double longitude,
}) async {
  final url =
      'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$latitude&longitude=$longitude&hourly=pm10,pm2_5,nitrogen_dioxide,sulphur_dioxide,us_aqi&timezone=GMT&forecast_days=1';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Decode the JSON response
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load air quality data. HTTP Status: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error fetching air quality data: $error');
  }
}

Future<Map<String, dynamic>> fetchAirQualityDataDetailed({
  required double latitude,
  required double longitude,
}) async {
  final url =
      'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=$latitude&longitude=$longitude&hourly=pm10,pm2_5,carbon_monoxide,carbon_dioxide,nitrogen_dioxide,sulphur_dioxide,ozone,uv_index,uv_index_clear_sky,ammonia,methane,european_aqi_pm2_5,us_aqi&timezone=auto&past_days=7';

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Decode the JSON response
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load air quality data. HTTP Status: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error fetching air quality data: $error');
  }
}
