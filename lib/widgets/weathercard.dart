import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';
import 'package:vaayusphere/widgets/glasscard.dart';
import 'package:loading_indicator/loading_indicator.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the weather data from the provider
    final weatherProvider = Provider.of<ApiDataProvider>(context);
    final weatherData = weatherProvider.weatherForecastData;

    // Fetch weather data if not already fetched
    if (weatherData == null) {
      weatherProvider.fetchAndSetweatherForecastData();
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
                ? Column(
                    children: [
                      // Temperature
                      Row(
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
                                      value:
                                          loadingProgress.expectedTotalBytes !=
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
                              size: 80,
                            ),
                          const SizedBox(width: 10),
                          Text(
                            "${weatherData['hourly']['temperature_2m'][0]}°C", // Display the first temperature reading
                            style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Wind Speed
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                        mainAxisAlignment: MainAxisAlignment.center,
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
                      const SizedBox(height: 10),

                      // Precipitation Probability
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
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
                        mainAxisAlignment: MainAxisAlignment.center,
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
                      const SizedBox(height: 10),
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

                      // pathBackgroundColor: Colors.black45,
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
