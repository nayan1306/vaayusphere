import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/glasscard.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/weatherforecastcard.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the weather data from the provider
    final weatherProvider = Provider.of<ApiDataProvider>(context);
    final weatherData = weatherProvider.weatherForecastData;

    // Fetch weather data if not already fetched
    if (weatherData == null) {
      weatherProvider.fetchAndSetWeatherForecastData();
    }

    return SizedBox(
      width: 830,
      height: 300,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Weather Info
            weatherData != null
                ? Row(
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Temperature
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (weatherData['hourly']['is_day'][0] == 1)
                                Image.network(
                                  "https://raw.githubusercontent.com/nayan1306/assets/main/sun.png",
                                  width: 100,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) {
                                      return child;
                                    } else {
                                      return Center(
                                        child: CircularProgressIndicator(
                                          value: loadingProgress
                                                      .expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  (loadingProgress
                                                          .expectedTotalBytes ??
                                                      1)
                                              : null,
                                        ),
                                      );
                                    }
                                  },
                                )
                              else
                                const Icon(
                                  Icons.nightlight_round,
                                  color: Colors.white70,
                                  size: 100,
                                ),
                              const SizedBox(width: 10),
                              Text(
                                "${weatherData['hourly']['temperature_2m'][0]}°C", // Display the first temperature reading
                                style: const TextStyle(
                                  fontSize: 50,
                                  fontWeight: FontWeight.bold,
                                  color: Color.fromARGB(255, 255, 255, 255),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Wind Speed
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.waves,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${weatherData['hourly']['wind_speed_10m'][0]} km/h", // Display wind speed
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Humidity
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.cloud,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${weatherData['hourly']['relative_humidity_2m'][0]}%", // Display humidity
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Precipitation Probability
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.water_drop,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${weatherData['hourly']['precipitation_probability'][0]}%", // Display precipitation probability
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),

                                  // Visibility
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.visibility,
                                        color: Colors.white70,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        "${weatherData['hourly']['visibility'][0]} m", // Display visibility
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 40,
                            width: 290,
                          )
                        ],
                      ),
                      // weather forecast
                      const WeatherForecastCard()
                    ],
                  )
                : SizedBox(
                    width: 200,
                    child: LoadingIndicator(
                      colors: [
                        Colors.blue.shade100, // Light and gentle sky blue
                        Colors.blue.shade200, // Soft pastel blue
                        Colors.blue.shade300, // Calm and serene medium blue
                        Colors.blue.shade400, // Cool, peaceful azure blue
                        Colors.blue.shade500, // Subtle and deeper blue
                      ],
                      indicatorType: Indicator.lineScale,
                      strokeWidth: 3,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
