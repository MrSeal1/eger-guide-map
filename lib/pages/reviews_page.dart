import 'package:flutter/material.dart';
import 'package:maps_testing/data/models/place_review.dart';
import 'package:maps_testing/logic/services/firestore_service.dart';
import 'package:maps_testing/pages/widgets/review_list_item.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Értékeléseim'), centerTitle: true),
      body: FutureBuilder<List<PlaceReview>>(
        future: FirestoreService().getMyReviews(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final reviews = snapshot.data;

          if (reviews == null || reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.star_border,
                    size: 80,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Még nincs megjeleníthető értékelésed.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: reviews.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              return ReviewListItem(
                review: reviews[index],
                showPlaceName: true,
              );
            },
          );
        },
      ),
    );
  }
}
