import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';

class ComplaintsScreenPlaceholder extends StatefulWidget {
  const ComplaintsScreenPlaceholder({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  State<ComplaintsScreenPlaceholder> createState() =>
      _ComplaintsScreenPlaceholderState();
}

class _ComplaintsScreenPlaceholderState
    extends State<ComplaintsScreenPlaceholder> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return const Scaffold(
      body: Center(child: Text("Complaints Screen")),
    );
  }
}
