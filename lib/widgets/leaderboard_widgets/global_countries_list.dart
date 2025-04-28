import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vaayusphere/widgets/leaderboard_widgets/air_quality_data.dart';

class GlobalCountriesList extends StatefulWidget {
  const GlobalCountriesList({super.key});

  @override
  State<GlobalCountriesList> createState() => _GlobalCountriesListState();
}

class _GlobalCountriesListState extends State<GlobalCountriesList> {
  late Future<List<AirQualityData>> _countriesData;
  bool _isLoading = true;
  String _sortBy = 'aqi'; // 'aqi' or 'name'
  bool _ascending = false; // true for ascending, false for descending

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    _countriesData = AirQualityService.getCountriesByPollution();

    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });
  }

  void _sortData(List<AirQualityData> countries) {
    if (_sortBy == 'aqi') {
      _ascending
          ? countries.sort((a, b) => a.aqi.compareTo(b.aqi))
          : countries.sort((a, b) => b.aqi.compareTo(a.aqi));
    } else if (_sortBy == 'name') {
      _ascending
          ? countries.sort((a, b) => a.country.compareTo(b.country))
          : countries.sort((a, b) => b.country.compareTo(a.country));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Countries by Air Pollution',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            _buildGlassDropdown(),
          ],
        ),
        const SizedBox(height: 16),
        _isLoading
            ? _buildLoadingList()
            : FutureBuilder<List<AirQualityData>>(
                future: _countriesData,
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
                        'No country data available',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  final countries = snapshot.data!;
                  _sortData(countries);

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: countries.length,
                    itemBuilder: (context, index) {
                      final country = countries[index];
                      final color = AirQualityData.getAqiColor(country.aqi);

                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20.0),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                  width: 1.5,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                leading: Text(
                                  '${index + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                title: Text(
                                  country.country,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: Text(
                                        'AQI: ${country.aqi.toStringAsFixed(1)}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      country.status,
                                      style: TextStyle(
                                        color: color,
                                        fontWeight: FontWeight.bold,
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

  Widget _buildGlassDropdown() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: Colors.black.withOpacity(0.7),
                  value: _sortBy,
                  style: const TextStyle(color: Colors.white),
                  items: const [
                    DropdownMenuItem(
                      value: 'aqi',
                      child: Text('Sort by AQI'),
                    ),
                    DropdownMenuItem(
                      value: 'name',
                      child: Text('Sort by Name'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _sortBy = value;
                      });
                    }
                  },
                ),
              ),
              IconButton(
                icon: Icon(
                  _ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  color: Colors.white,
                ),
                onPressed: () {
                  setState(() {
                    _ascending = !_ascending;
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.refresh, color: Colors.white),
                onPressed: _loadData,
                tooltip: 'Refresh data',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 10,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.0),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: const ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  // leading: Container(
                  //   width: 24,
                  //   height: 24,
                  //   color: Colors.white,
                  // ),
                  // title: Container(
                  //   width: double.infinity,
                  //   height: 16,
                  //   color: Colors.white,
                  // ),
                  // trailing: Container(
                  //   width: 80,
                  //   height: 16,
                  //   color: Colors.white,
                  // ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
