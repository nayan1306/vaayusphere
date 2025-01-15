import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';

class ImageAsPerWeatherCode extends StatelessWidget {
  const ImageAsPerWeatherCode({super.key});

  get isday => null;

  @override
  Widget build(BuildContext context) {
    // Access the air quality data from the provider
    final weatherForecastData =
        Provider.of<ApiDataProvider>(context).weatherForecastData;

    // Get the weather code from the data (ensure it matches your API structure)
    final weatherCode = weatherForecastData?['daily']['weather_code']?[0];
    final isday = weatherForecastData?['hourly']['is_day'][0];

    return SizedBox(
      width: 250,
      height: 250,
      child: weatherCode != null
          ? Image.network(
              _getWeatherImageUrl(weatherCode, isday),
              width: 150,
              height: 150,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return const CircularProgressIndicator();
              },
              errorBuilder: (context, error, stackTrace) {
                return Text("$isday$weatherCode");
              },
            )
          : const CircularProgressIndicator(), // Loader while data is being fetched
    );
  }

  /// Maps weather codes to corresponding network image URLs
  String _getWeatherImageUrl(int code, int isday) {
    const baseUrl =
        "https://raw.githubusercontent.com/nayan1306/assets/main/Icons"; // Updated base URL to raw content
    if (code == 0 && isday == 1) {
      return "$baseUrl/sun.png";
    } else if (code == 0 && isday == 0) {
      return "$baseUrl/clearMoon.png";
    } else if ([1, 2, 3].contains(code) && isday == 0) {
      return "$baseUrl/cloudyMoon.png";
    } else if ([1, 2, 3].contains(code) && isday == 1) {
      return "$baseUrl/cloudy.png";
    } else if ([45, 48].contains(code)) {
      return "$baseUrl/superCloudyMoon.png";
    } else if ([51, 53, 55].contains(code)) {
      return "$baseUrl/raining.png";
    } else if ([56, 57].contains(code)) {
      return "$baseUrl/raining.png";
    } else if ([61, 63, 65].contains(code)) {
      return "$baseUrl/raining.png";
    } else if ([66, 67].contains(code)) {
      return "$baseUrl/raining.png";
    } else if ([71, 73, 75].contains(code)) {
      return "$baseUrl/raining.png";
    } else if (code == 77) {
      return "$baseUrl/raining.png";
    } else if ([80, 81, 82].contains(code)) {
      return "$baseUrl/raining.png";
    } else if ([85, 86].contains(code)) {
      return "$baseUrl/raining.png";
    } else if (code == 95) {
      return "$baseUrl/thunderStorm.png";
    } else if ([96, 99].contains(code)) {
      return "$baseUrl/thunderStorm.png";
    } else {
      return "$baseUrl/coldNight.png"; // Fallback image URL
    }
  }
}
