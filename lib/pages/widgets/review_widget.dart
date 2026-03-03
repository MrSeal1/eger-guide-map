import 'package:flutter/material.dart';
import 'package:maps_testing/data/models/place_review.dart';
import 'package:maps_testing/logic/services/firestore_service.dart';

class ReviewWidget extends StatefulWidget {
  final String placeId;
  final String placeName;

  const ReviewWidget({
    super.key,
    required this.placeId,
    required this.placeName,
  });

  @override
  State<ReviewWidget> createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Közösségi értékelések",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            TextButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => _ReviewDialog(
                    placeId: widget.placeId,
                    placeName: widget.placeName,
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text("Írok"),
            ),
          ],
        ),
        const SizedBox(height: 16),

        FutureBuilder<List<PlaceReview>>(
          future: FirestoreService().getReviews(widget.placeId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              debugPrint("Stream hiba: ${snapshot.error}");
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  "Hiba történt: ${snapshot.error}",
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Text("Még nincs értékelés erre a helyre."),
              );
            }

            final reviews = snapshot.data!;

            return ListView.separated(
              shrinkWrap: true,
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const Divider(),
              itemBuilder: (context, index) {
                final review = reviews[index];

                return ListTile(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  title: Row(
                    children: [
                      Text(
                        review.userEmail.split('@')[0],
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),

                      const Spacer(),

                      Row(
                        // az értékeléstől függ, hány csillag lesz kitöltve
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating ? Icons.star : Icons.star_border,
                            size: 16,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                    ],
                  ),

                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: review.comment != null
                        ? Text(review.comment!)
                        : const Text(
                            "A felhasználó nem írt szöveget.",
                            style: TextStyle(fontStyle: FontStyle.italic),
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
}

class _ReviewDialog extends StatefulWidget {
  final String placeId;
  final String placeName;

  const _ReviewDialog({required this.placeId, required this.placeName});

  @override
  State<_ReviewDialog> createState() => __ReviewDialogState();
}

class __ReviewDialogState extends State<_ReviewDialog> {
  int selectedStars = 5;
  final commentController = TextEditingController();
  bool isLoading = false;

  // érdemes a doboz memóriáját manuálisan felszabadítani amikor bezárul a menü
  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    setState(() {
      isLoading = true;
    });

    try {
      final writtenComment = commentController.text.trim();

      final actualComment = writtenComment.isEmpty ? null : writtenComment;

      await FirestoreService().addReview(
        placeId: widget.placeId,
        placeName: widget.placeName,
        rating: selectedStars.toDouble(),
        comment: actualComment,
      );

      // ha megvan a mentés akkor bezárjuk a menüt
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Hiba az értékelés mentése során: $e")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Értékelés írása"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    selectedStars = index + 1;
                  });
                },
                icon: Icon(
                  index < selectedStars ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 32,
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: commentController,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: "Írj szöveget az értékelésednek (opcionális)",
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text("Mégse"),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : submit,
          child: isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text("Küldés"),
        ),
      ],
    );
  }
}
