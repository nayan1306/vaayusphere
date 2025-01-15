import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchWeatherData({
  required double latitude,
  required double longitude,
}) async {
  final url =
      "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,visibility,wind_speed_10m,is_day&daily=weather_code&timezone=auto&past_hours=24&forecast_hours=1";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Decode the JSON response
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load weather data. HTTP Status: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error fetching weather data: $error');
  }
}

Future<Map<String, dynamic>> fetchWeatherDataDetailed({
  required double latitude,
  required double longitude,
}) async {
  final url =
      "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,relative_humidity_2m,dew_point_2m,apparent_temperature,precipitation_probability,precipitation,rain,showers&timezone=auto&past_days=7&past_hours=24&forecast_hours=1";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Decode the JSON response
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load weather data. HTTP Status: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error fetching weather data: $error');
  }
}
