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

class AppraisalScreenPlaceholder extends StatefulWidget {
  const AppraisalScreenPlaceholder({
    super.key,
    required this.controller,
  });

  final SidebarXController controller;

  @override
  State<AppraisalScreenPlaceholder> createState() =>
      _AppraisalScreenPlaceholderState();
}

class _AppraisalScreenPlaceholderState
    extends State<AppraisalScreenPlaceholder> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // Firestore collection reference
  final CollectionReference _appraisalsCollection =
      FirebaseFirestore.instance.collection('appraisals');

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

  // User info (would come from auth in a real app)
  final String _username = "Nayan verma"; // Placeholder username

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {});
    });

    // Initialize Cloudinary with your credentials
    _cloudinary = CloudinaryPublic('dtmmi1uae', 'appraisals', cache: false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
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
          'appraisal_img_${DateTime.now().millisecondsSinceEpoch}${path.extension(_selectedImageXFile!.name)}';

      CloudinaryResponse response;

      if (kIsWeb) {
        // Web upload using bytes
        _selectedImageBytes ??= await _selectedImageXFile!.readAsBytes();

        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromBytesData(
            _selectedImageBytes!,
            folder: 'appraisals',
            resourceType: CloudinaryResourceType.Image,
            identifier: fileName,
          ),
        );
      } else {
        // Mobile upload using file
        response = await _cloudinary.uploadFile(
          CloudinaryFile.fromFile(
            _selectedImageFile!.path,
            folder: 'appraisals',
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

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          content: _buildGlassmorphicContainer(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Create Environmental Appraisal Post",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildGlassTextField(
                    controller: _titleController,
                    hintText:
                        "Enter the title of your environmental achievement",
                    label: "Title",
                  ),
                  const SizedBox(height: 16),
                  _buildGlassTextField(
                    controller: _descriptionController,
                    hintText: "Describe your environmental contribution",
                    label: "Description",
                    maxLines: 5,
                  ),
                  const SizedBox(height: 16),
                  _buildGlassTextField(
                    controller: _tagsController,
                    hintText: "e.g., CleanupEvent, Recycling, Conservation",
                    label: "Tags (comma separated)",
                  ),
                  const SizedBox(height: 16),
                  _buildImageAttachmentSection(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _isLoading
                            ? null
                            : () async {
                                await _submitPost();
                                Navigator.of(context).pop();
                              },
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text("Post"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Submit a new appraisal post to Firestore
  Future<void> _submitPost() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill title and description fields!'),
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

      // Process tags
      List<String> tags = [];
      if (_tagsController.text.isNotEmpty) {
        tags = _tagsController.text
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();
      }

      // Calculate time ago
      final now = DateTime.now();

      // Add new appraisal to Firestore
      await _appraisalsCollection.add({
        'username': _username,
        'title': _titleController.text,
        'description': _descriptionController.text,
        'imageUrl': imageUrl ?? '',
        'upvotes': 0,
        'timeAgo': 'just now',
        'tags': tags,
        'timestamp': FieldValue.serverTimestamp(),
        'date': DateFormat('yyyy-MM-dd').format(now),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Appraisal post created successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form
      _titleController.clear();
      _descriptionController.clear();
      _tagsController.clear();
      setState(() {
        _selectedImageXFile = null;
        _selectedImageFile = null;
        _selectedImageBytes = null;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating post: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Update timeAgo field based on timestamp
  String _getTimeAgo(Timestamp timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp.toDate());

    if (difference.inDays > 7) {
      return DateFormat('MMM d, yyyy').format(timestamp.toDate());
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreatePostDialog,
        icon: const Icon(Icons.add_circle_outline),
        label: const Text(
          "Create Post",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 207, 239, 208),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.withOpacity(0.2),
              Colors.teal.withOpacity(0.2),
            ],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              expandedHeight: 120.0,
              pinned: false,
              backgroundColor: Colors.transparent,
              flexibleSpace: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20.0),
                  bottomRight: Radius.circular(20.0),
                ),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: FlexibleSpaceBar(
                    title: const Text(
                      "Environmental Heroes",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 44,
                        shadows: [
                          Shadow(
                            offset: Offset(1.0, 1.0),
                            blurRadius: 3.0,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ],
                      ),
                    ),
                    centerTitle: true,
                    background: Container(
                      foregroundDecoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.3),
                      ),
                      child: Image.network(
                        "https://img.goodfon.com/original/1920x1080/0/64/listia-fon-background-leaves-still-life-kompozitsiia-dark-ba.jpg",
                        fit: BoxFit.cover,
                        opacity: const AlwaysStoppedAnimation(0.5),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                child: _buildGlassmorphicContainer(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Environmental Appraisals',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isDense: true,
                                  hint: Text(
                                    "Filter",
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.8),
                                    ),
                                  ),
                                  icon: Icon(
                                    Icons.arrow_drop_down,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  dropdownColor:
                                      Colors.green.shade900.withOpacity(0.9),
                                  items: <String>[
                                    'Most Recent',
                                    'Most Upvoted',
                                    'My Location'
                                  ].map((String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    );
                                  }).toList(),
                                  onChanged: (_) {},
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Recognize and appreciate those making a difference in environmental conservation',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: StreamBuilder<QuerySnapshot>(
                stream: _appraisalsCollection
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'Error loading appraisals: ${snapshot.error}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text(
                          'No appraisals found. Be the first to create one!',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final data = doc.data() as Map<String, dynamic>;

                        String timeAgo = data['timeAgo'] ?? 'recent';
                        if (data['timestamp'] != null) {
                          timeAgo = _getTimeAgo(data['timestamp'] as Timestamp);
                        }

                        // Create appraisal model from Firestore document
                        final post = AppraisalPost(
                          id: doc.id,
                          username: data['username'] ?? 'Anonymous',
                          title: data['title'] ?? 'Untitled',
                          description: data['description'] ?? '',
                          imageUrl: data['imageUrl'] ?? '',
                          upvotes: data['upvotes'] ?? 0,
                          timeAgo: timeAgo,
                          tags: List<String>.from(data['tags'] ?? []),
                        );

                        return AppraisalPostCard(post: post);
                      },
                      childCount: snapshot.data!.docs.length,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

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
        if (hasSelectedImage) // If an image is selected, show it
          Stack(
            children: [
              Container(
                constraints: const BoxConstraints(
                  minHeight: 220,
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
                  onTap: _removeImage, // Function to remove the image
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

  Widget _buildSelectedImagePreview() {
    // If no image is selected, return an empty container
    if (!hasSelectedImage) return Container();

    if (kIsWeb) {
      // For web, always use the XFile and read as bytes
      return FutureBuilder<Uint8List>(
        future: _selectedImageXFile!.readAsBytes(), // Read the XFile as bytes
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
                snapshot.data!, // Display the image from bytes
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
      // For mobile, use file image (this part works as before for mobile)
      if (_selectedImageFile != null) {
        return Center(
          child: Image.file(
            _selectedImageFile!, // Use file image for mobile
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
    required String label,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ClipRRect(
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
                  borderSide: BorderSide(
                    color: Colors.green.shade300,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AppraisalPost {
  final String id;
  final String username;
  final String title;
  final String description;
  final String imageUrl;
  int upvotes;
  final String timeAgo;
  final List<String> tags;

  AppraisalPost({
    required this.id,
    required this.username,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.upvotes,
    required this.timeAgo,
    required this.tags,
  });
}

class AppraisalPostCard extends StatefulWidget {
  final AppraisalPost post;

  const AppraisalPostCard({super.key, required this.post});

  @override
  State<AppraisalPostCard> createState() => _AppraisalPostCardState();
}

class _AppraisalPostCardState extends State<AppraisalPostCard> {
  bool _hasUpvoted = false;

  // Firestore reference
  final CollectionReference _appraisalsCollection =
      FirebaseFirestore.instance.collection('appraisals');

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: _buildGlassmorphicContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green.shade600,
                child: Text(
                  widget.post.username[0],
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              title: Text(
                widget.post.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                widget.post.timeAgo,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white.withOpacity(0.8),
                ),
                onPressed: () {
                  // Show options menu
                  _showOptionsMenu();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                widget.post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                widget.post.description,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
            ),
            if (widget.post.imageUrl.isNotEmpty)
              GestureDetector(
                onTap: () {
                  // Show image in full screen
                  _showFullScreenImage(context, widget.post.imageUrl);
                },
                child: Container(
                  constraints: const BoxConstraints(
                    maxHeight: 400,
                  ),
                  width: double.infinity,
                  child: CachedNetworkImage(
                    imageUrl: widget.post.imageUrl,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Container(
                      color: Colors.black12,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.black12,
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      _hasUpvoted ? Icons.thumb_up : Icons.thumb_up_outlined,
                      color: _hasUpvoted ? Colors.green : Colors.white,
                    ),
                    onPressed: _toggleUpvote,
                  ),
                  Text(
                    widget.post.upvotes.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: Icon(
                      Icons.comment_outlined,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    onPressed: () {
                      // Show comments
                    },
                  ),
                  Text(
                    "0", // Placeholder for comment count
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: Icon(
                      Icons.share_outlined,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    onPressed: () {
                      // Share functionality
                    },
                  ),
                ],
              ),
            ),
            if (widget.post.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.post.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Text(
                        '#$tag',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Toggle upvote
  void _toggleUpvote() {
    setState(() {
      if (_hasUpvoted) {
        widget.post.upvotes--;
      } else {
        widget.post.upvotes++;
      }
      _hasUpvoted = !_hasUpvoted;
    });

    // Update upvote count in Firestore
    _appraisalsCollection.doc(widget.post.id).update({
      'upvotes': widget.post.upvotes,
    });
  }

  // Show options menu
  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.green.shade900.withOpacity(0.95),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.bookmark_outline,
                  color: Colors.white,
                ),
                title: const Text(
                  'Save post',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Save post functionality
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.flag_outlined,
                  color: Colors.white,
                ),
                title: const Text(
                  'Report post',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  // Report post functionality
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show full screen image
  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
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
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
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
}
