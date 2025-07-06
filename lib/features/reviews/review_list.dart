import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:goreto/data/providers/review_provider.dart';

class ReviewList extends StatelessWidget {
  final int placeId;

  const ReviewList({super.key, required this.placeId});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ReviewProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reviews",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        provider.isLoading
            ? const Center(child: CircularProgressIndicator())
            : provider.reviews.isEmpty
            ? const Text("No reviews available.")
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.reviews.length,
                itemBuilder: (context, index) {
                  final review = provider.reviews[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      title: Text(review.user.name),
                      subtitle: Text(review.review),
                      trailing: Text(
                        "${review.rating}/5",
                        style: const TextStyle(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  );
                },
              ),
      ],
    );
  }
}
