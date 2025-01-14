import 'dart:convert';
// import 'dart:developer';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchWeatherData() async {
  const url =
      "https://api.open-meteo.com/v1/forecast?latitude=21.2333&longitude=81.6333&hourly=temperature_2m,relative_humidity_2m,precipitation_probability,visibility,wind_speed_10m,is_day&timezone=auto&past_hours=24&forecast_hours=1";
  try {
    final response = await http.get(Uri.parse(url));
    // log("message: ${response.body}");

    if (response.statusCode == 200) {
      // Decode the JSON response
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load data');
    }
  } catch (error) {
    throw Exception('Error fetching data: $error');
  }
}
