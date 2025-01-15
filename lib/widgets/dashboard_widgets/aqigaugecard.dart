import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';
import 'package:vaayusphere/widgets/dashboard_widgets/glasscard.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';

class AqiGaugeCard extends StatelessWidget {
  const AqiGaugeCard({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the air quality data from the provider
    final airQualityData = Provider.of<ApiDataProvider>(context).airQualityData;

    // Function to determine AQI status
    String getAqiStatus(double aqiValue) {
      if (aqiValue <= 50) {
        return "Good";
      } else if (aqiValue <= 100) {
        return "Moderate";
      } else if (aqiValue <= 150) {
        return "Unhealthy for Sensitive Groups";
      } else if (aqiValue <= 200) {
        return "Unhealthy";
      } else if (aqiValue <= 300) {
        return "Very Unhealthy";
      } else {
        return "Hazardous";
      }
    }

    // Function to determine AQI status emoji
    String getAqiEmoji(double aqiValue) {
      if (aqiValue <= 50) {
        return "🌱"; // Good
      } else if (aqiValue <= 100) {
        return "🍃"; // Moderate
      } else if (aqiValue <= 150) {
        return "😷"; // Unhealthy for Sensitive Groups
      } else if (aqiValue <= 200) {
        return "😷😷"; // Unhealthy
      } else if (aqiValue <= 300) {
        return "💀"; // Very Unhealthy
      } else {
        return "☠️"; // Hazardous
      }
    }

    // Function to get AQI status color
    Color getAqiColor(double aqiValue) {
      if (aqiValue <= 50) {
        return Colors.green;
      } else if (aqiValue <= 100) {
        return Colors.yellow;
      } else if (aqiValue <= 150) {
        return Colors.orange;
      } else if (aqiValue <= 200) {
        return Colors.red;
      } else if (aqiValue <= 300) {
        return Colors.purple;
      } else {
        return Colors.brown;
      }
    }

    return SizedBox(
      width: 600,
      height: 200, // Set height to 200 as per your requirement
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // AQI value display
            airQualityData != null
                ? Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            getAqiEmoji(double.parse(
                              airQualityData['hourly']['european_aqi_pm10'][0]
                                  .toString(),
                            )),
                            style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(
                            width: 20,
                          ),
                          Text(
                            airQualityData['hourly']['european_aqi_pm10'][0]
                                .toString(),
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                              color: getAqiColor(double.parse(
                                airQualityData['hourly']['european_aqi_pm10'][0]
                                    .toString(),
                              )),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                getAqiStatus(double.parse(
                                  airQualityData['hourly']['european_aqi_pm10']
                                          [0]
                                      .toString(),
                                )),
                                style: TextStyle(
                                  fontSize: 25,
                                  fontWeight: FontWeight.w500,
                                  color: getAqiColor(double.parse(
                                    airQualityData['hourly']
                                            ['european_aqi_pm10'][0]
                                        .toString(),
                                  )),
                                ),
                              ),
                              const Text(
                                "PM 10 (µg/m³)",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          // Label for AQI
                          // const Text(
                          //   "AQI (PM10)",
                          //   style: TextStyle(
                          //     fontSize: 16,
                          //     color: Colors.white70,
                          //   ),
                          // ),
                        ],
                      ),
                    ],
                  )
                : Image.asset(
                    "./assets/gifs/air.gif",
                    width: 150,
                  ),

            const SizedBox(height: 20),

            // Linear Gauge with color coding for different AQI ranges
            airQualityData != null
                ? LinearGauge(
                    gaugeOrientation: GaugeOrientation.horizontal,
                    enableGaugeAnimation: true,
                    rulers: RulerStyle(
                      rulerPosition: RulerPosition.bottom,
                    ),
                    end: 500,
                    linearGaugeBoxDecoration:
                        const LinearGaugeBoxDecoration(thickness: 20),
                    rangeLinearGauge: [
                      // Color coding based on AQI value ranges
                      RangeLinearGauge(
                        start: 0,
                        end: 50,
                        color: Colors.green,
                      ),
                      RangeLinearGauge(
                        start: 51,
                        end: 100,
                        color: Colors.yellow,
                      ),
                      RangeLinearGauge(
                        start: 101,
                        end: 150,
                        color: Colors.orange,
                      ),
                      RangeLinearGauge(
                        start: 151,
                        end: 200,
                        color: Colors.red,
                      ),
                      RangeLinearGauge(
                        start: 201,
                        end: 300,
                        color: const Color.fromARGB(255, 107, 26, 121),
                      ),
                      RangeLinearGauge(
                        start: 301,
                        end: 500,
                        color: const Color.fromARGB(255, 84, 42, 27),
                      ),
                    ],
                    pointers: [
                      Pointer(
                        value: double.parse(
                          airQualityData['hourly']['european_aqi_pm10'][0]
                              .toString(),
                        ),
                        shape: PointerShape.triangle,
                        color: const Color.fromARGB(255, 255, 166, 166),
                        width: 20,
                        pointerPosition: PointerPosition.top,
                      ),
                    ],
                  )
                : const SizedBox(), // Empty size if data is null
          ],
        ),
      ),
    );
  }
}
