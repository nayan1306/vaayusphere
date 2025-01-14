import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:vaayusphere/providers/apidataprovider.dart';

class WeatherForecastCard extends StatelessWidget {
  const WeatherForecastCard({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherProvider = Provider.of<ApiDataProvider>(context);
    final weatherData = weatherProvider.weatherForecastData;

    // Fetch weather data if not already fetched
    if (weatherData == null) {
      weatherProvider.fetchAndSetweatherForecastData();
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    // Parse weather data
    final dailyForecast = weatherData['daily'];
    final dates = (dailyForecast['time'] as List<dynamic>).cast<String>();
    final weatherCodes =
        (dailyForecast['weather_code'] as List<dynamic>).cast<int>();

    // Prepare chart data
    final List<WeatherData> chartData = List.generate(
      dates.length,
      (index) => WeatherData(
        date: _formatDate(dates[index]),
        icon: _getWeatherIcon(weatherCodes[index]),
        code: weatherCodes[index],
      ),
    );

    return SizedBox(
      width: 500,
      height: 250,
      child: Card(
        color: Colors.transparent,
        elevation: 0, // No shadow
        margin: const EdgeInsets.all(15),

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: Colors.white.withOpacity(0.5), // Wide border color
            width: 1, // Border width
          ),
        ),
        child: SfCartesianChart(
          enableAxisAnimation: true,
          plotAreaBackgroundColor: Colors.transparent,
          plotAreaBorderColor: Colors.transparent,
          plotAreaBorderWidth: 0,
          // margin: const EdgeInsets.all(1),
          primaryXAxis: const CategoryAxis(
            // title: AxisTitle(
            //   text: 'Date',
            //   textStyle: TextStyle(
            //       color: Color.fromARGB(255, 220, 233, 255),
            //       fontWeight: FontWeight.bold,
            //       fontSize: 10),
            // ),
            labelStyle: TextStyle(color: Color.fromARGB(255, 224, 235, 255)),
            // isVisible: false,
            majorGridLines:
                MajorGridLines(width: 0), // Disable major grid lines
          ),
          primaryYAxis: const NumericAxis(
            title: AxisTitle(
              text: 'Weather Intensity',
              textStyle: TextStyle(
                color: Color.fromARGB(255, 0, 85, 255),
                fontWeight: FontWeight.bold,
              ),
            ),
            // labelStyle: TextStyle(color: Color.fromARGB(255, 190, 190, 190)),
            isVisible: false,
            majorGridLines:
                MajorGridLines(width: 0), // Disable major grid lines
          ),
          title: const ChartTitle(
            text: '7-Day Weather Forecast',
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color.fromARGB(255, 240, 248, 255),
            ),
          ),
          tooltipBehavior: TooltipBehavior(
            enable: true,
            format: 'point.x\nWeather:  point.label',
          ),
          series: <CartesianSeries>[
            ColumnSeries<WeatherData, String>(
              dataSource: chartData,
              xValueMapper: (WeatherData data, _) => data.date,
              yValueMapper: (WeatherData data, _) => data.code,
              pointColorMapper: (_, __) =>
                  const Color.fromARGB(68, 234, 208, 255).withOpacity(0.7),
              dataLabelMapper: (WeatherData data, _) => data.icon,
              dataLabelSettings: const DataLabelSettings(
                isVisible: true,
                textStyle: TextStyle(
                  fontSize: 24,
                  color: Color.fromARGB(255, 255, 253, 247),
                ),
              ),
              spacing: 0.2, // Spacing between bars
              width: 0.7, // Width of the bars

              borderWidth: 0, // No border width between bars
              borderColor: Colors.transparent, // Ensures no visible borders
              borderRadius: BorderRadius.circular(
                  8), // Optional: Adjust the roundness of the bars
              enableTooltip: true, // Enable tooltip for better interaction
              isVisibleInLegend:
                  false, // Optionally hide the legend if not needed
              opacity:
                  0.8, // Adjust the opacity to make bars less solid (if needed)
              selectionBehavior: SelectionBehavior(
                enable: true, // Enable selection behavior
              ),
              animationDuration: 1000, // Adjust animation duration
              trackColor: Colors.transparent, // Remove track color behind bars
              trackBorderColor: Colors.transparent, // No track border
              trackBorderWidth: 0.0, // Set to 0 to avoid any track border
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String date) {
    final parsedDate = DateTime.parse(date);
    return DateFormat('dd MMM').format(parsedDate);
  }

  String _getWeatherIcon(int code) {
    if (code == 0) return '☀️'; // Clear sky
    if ([1, 2, 3].contains(code)) return '⛅'; // Partly cloudy
    if ([45, 48].contains(code)) return '🌫️'; // Fog
    if ([51, 53, 55].contains(code)) return '🌦️'; // Drizzle
    if ([56, 57].contains(code)) return '❄️'; // Freezing drizzle
    if ([61, 63, 65].contains(code)) return '🌧️'; // Rain
    if ([66, 67].contains(code)) return '🌨️'; // Freezing rain
    if ([71, 73, 75].contains(code)) return '🌨️'; // Snowfall
    if (code == 77) return '❄️'; // Snow grains
    if ([80, 81, 82].contains(code)) return '🌦️'; // Rain showers
    if ([85, 86].contains(code)) return '🌨️'; // Snow showers
    if (code == 95) return '⛈️'; // Thunderstorm
    if ([96, 99].contains(code)) return '🌩️'; // Thunderstorm with hail
    return '❓'; // Unknown
  }
}

class WeatherData {
  final String date;
  final String icon;
  final int code;

  WeatherData({required this.date, required this.icon, required this.code});
}
