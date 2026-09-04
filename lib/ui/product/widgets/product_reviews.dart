import 'package:flutter/material.dart';

import '../../../domain/models/review.dart';
import '../../core/themes/colors.dart';
import '../../core/ui/star_rating.dart';

/// Avis + questions/reponses (lecture).
class ProductReviews extends StatelessWidget {
  const ProductReviews({
    super.key,
    required this.reviews,
    required this.questions,
  });

  final List<Review> reviews;
  final List<ProductQuestion> questions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Avis clients',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        if (reviews.isEmpty)
          const Text('Aucun avis pour le moment.',
              style: TextStyle(color: AppColors.inkSoft))
        else
          for (final r in reviews) _ReviewTile(review: r),
        const SizedBox(height: 24),
        const Text('Questions / reponses',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        if (questions.isEmpty)
          const Text('Aucune question pour ce produit.',
              style: TextStyle(color: AppColors.inkSoft))
        else
          for (final q in questions) _QuestionTile(question: q),
      ],
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            StarRating(value: review.rating.toDouble(), size: 14),
            const Spacer(),
            if (review.verifiedPurchase)
              const Row(children: [
                Icon(Icons.verified, size: 14, color: AppColors.mint),
                SizedBox(width: 4),
                Text('Achat verifie',
                    style: TextStyle(fontSize: 11, color: AppColors.mint)),
              ]),
          ]),
          if (review.title != null && review.title!.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(review.title!,
                style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
          if (review.body != null && review.body!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(review.body!, style: const TextStyle(height: 1.4)),
          ],
          const SizedBox(height: 6),
          Text(review.author ?? 'Client',
              style: const TextStyle(fontSize: 12, color: AppColors.inkSoft)),
        ],
      ),
    );
  }
}

class _QuestionTile extends StatelessWidget {
  const _QuestionTile({required this.question});
  final ProductQuestion question;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.grey1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.help_outline, size: 16, color: AppColors.orange),
            const SizedBox(width: 8),
            Expanded(
                child: Text(question.question,
                    style: const TextStyle(fontWeight: FontWeight.w700))),
          ]),
          for (final a in question.answers)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(a.isVendor ? Icons.storefront : Icons.reply,
                    size: 15,
                    color: a.isVendor ? AppColors.mint : AppColors.inkSoft),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(a.body, style: const TextStyle(height: 1.4)),
                      Text(a.isVendor ? 'Reponse du vendeur' : (a.author ?? ''),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.inkSoft)),
                    ],
                  ),
                ),
              ]),
            ),
        ],
      ),
    );
  }
}
