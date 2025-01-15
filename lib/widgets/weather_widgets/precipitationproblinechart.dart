import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Import Syncfusion chart package
import 'package:vaayusphere/widgets/dashboard_widgets/glasscard.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';
// import 'package:vaayusphere/widgets/dashboard_widgets/weatherforecastcard.dart'; // Adjust import path
// For date formatting

class PrecipitationProbabilityLineChart extends StatelessWidget {
  const PrecipitationProbabilityLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the air quality data from the provider
    final WeatherData =
        Provider.of<ApiDataProvider>(context).weatherForecastDataDetailed;

    // Extract data for the chart
    List<_AqiData> chartData = [];
    if (WeatherData != null) {
      final timeData = WeatherData['hourly']['time'] as List;
      final hourlyData =
          WeatherData['hourly']['precipitation_probability	'] as List;

      chartData = List.generate(
        timeData.length,
        (index) {
          final hour = (DateTime.parse(timeData[index]).hour); // Extract hour
          return _AqiData(hour, hourlyData[index].toDouble());
        },
      );

      // Sort the chart data by hour
      chartData.sort((a, b) => a.hour.compareTo(b.hour));
    }

    // Configure zooming and panning behavior
    final ZoomPanBehavior zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true, // Enable zooming using pinch gesture
      enablePanning: true, // Enable panning
      enableDoubleTapZooming: true, // Enable double-tap zooming
      enableMouseWheelZooming:
          true, // Enable mouse wheel zooming (for web/desktop)
      enableSelectionZooming: true, // Enable selection zooming
      zoomMode: ZoomMode.xy, // Enable zooming for both X and Y axes
    );

    // Configure tooltip behavior
    final TooltipBehavior tooltipBehavior = TooltipBehavior(
      enable: true, // Enable tooltips
      header: '', // Optional: Hide header for tooltips
      format: 'Hour: point.x\nAQI: point.y µg/m³', // Custom tooltip format
    );

    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.4,
      height: 300,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            WeatherData != null
                ? Expanded(
                    child: SfCartesianChart(
                      zoomPanBehavior: zoomPanBehavior, // Apply zooming/panning
                      tooltipBehavior: tooltipBehavior, // Apply tooltips
                      plotAreaBorderWidth: 0.0,

                      title: const ChartTitle(
                        text: 'Precipitation Probability',
                        textStyle: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      primaryXAxis: const NumericAxis(
                        title: AxisTitle(
                          text: 'Hour',
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white70,
                          ),
                        ),
                        labelStyle: TextStyle(color: Colors.white70),
                        majorGridLines: MajorGridLines(width: 0),
                      ),
                      primaryYAxis: const NumericAxis(
                        title: AxisTitle(
                          text: 'Precipitation Probability',
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
                        LineSeries<_AqiData, int>(
                          dataSource: chartData,
                          xValueMapper: (_AqiData data, _) => data.hour,
                          yValueMapper: (_AqiData data, _) => data.aqi,
                          name: 'preciptation probability',
                          width: 5,
                          color: const Color.fromARGB(255, 152, 255, 241),
                          markerSettings: const MarkerSettings(
                              isVisible: true,
                              color: Color.fromARGB(255, 41, 165, 138)),
                          dataLabelSettings: const DataLabelSettings(
                            isVisible: false, // Disable default data labels
                          ),
                          enableTooltip: true, // Enable tooltips for the series
                        ),
                      ],
                      backgroundColor: Colors.transparent,
                      borderColor: Colors.transparent,
                    ),
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
                      indicatorType: Indicator.lineScalePulseOut,
                      strokeWidth: 3,
                    ),
                  ), // Show a loader while data is being fetched
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// Data model for chart data
class _AqiData {
  final int hour;
  final double aqi;

  _AqiData(this.hour, this.aqi);
}
