import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

// Model classes
class PlantationGroup {
  final String id;
  final String name;
  final String description;
  final String category;
  final int memberCount;
  final LatLng location;
  final String address;
  final String imageUrl;
  final double distance;

  PlantationGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.memberCount,
    required this.location,
    required this.address,
    required this.imageUrl,
    required this.distance,
  });
}

class PlantationDrive {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final LatLng location;
  final String address;
  final String groupId;
  final String groupName;
  final int participantCount;
  final int targetTrees;
  final double distance;

  PlantationDrive({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.address,
    required this.groupId,
    required this.groupName,
    required this.participantCount,
    required this.targetTrees,
    required this.distance,
  });
}

class PlantationScreenPlaceholder extends StatefulWidget {
  const PlantationScreenPlaceholder({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  State<PlantationScreenPlaceholder> createState() =>
      _PlantationScreenPlaceholderState();
}

class _PlantationScreenPlaceholderState
    extends State<PlantationScreenPlaceholder>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late TabController _tabController;
  final MapController _mapController = MapController();

  // Firebase variables
  late FirebaseFirestore _firestore;
  List<PlantationGroup> _nearbyGroups = [];
  List<PlantationDrive> _upcomingDrives = [];

  // Location variables
  LatLng _currentPosition =
      const LatLng(28.6139, 77.2090); // Default position (New Delhi)
  String _currentAddress = "Fetching location...";

  // Filter variables
  double _distanceFilter = 10.0; // km
  String _selectedCategory = "All";
  final List<String> _categories = [
    "All",
    "Community",
    "NGO",
    "Government",
    "School"
  ];

  // New drive form variables
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedGroupId = "";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(() => setState(() {}));
    _firestore = FirebaseFirestore.instance;
    _getCurrentLocation();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _currentAddress = "Location services are disabled";
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _currentAddress = "Location permissions are denied";
          });
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
          _currentAddress = "${place.locality}, ${place.administrativeArea}";
        });

        // Move map to current location
        _mapController.move(_currentPosition, 13.0);
        // Fetch data based on new location
        _fetchNearbyGroups();
        _fetchUpcomingDrives();
      }
    } catch (e) {
      setState(() {
        _currentAddress = "Error getting location: $e";
      });
    }
  }

  _fetchNearbyGroups() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('plantation_groups').get();

      setState(() {
        _nearbyGroups = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          double lat = data['latitude'] ?? 0.0;
          double lng = data['longitude'] ?? 0.0;

          double distance = Geolocator.distanceBetween(
                _currentPosition.latitude,
                _currentPosition.longitude,
                lat,
                lng,
              ) /
              1000; // Convert to km

          return PlantationGroup(
            id: doc.id,
            name: data['name'] ?? 'Unknown Group',
            description: data['description'] ?? '',
            category: data['category'] ?? 'Community',
            memberCount: data['memberCount'] ?? 0,
            location: LatLng(lat, lng),
            address: data['address'] ?? 'Unknown Location',
            imageUrl: data['imageUrl'] ?? '',
            distance: distance,
          );
        }).toList()
          ..sort((a, b) => a.distance.compareTo(b.distance));
      });
    } catch (e) {
      print('Error fetching groups: $e');
    }
  }

  _fetchUpcomingDrives() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('plantation_drives')
          .where('date',
              isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
          .orderBy('date')
          .limit(20)
          .get();

      List<PlantationDrive> drives =
          await Future.wait(snapshot.docs.map((doc) async {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        DocumentSnapshot groupDoc = await _firestore
            .collection('plantation_groups')
            .doc(data['groupId'])
            .get();
        Map<String, dynamic> groupData =
            groupDoc.exists ? (groupDoc.data() as Map<String, dynamic>) : {};

        double lat = data['latitude'] ?? 0.0;
        double lng = data['longitude'] ?? 0.0;
        double distance = Geolocator.distanceBetween(
              _currentPosition.latitude,
              _currentPosition.longitude,
              lat,
              lng,
            ) /
            1000;

        return PlantationDrive(
          id: doc.id,
          title: data['title'] ?? 'Unnamed Drive',
          description: data['description'] ?? '',
          date: (data['date'] as Timestamp).toDate(),
          location: LatLng(lat, lng),
          address: data['address'] ?? 'Unknown Location',
          groupId: data['groupId'] ?? '',
          groupName: groupData['name'] ?? 'Unknown Group',
          participantCount: data['participantCount'] ?? 0,
          targetTrees: data['targetTrees'] ?? 0,
          distance: distance,
        );
      }).toList());

      setState(() => _upcomingDrives = drives);
    } catch (e) {
      print('Error fetching drives: $e');
    }
  }

  Future<void> _joinGroup(String groupId) async {
    try {
      await _firestore.collection('group_members').add({
        'groupId': groupId,
        'userId': 'current_user_id', // Replace with actual auth user ID
        'joinedAt': Timestamp.now(),
      });

      await _firestore.collection('plantation_groups').doc(groupId).update({
        'memberCount': FieldValue.increment(1),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Successfully joined the group!')),
      );
      _fetchNearbyGroups();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining group: $e')),
      );
    }
  }

  Future<void> _joinDrive(String driveId) async {
    try {
      await _firestore.collection('drive_participants').add({
        'driveId': driveId,
        'userId': 'current_user_id', // Replace with actual auth user ID
        'joinedAt': Timestamp.now(),
      });

      await _firestore.collection('plantation_drives').doc(driveId).update({
        'participantCount': FieldValue.increment(1),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Successfully joined the plantation drive!')),
      );
      _fetchUpcomingDrives();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error joining drive: $e')),
      );
    }
  }

  Future<void> _createDrive() async {
    try {
      DateTime dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      await _firestore.collection('plantation_drives').add({
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': Timestamp.fromDate(dateTime),
        'latitude': _currentPosition.latitude,
        'longitude': _currentPosition.longitude,
        'address': _currentAddress,
        'groupId': _selectedGroupId,
        'createdBy': 'current_user_id',
        'createdAt': Timestamp.now(),
        'participantCount': 1,
        'targetTrees': 50,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plantation drive created successfully!')),
      );

      _titleController.clear();
      _descriptionController.clear();
      _fetchUpcomingDrives();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating drive: $e')),
      );
    }
  }

  // Common UI components
  Widget _buildChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: Color.fromARGB(255, 255, 255, 255),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildBlurredContainer({
    required Widget child,
    double borderRadius = 15,
    EdgeInsets padding = EdgeInsets.zero,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(color: Colors.white.withOpacity(0.5), width: 1),
          ),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                    "https://t3.ftcdn.net/jpg/01/70/81/86/360_F_170818693_t9Ci3UglAbQ0K15vUCE0xVaKpAdsFHRy.jpg"),
                fit: BoxFit.cover,
                opacity: 0.3,
              ),
            ),
          ),

          // Main content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120.0,
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(20.0),
                    bottomRight: Radius.circular(20.0),
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.green.withOpacity(0.7),
                              Colors.teal.withOpacity(0.5),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(50),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _buildBlurredContainer(
                      borderRadius: 25,
                      child: TabBar(
                        controller: _tabController,
                        indicatorColor: Colors.white,
                        indicatorWeight: 3,
                        labelColor: Colors.white,
                        tabs: const [
                          Tab(text: 'Map'),
                          // Tab(text: 'Groups'),
                          Tab(text: 'Drives'),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Tab content
              SliverFillRemaining(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildMapTab(),
                    // _buildGroupsTab(),
                    _buildDrivesTab(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildMapTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: _buildBlurredContainer(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            // Map filters
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedCategory,
                    items: _categories.map((category) {
                      return DropdownMenuItem<String>(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedCategory = value!),
                    underline: Container(
                      height: 1,
                      color: Colors.green.withOpacity(0.5),
                    ),
                    dropdownColor: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Distance: ${_distanceFilter.toInt()} km'),
                      Slider(
                        value: _distanceFilter,
                        min: 1,
                        max: 50,
                        divisions: 49,
                        onChanged: (value) =>
                            setState(() => _distanceFilter = value),
                        activeColor: Colors.green,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Map
            Expanded(
              child: FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: _currentPosition,
                  minZoom: 3.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      // Current location marker
                      Marker(
                        width: 40,
                        height: 40,
                        point: _currentPosition,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.7),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(Icons.person_pin_circle,
                              color: Colors.white, size: 30),
                        ),
                      ),
                      // Group markers
                      ..._nearbyGroups
                          .where((group) =>
                              group.distance <= _distanceFilter &&
                              (_selectedCategory == "All" ||
                                  group.category == _selectedCategory))
                          .map((group) => Marker(
                                width: 40,
                                height: 40,
                                point: group.location,
                                child: GestureDetector(
                                  onTap: () => _showGroupDetails(group),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.nature_people,
                                        color: Colors.white, size: 24),
                                  ),
                                ),
                              )),
                      // Drive markers
                      ..._upcomingDrives
                          .where((drive) => drive.distance <= _distanceFilter)
                          .map((drive) => Marker(
                                width: 40,
                                height: 40,
                                point: drive.location,
                                child: GestureDetector(
                                  onTap: () => _showDriveDetails(drive),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.amber.withOpacity(0.7),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 2),
                                    ),
                                    child: const Icon(Icons.park,
                                        color: Colors.white, size: 24),
                                  ),
                                ),
                              )),
                    ],
                  ),
                ],
              ),
            ),

            // Legend
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem(Colors.blue, 'You'),
                  const SizedBox(width: 16),
                  _buildLegendItem(Colors.green, 'Groups'),
                  const SizedBox(width: 16),
                  _buildLegendItem(Colors.amber, 'Drives'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color.withOpacity(0.7),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
          ),
        ),
        const SizedBox(width: 4),
        Text(label),
      ],
    );
  }

  Widget _buildDrivesTab() {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('plantation_drives').get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Error loading drives.'));
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return const Center(child: Text('No upcoming drives.'));
        }

        final drives = docs
            .map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return PlantationDrive(
                id: doc.id,
                title: data['title'] ?? '',
                groupName: data['groupName'] ?? '',
                date: (data['date'] as Timestamp).toDate(),
                address: data['address'] ?? '',
                participantCount: data['participantCount'] ?? 0,
                targetTrees: data['targetTrees'] ?? 0,
                distance: (data['distance'] ?? 0).toDouble(),
                description: data['description'] ?? '',
                location: const LatLng(28.6139, 77.209),
                groupId: '',
              );
            })
            .where((drive) => drive.distance <= _distanceFilter)
            .toList();

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header
              // _buildBlurredContainer(
              //   padding: const EdgeInsets.all(16),
              //   child: Column(
              //     children: [
              //       const Text('Upcoming Plantation Drives',
              //           style: TextStyle(
              //               fontSize: 18, fontWeight: FontWeight.bold)),
              //       const SizedBox(height: 8),
              //       Text('Join a plantation drive near you or create your own',
              //           style: TextStyle(color: Colors.black.withOpacity(0.7))),
              //     ],
              //   ),
              // ),
              const SizedBox(height: 16),

              // Drives list
              Expanded(
                child: ListView.builder(
                  itemCount: drives.length,
                  itemBuilder: (context, index) {
                    final drive = drives[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: _buildBlurredContainer(
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(drive.title,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 181, 255, 117),
                                    fontSize: 18,
                                  )),
                              subtitle: Text(
                                drive.description,
                                style: const TextStyle(color: Colors.white),
                              ),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(DateFormat('MMM dd').format(drive.date),
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white)),
                                  Text(
                                    DateFormat('hh:mm a').format(drive.date),
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  // const Icon(Icons.location_on,
                                  //     size: 16, color: Colors.green),
                                  // const SizedBox(width: 4),
                                  // Expanded(
                                  //   child: Text(drive.address,
                                  //       style: TextStyle(
                                  //           color:
                                  //               Colors.black.withOpacity(0.7))),
                                  // ),
                                  Text(
                                      '${drive.distance.toStringAsFixed(1)} km away',
                                      style: TextStyle(
                                          color:
                                              Colors.black.withOpacity(0.7))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                children: [
                                  _buildChip(
                                      '${drive.participantCount} participants',
                                      const Color.fromARGB(255, 255, 217, 0)),
                                  const SizedBox(width: 8),
                                  _buildChip('${drive.targetTrees} trees',
                                      const Color.fromARGB(255, 55, 255, 41)),
                                ],
                              ),
                            ),
                            OverflowBar(
                              alignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () => _showDriveDetails(drive),
                                  child: const Text(
                                    'Details',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                                ElevatedButton(
                                  onPressed: () => _joinDrive(drive.id),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor:
                                        Colors.green.withOpacity(0.7),
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Join'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton() {
    return _buildBlurredContainer(
      borderRadius: 30,
      child: FloatingActionButton.extended(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            backgroundColor: Colors.transparent,
            builder: (context) => _buildBlurredContainer(
              borderRadius: 20,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading:
                        const Icon(Icons.nature_people, color: Colors.green),
                    title: const Text('Create New Group'),
                    onTap: () {
                      Navigator.pop(context);
                      _showDialog('Create New Plantation Group',
                          'This feature will be available soon!');
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.park, color: Colors.amber),
                    title: const Text('Create Plantation Drive'),
                    onTap: () {
                      Navigator.pop(context);
                      _showCreateDriveDialog();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        backgroundColor: Colors.green.withOpacity(0.8),
        foregroundColor: Colors.white,
        label: const Text('Create'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.8),
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDriveDialog() {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          title: const Text('Create Plantation Drive',
              style: TextStyle(color: Colors.lightGreen)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Drive Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  title: const Text('Date'),
                  subtitle:
                      Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null && picked != _selectedDate) {
                      setState(() {
                        _selectedDate = picked;
                      });
                    }
                  },
                ),
                ListTile(
                  title: const Text('Time'),
                  subtitle: Text(_selectedTime.format(context)),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final TimeOfDay? picked = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (picked != null && picked != _selectedTime) {
                      setState(() {
                        _selectedTime = picked;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Group',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedGroupId.isEmpty ? null : _selectedGroupId,
                  items: _nearbyGroups.map((group) {
                    return DropdownMenuItem<String>(
                      value: group.id,
                      child: Text(group.name),
                    );
                  }).toList(),
                  onChanged: (value) =>
                      setState(() => _selectedGroupId = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _createDrive();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  void _showGroupDetails(PlantationGroup group) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          title: Text(group.name, style: const TextStyle(color: Colors.green)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.green.withOpacity(0.7),
                  child: Text(
                    group.name.isNotEmpty ? group.name[0] : '?',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(group.description),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Expanded(child: Text(group.address)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildChip(group.category, Colors.teal),
                  const SizedBox(width: 8),
                  _buildChip('${group.memberCount} members', Colors.blue),
                  const SizedBox(width: 8),
                  _buildChip(
                      '${group.distance.toStringAsFixed(1)} km', Colors.orange),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _joinGroup(group.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Join Group'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDriveDetails(PlantationDrive drive) {
    showDialog(
      context: context,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.9),
          title: Text(drive.title, style: const TextStyle(color: Colors.amber)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Organized by ${drive.groupName}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(drive.description),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today,
                      size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(DateFormat('EEEE, MMM dd, yyyy').format(drive.date)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.access_time, size: 16, color: Colors.blue),
                  const SizedBox(width: 4),
                  Text(DateFormat('hh:mm a').format(drive.date)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 16, color: Colors.green),
                  const SizedBox(width: 4),
                  Expanded(child: Text(drive.address)),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildChip(
                      '${drive.participantCount} participants', Colors.blue),
                  const SizedBox(width: 8),
                  _buildChip('${drive.targetTrees} trees', Colors.green),
                  const SizedBox(width: 8),
                  _buildChip(
                      '${drive.distance.toStringAsFixed(1)} km', Colors.orange),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _joinDrive(drive.id);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.white,
              ),
              child: const Text('Join Drive'),
            ),
          ],
        ),
      ),
    );
  }
}
