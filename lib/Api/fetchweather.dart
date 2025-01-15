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
      "https://api.open-meteo.com/v1/forecast?latitude=$latitude&longitude=$longitude&hourly=temperature_2m,relative_humidity_2m,dew_point_2m,apparent_temperature,precipitation_probability,precipitation,rain,showers,weather_code,pressure_msl,surface_pressure,cloud_cover,cloud_cover_low,cloud_cover_mid,cloud_cover_high,visibility,wind_speed_10m,wind_direction_10m,soil_temperature_0cm,soil_moisture_0_to_1cm,is_day&daily=weather_code&timezone=auto&past_hours=24&forecast_hours=1";

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
