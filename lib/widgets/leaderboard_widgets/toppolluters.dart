import 'dart:ui'; // Import for glassmorphism (blur)

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vaayusphere/widgets/leaderboard_widgets/air_quality_data.dart'; // Your AirQualityData model

class TopPolluters extends StatefulWidget {
  const TopPolluters({super.key});

  @override
  State<TopPolluters> createState() => _TopPollutersState();
}

class _TopPollutersState extends State<TopPolluters> {
  late Future<List<AirQualityData>> _citiesData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _citiesData = AirQualityService.getMostPollutedCities();

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Most Polluted Cities',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White title for glassy look
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadData,
                tooltip: 'Refresh data',
              ),
            ],
          ),
        ),
        _isLoading
            ? _buildLoadingList()
            : FutureBuilder<List<AirQualityData>>(
                future: _citiesData,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildLoadingList();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Column(
                        children: [
                          const Icon(Icons.error, size: 50, color: Colors.red),
                          const SizedBox(height: 16),
                          Text(
                            'Error loading data: ${snapshot.error}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          TextButton(
                            onPressed: _loadData,
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                      child: Text(
                        'No pollution data available',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final cities = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        cities.length > 20 ? 20 : cities.length, // Top 20
                    itemBuilder: (context, index) {
                      final city = cities[index];
                      final color = AirQualityData.getAqiColor(city.aqi);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: color,
                                  child: Text(
                                    '${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  city.city,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                subtitle: Text(
                                  city.country,
                                  style: const TextStyle(
                                    color: Colors.white70,
                                  ),
                                ),
                                trailing: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'AQI: ${city.aqi.toStringAsFixed(1)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                    Text(
                                      city.status,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
      ],
    );
  }

  Widget _buildLoadingList() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 10,
        itemBuilder: (_, __) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Container(
              color: Colors.white.withOpacity(0.2),
              height: 80,
            ),
          ),
        ),
      ),
    );
  }
}
