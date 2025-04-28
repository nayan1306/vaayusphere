import 'package:flutter/material.dart';
import 'package:sidebarx/sidebarx.dart';
import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:flutter/foundation.dart' show kIsWeb, Uint8List;
import 'dart:typed_data';

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
  final TextEditingController _subjectController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  // Firestore collection reference
  final CollectionReference _complaintsCollection =
      FirebaseFirestore.instance.collection('complaints');

  // Cloudinary instance
  late final CloudinaryPublic _cloudinary;

  // Image picker
  final ImagePicker _imagePicker = ImagePicker();

  // Selected image - different types for web vs mobile
  File? _selectedImageFile;
  Uint8List? _selectedImageBytes;
  XFile? _selectedImageXFile;
  bool get hasSelectedImage => _selectedImageXFile != null;

  // Loading state
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {});
    });

    // Initialize Cloudinary with your credentials
    _cloudinary = CloudinaryPublic('dtmmi1uae', 'complaints', cache: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _subjectController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImageXFile = pickedFile;

        if (!kIsWeb) {
          _selectedImageFile = File(pickedFile.path);
        } else {
          // For web, read as bytes
          pickedFile.readAsBytes().then((bytes) {
            setState(() {
              _selectedImageBytes = bytes;
            });
          });
        }
      });
    }
  }

  // Pick image from camera
  Future<void> _takePhoto() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImageXFile = pickedFile;

        if (!kIsWeb) {
          _selectedImageFile = File(pickedFile.path);
        } else {
          // For web, read as bytes
          pickedFile.readAsBytes().then((bytes) {
            setState(() {
              _selectedImageBytes = bytes;
            });
          });
        }
      });
    }
  }

  // Upload image to Cloudinary
  Future<String?> _uploadImage() async {
    if (_selectedImageXFile == null) return null;

    try {
      // Create a unique filename
      final String fileName =
          'complaint_img_${DateTime.now().millisecondsSinceEpoch}${path.extension(_selectedImageXFile!.name)}';

      CloudinaryResponse response;

      if (kIsWeb) {
        // Web upload using bytes
        _selectedImageBytes ??= await _selectedImageXFile!.readAsBytes();

        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            _selectedImageBytes!,
            folder: 'complaints',
            resourceType: CloudinaryResourceType.Image,
            identifier: fileName,
          ),
        );
      } else {
        // Mobile upload using file
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _selectedImageFile!.path,
            folder: 'complaints',
            resourceType: CloudinaryResourceType.Image,
            identifier: fileName,
          ),
        );
      }

      // Return the secure URL
      return response.secureUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  // Remove selected image
  void _removeImage() {
    setState(() {
      _selectedImageXFile = null;
      _selectedImageFile = null;
      _selectedImageBytes = null;
    });
  }

  // Submit a new complaint to Firestore
  Future<void> _submitComplaint() async {
    if (_subjectController.text.isEmpty ||
        _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all fields!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Upload image if selected
      String? imageUrl;
      if (_selectedImageXFile != null) {
        imageUrl = await _uploadImage();
      }

      // Generate a timestamp for the current date
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd').format(now);

      // Add new complaint to Firestore
      await _complaintsCollection.add({
        'subject': _subjectController.text,
        'description': _descriptionController.text,
        'date': formattedDate,
        'status': 'Pending',
        'imageUrl': imageUrl, // Add the image URL if available
        'timestamp': FieldValue.serverTimestamp(), // For sorting
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complaint submitted successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form
      _subjectController.clear();
      _descriptionController.clear();
      setState(() {
        _selectedImageXFile = null;
        _selectedImageFile = null;
        _selectedImageBytes = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting complaint: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.withOpacity(0.2),
              Colors.purple.withOpacity(0.2),
            ],
          ),
        ),
        // Use CustomScrollView instead of SingleChildScrollView with Expanded child
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // App Bar Content
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Complaints',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 24),
                    // New Complaint Form
                    _buildGlassmorphicContainer(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Submit New Complaint',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildGlassTextField(
                              controller: _subjectController,
                              hintText: 'Subject',
                            ),
                            const SizedBox(height: 16),
                            _buildGlassTextField(
                              controller: _descriptionController,
                              hintText: 'Description',
                              maxLines: 5,
                            ),
                            const SizedBox(height: 16),
                            // Image attachment section
                            _buildImageAttachmentSection(),
                            const SizedBox(height: 16),
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _submitComplaint,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.purpleAccent.withOpacity(0.3),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ))
                                    : const Text(
                                        'Submit',
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Previous Complaints',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // Previous Complaints List - now in a SliverFillRemaining
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 24.0),
              sliver: SliverToBoxAdapter(
                child: SizedBox(
                  // Set a fixed height for the list container instead of using Expanded
                  height: 2500, // Adjust as needed
                  child: _buildGlassmorphicContainer(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: _complaintsCollection
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }

                        if (snapshot.hasError) {
                          return Center(
                            child: Text(
                              'Error loading complaints: ${snapshot.error}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              'No complaints found',
                              style: TextStyle(color: Colors.white),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final data = doc.data() as Map<String, dynamic>;

                            // Create complaint model from Firestore document
                            final complaint = ComplaintModel(
                              id: doc.id,
                              subject: data['subject'] ?? 'No Subject',
                              description:
                                  data['description'] ?? 'No Description',
                              date: data['date'] ?? 'Unknown Date',
                              status: data['status'] ?? 'Pending',
                              imageUrl: data['imageUrl'],
                            );

                            return _buildComplaintCard(complaint);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build image attachment section
  Widget _buildImageAttachmentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Attachment',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (hasSelectedImage)
          Stack(
            children: [
              Container(
                constraints: const BoxConstraints(
                  minHeight: 120,
                  maxHeight: 400, // Set a reasonable maximum height
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildSelectedImagePreview(),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _removeImage,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          )
        else
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _buildAttachmentButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: _pickImage,
              ),
              const SizedBox(width: 12),
              _buildAttachmentButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: _takePhoto,
              ),
            ],
          ),
      ],
    );
  }

  // Build image preview based on platform
  Widget _buildSelectedImagePreview() {
    if (!hasSelectedImage) return Container();

    if (kIsWeb) {
      // For web, always use the XFile and read as bytes
      return FutureBuilder<Uint8List>(
        future: _selectedImageXFile!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(
                color: Colors.white.withOpacity(0.8),
              ),
            );
          }
          if (snapshot.hasData) {
            return Center(
              child: Image.memory(
                snapshot.data!,
                fit: BoxFit.contain,
              ),
            );
          }
          return Center(
            child: Icon(
              Icons.image_not_supported,
              color: Colors.white.withOpacity(0.8),
            ),
          );
        },
      );
    } else {
      // For mobile, use file image
      if (_selectedImageFile != null) {
        return Center(
          child: Image.file(
            _selectedImageFile!,
            fit: BoxFit.contain,
          ),
        );
      }
    }

    return Center(
      child: Icon(
        Icons.image_not_supported,
        color: Colors.white.withOpacity(0.8),
      ),
    );
  }

  // Build attachment button for camera and gallery
  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.white.withOpacity(0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.8),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassmorphicContainer({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _buildGlassTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: TextField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withOpacity(0.1),
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Colors.purpleAccent,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildComplaintCard(ComplaintModel complaint) {
    Color statusColor;
    switch (complaint.status) {
      case 'Resolved':
        statusColor = Colors.green;
        break;
      case 'In Progress':
        statusColor = Colors.amber;
        break;
      case 'Pending':
      default:
        statusColor = Colors.red;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        complaint.subject,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: statusColor.withOpacity(0.5),
                        ),
                      ),
                      child: Text(
                        complaint.status,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  complaint.description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 8),
                // Display image if available
                if (complaint.imageUrl != null &&
                    complaint.imageUrl!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 8),
                    child: GestureDetector(
                      onTap: () =>
                          _showImageFullScreen(context, complaint.imageUrl!),
                      child: Container(
                        height: 620,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.2),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: CachedNetworkImage(
                            imageUrl: complaint.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.black.withOpacity(0.1),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: Colors.black.withOpacity(0.1),
                              child: const Center(
                                child: Icon(
                                  Icons.error_outline,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'ID: ${complaint.id}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      'Date: ${complaint.date}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    _buildStatusUpdateButton(complaint),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Show full screen image preview
  void _showImageFullScreen(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.zero,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Image with zoom capability
                InteractiveViewer(
                  minScale: 0.5,
                  maxScale: 4.0,
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.95,
                    height: MediaQuery.of(context).size.height * 0.95,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.contain,
                      placeholder: (context, url) => const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, url, error) => const Center(
                        child: Icon(
                          Icons.error_outline,
                          color: Colors.white,
                          size: 50,
                        ),
                      ),
                    ),
                  ),
                ),
                // Close button
                Positioned(
                  top: 40,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Status update dropdown button
  Widget _buildStatusUpdateButton(ComplaintModel complaint) {
    return PopupMenuButton<String>(
      onSelected: (String value) async {
        try {
          await _complaintsCollection.doc(complaint.id).update({
            'status': value,
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Status updated to $value'),
              backgroundColor: Colors.green,
            ),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating status: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'Pending',
          child: Text('Pending'),
        ),
        const PopupMenuItem<String>(
          value: 'In Progress',
          child: Text('In Progress'),
        ),
        const PopupMenuItem<String>(
          value: 'Resolved',
          child: Text('Resolved'),
        ),
      ],
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update Status',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white.withOpacity(0.8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

// Model class for Complaint data
class ComplaintModel {
  final String id;
  final String subject;
  final String description;
  final String date;
  final String status;
  final String? imageUrl;

  ComplaintModel({
    required this.id,
    required this.subject,
    required this.description,
    required this.date,
    required this.status,
    this.imageUrl,
  });
}
