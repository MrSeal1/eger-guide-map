import 'package:flutter/material.dart';
import 'package:maps_testing/data/models/place_review.dart';

class ReviewListItem extends StatelessWidget {
  final PlaceReview review;

  // a hely nevét mutassa-e az értékelő e-mail címe helyett (alapértelmezetten false)
  final bool showPlaceName;

  const ReviewListItem({
    super.key,
    required this.review,
    this.showPlaceName = false,
  });

  @override
  Widget build(BuildContext context) {

    // értéke vagy a hely neve vagy az értékelő neve
    final title = showPlaceName
        ? (review.placeName ?? 'Ismeretlen hely')
        : review.userEmail.split('@')[0];

    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: List.generate(5,
                  (i) => Icon(
                    i < review.rating ? Icons.star : Icons.star_border,
                    size: 16,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (review.comment != null && review.comment!.isNotEmpty)
            Text(review.comment!)
          else
            Text(
              "Csak csillagos értékelés.",
              style: TextStyle(fontStyle: FontStyle.italic, color: theme.hintColor),
            ),
          const SizedBox(height: 8)
        ],
      ),
    );
  }
}
