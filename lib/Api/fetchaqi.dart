import 'dart:convert';
import 'package:http/http.dart' as http;

Future<Map<String, dynamic>> fetchAirQualityData() async {
  const url =
      'https://air-quality-api.open-meteo.com/v1/air-quality?latitude=21.5386&longitude=81.9403&hourly=pm10,pm2_5,nitrogen_dioxide,sulphur_dioxide,european_aqi_pm10&timezone=GMT&forecast_days=1';

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
