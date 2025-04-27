import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vaayusphere/api/news_api_service.dart';

class InfoFocusCard extends StatelessWidget {
  final Article? featuredArticle;

  const InfoFocusCard({
    super.key,
    this.featuredArticle,
  });

  @override
  Widget build(BuildContext context) {
    if (featuredArticle == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: Text('No featured article available'),
        ),
      );
    }

    // Format the date
    final DateTime publishDate = DateTime.parse(featuredArticle!.publishedAt);
    final String formattedDate = DateFormat('MMM dd, yyyy').format(publishDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Text(
            'Featured Story',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () async {
              if (featuredArticle!.url.isNotEmpty) {
                final Uri url = Uri.parse(featuredArticle!.url);
                if (await canLaunchUrl(url)) {
                  await launchUrl(url);
                }
              }
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (featuredArticle!.urlToImage != null)
                  Container(
                    height: 250,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(featuredArticle!.urlToImage!),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.all(16),
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        featuredArticle!.source.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        featuredArticle!.title,
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        formattedDate,
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        featuredArticle!.description,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        featuredArticle!.content,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 6,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 20),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        onPressed: () async {
                          if (featuredArticle!.url.isNotEmpty) {
                            final Uri url = Uri.parse(featuredArticle!.url);
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          }
                        },
                        child: const Text('Read Full Article'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
