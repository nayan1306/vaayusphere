import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    _scrollController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            expandedHeight: 120.0,
            pinned: true,
            backgroundColor: const Color.fromARGB(0, 32, 31, 51),
            flexibleSpace: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
              child: FlexibleSpaceBar(
                background: Container(
                  foregroundDecoration: const BoxDecoration(
                    color: Color.fromARGB(127, 180, 255, 134),
                  ),
                  child: Image.network(
                    "https://t3.ftcdn.net/jpg/01/70/81/86/360_F_170818693_t9Ci3UglAbQ0K15vUCE0xVaKpAdsFHRy.jpg",
                    fit: BoxFit.contain,
                    repeat: ImageRepeat.repeat,
                    errorBuilder: (context, error, stackTrace) {
                      // Display a placeholder if image fails to load
                      return Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 50),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
