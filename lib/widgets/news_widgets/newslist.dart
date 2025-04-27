import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaayusphere/api/news_api_service.dart';

// Image Validation Service
class ImageValidationService {
  Future<bool> isValidImage(String url) async {
    try {
      final uri = Uri.parse(url);
      if (!uri.isAbsolute || (uri.scheme != 'http' && uri.scheme != 'https')) {
        log('❌ Invalid URL scheme for image: $url');
        return false;
      }
      final response = await http.head(uri);
      return response.statusCode == 200;
    } catch (e) {
      log('❌ Error validating image $url: $e');
      return false;
    }
  }
}

class NewsList extends StatefulWidget {
  final List<Article> articles;

  const NewsList({super.key, required this.articles});

  @override
  _NewsListState createState() => _NewsListState();
}

class _NewsListState extends State<NewsList> {
  late Future<List<Article>> _filteredArticles;
  final ImageValidationService _imageValidationService =
      ImageValidationService();

  @override
  void initState() {
    super.initState();
    _filteredArticles = _filterArticlesWithValidImages();
  }

  Future<List<Article>> _filterArticlesWithValidImages() async {
    final futures = widget.articles.map((article) async {
      final imageUrl = article.urlToImage;
      bool isValidImage = false;
      if (imageUrl != null && imageUrl.isNotEmpty) {
        isValidImage = await _imageValidationService.isValidImage(imageUrl);
        if (!isValidImage) {
          log('❌ Article filtered out due to invalid image: ${article.title}');
        }
      }
      return {
        'article': article,
        'isValidImage': isValidImage,
      };
    });

    final results = await Future.wait(futures);
    final validArticles = results
        .where((result) => result['isValidImage'] == true)
        .map((result) => result['article'] as Article)
        .toList();

    final invalidArticles = results
        .where((result) => result['isValidImage'] == false)
        .map((result) => result['article'] as Article)
        .toList();

    // Combine valid and invalid articles, valid ones on top
    return [...validArticles, ...invalidArticles];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Article>>(
      future: _filteredArticles,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return const Center(child: Text('Failed to load news articles.'));
        }

        final filteredArticles = snapshot.data ?? [];
        log('📰 NewsList ready with ${filteredArticles.length} valid articles');

        if (filteredArticles.isEmpty) {
          return const Center(child: Text('No news articles available.'));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(
                'Latest News',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredArticles.length,
              itemBuilder: (_, i) => NewsCard(article: filteredArticles[i]),
            ),
          ],
        );
      },
    );
  }
}

class NewsCard extends StatelessWidget {
  final Article article;

  const NewsCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final dt = DateTime.tryParse(article.publishedAt);
    final date = dt != null ? DateFormat('MMM dd, yyyy').format(dt) : '';

    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(article.url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open article')),
          );
        }
      },
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 8),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  if (date.isNotEmpty)
                    Text(
                      date,
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.grey),
                    ),
                  const SizedBox(height: 8),
                  if (article.description.isNotEmpty)
                    Text(
                      article.description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.black87,
                          ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Image Section with conditional handling for missing images
  Widget _buildImageSection() {
    if (article.urlToImage != null && article.urlToImage!.isNotEmpty) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        child: Image.network(
          article.urlToImage!,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
          loadingBuilder: (_, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 180,
              color: Colors.grey.shade300,
            );
          },
          errorBuilder: (_, __, ___) {
            log('❌ Error loading image: ${article.urlToImage}');
            return Container(
              height: 10,
              color: Colors.grey.shade300,
              alignment: Alignment.center,
              // child: const Icon(Icons.broken_image, size: 48),
            );
          },
        ),
      );
    } else {
      return const SizedBox.shrink(); // No placeholder for missing images
    }
  }
}
