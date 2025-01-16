import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Import Syncfusion chart package
import 'package:vaayusphere/widgets/dashboard_widgets/glasscard.dart';
import 'package:vaayusphere/providers/apidataprovider.dart'; // Adjust import path

class Co2BarChart extends StatelessWidget {
  const Co2BarChart({super.key});

  @override
  Widget build(BuildContext context) {
    final airQualityData =
        Provider.of<ApiDataProvider>(context).airQualityDataDetailed;

    List<_AqiData> chartData = [];
    if (airQualityData != null &&
        airQualityData['hourly'] != null &&
        airQualityData['hourly']['time'] != null &&
        airQualityData['hourly']['pm10'] != null) {
      final timeData = airQualityData['hourly']['time'] as List;
      final hourlyData = airQualityData['hourly']['carbon_dioxide'] as List;

      // Create a map of AQI data by hour
      final Map<int, double> aqiMap = {};
      for (var i = 0; i < timeData.length; i++) {
        try {
          final hour = DateTime.parse(timeData[i]).hour;
          final aqi = hourlyData[i].toDouble();
          aqiMap[hour] = aqi;
        } catch (e) {
          print("Error processing data at index $i: $e");
        }
      }

      // Generate the last 24 hours
      final currentHour = DateTime.now().hour;
      for (int i = 0; i < 24; i++) {
        final hour = (currentHour - i) % 24; // Wrap around for hours
        final aqi = aqiMap[hour] ?? 0; // Default AQI is 0 if data is missing
        chartData.add(_AqiData(hour, aqi));
      }
    } else {
      print("airQualityData or required keys are missing");
    }

    // Ensure the chart data is sorted by hour
    chartData.sort((a, b) => a.hour.compareTo(b.hour));

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      height: MediaQuery.of(context).size.height * 0.3,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            chartData.isNotEmpty
                ? Expanded(
                    child: SfCartesianChart(
                      zoomPanBehavior: ZoomPanBehavior(
                        enablePinching: true,
                        enablePanning: true,
                        enableDoubleTapZooming: true,
                        enableMouseWheelZooming: true,
                        enableSelectionZooming: true,
                        zoomMode: ZoomMode.xy,
                      ),
                      tooltipBehavior: TooltipBehavior(
                        enable: true,
                        header: '',
                        format: 'Hour: point.x\nAQI: point.y µg/m³',
                      ),
                      plotAreaBorderWidth: 0.0,
                      title: const ChartTitle(
                        text: 'CO2 ppm',
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      primaryXAxis: NumericAxis(
                        title: const AxisTitle(
                          text: 'Hour',
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        labelStyle: const TextStyle(color: Colors.white70),
                        majorGridLines: const MajorGridLines(width: 0),
                        interval: 1,
                        labelRotation: 45,
                        axisLabelFormatter: (AxisLabelRenderDetails details) {
                          // Convert the hour (integer) to a 12-hour format with AM/PM
                          int hour = details.value.toInt() %
                              24; // Ensure hour is in 24-hour format
                          final String suffix = hour >= 12 ? 'PM' : 'AM';
                          hour = hour % 12 == 0
                              ? 12
                              : hour % 12; // Convert to 12-hour format
                          return ChartAxisLabel('$hour $suffix',
                              const TextStyle(color: Colors.white70));
                        },
                      ),
                      primaryYAxis: const NumericAxis(
                        title: AxisTitle(
                          text: 'CO2 ppm',
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        labelStyle: TextStyle(color: Colors.white70),
                        majorGridLines: MajorGridLines(width: 0),
                      ),
                      series: <CartesianSeries>[
                        ColumnSeries<_AqiData, int>(
                          dataSource: chartData,
                          xValueMapper: (_AqiData data, _) => data.hour,
                          yValueMapper: (_AqiData data, _) => data.aqi,
                          name: 'CO2 ppm',
                          width: 0.6,
                          color: const Color.fromARGB(255, 174, 255, 229),
                          borderRadius: BorderRadius.circular(5),
                          enableTooltip: true,
                        ),
                      ],
                      backgroundColor: Colors.transparent,
                      borderColor: Colors.transparent,
                    ),
                  )
                : Image.asset(
                    "./assets/gifs/air.gif",
                    width: 150,
                  ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _AqiData {
  final int hour;
  final double aqi;

  _AqiData(this.hour, this.aqi);
}
