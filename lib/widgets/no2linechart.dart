import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart'; // Import Syncfusion chart package
import 'package:vaayusphere/widgets/glasscard.dart';
import 'package:vaayusphere/providers/air_quality_provider.dart'; // Adjust import path
// For date formatting

class No2LineChart extends StatelessWidget {
  const No2LineChart({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the air quality data from the provider
    final airQualityData = Provider.of<ApiDataProvider>(context).airQualityData;

    // Extract data for the chart
    List<_AqiData> chartData = [];
    if (airQualityData != null) {
      final timeData = airQualityData['hourly']['time'] as List;
      final hourlyData = airQualityData['hourly']['nitrogen_dioxide'] as List;

      chartData = List.generate(
        timeData.length,
        (index) {
          final hour = (DateTime.parse(timeData[index]).hour); // Extract hour
          return _AqiData(hour, hourlyData[index].toDouble());
        },
      );
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
      width: 640,
      height: 300,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            airQualityData != null
                ? Expanded(
                    child: SfCartesianChart(
                      zoomPanBehavior: zoomPanBehavior, // Apply zooming/panning
                      tooltipBehavior: tooltipBehavior, // Apply tooltips
                      plotAreaBorderWidth: 0.0,

                      title: const ChartTitle(
                        text: 'Hourly NO₂',
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
                          text: 'NO₂',
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
                          name: 'NO₂',
                          width: 5,
                          color: const Color.fromARGB(255, 210, 249, 255),
                          markerSettings: const MarkerSettings(
                              isVisible: true,
                              color: Color.fromARGB(255, 255, 205, 105)),
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
                : Image.asset(
                    "./assets/gifs/air.gif",
                    width: 150,
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
