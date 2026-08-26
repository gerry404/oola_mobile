import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../../../../shared/models/review.dart';
import '../../../../shared/widgets/star_rating.dart';
import '../../application/catalog_providers.dart';

/// Bloc avis + questions/reponses d'un produit (lecture).
class ProductReviews extends ConsumerWidget {
  const ProductReviews({super.key, required this.slug});
  final String slug;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviews = ref.watch(productReviewsProvider(slug));
    final questions = ref.watch(productQuestionsProvider(slug));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Avis clients',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        reviews.when(
          loading: () => const _MiniLoader(),
          error: (_, __) => const Text('Avis indisponibles pour le moment.',
              style: TextStyle(color: AppColors.inkSoft)),
          data: (list) {
            if (list.isEmpty) {
              return const Text('Aucun avis pour le moment.',
                  style: TextStyle(color: AppColors.inkSoft));
            }
            return Column(
              children: [for (final r in list) _ReviewTile(review: r)],
            );
          },
        ),
        const SizedBox(height: 24),
        const Text('Questions / reponses',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        questions.when(
          loading: () => const _MiniLoader(),
          error: (_, __) => const Text('Questions indisponibles.',
              style: TextStyle(color: AppColors.inkSoft)),
          data: (list) {
            if (list.isEmpty) {
              return const Text('Aucune question pour ce produit.',
                  style: TextStyle(color: AppColors.inkSoft));
            }
            return Column(
              children: [for (final q in list) _QuestionTile(question: q)],
            );
          },
        ),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StarRating(value: review.rating.toDouble(), size: 14),
              const Spacer(),
              if (review.verifiedPurchase)
                const Row(
                  children: [
                    Icon(Icons.verified, size: 14, color: AppColors.mint),
                    SizedBox(width: 4),
                    Text('Achat verifie',
                        style: TextStyle(fontSize: 11, color: AppColors.mint)),
                  ],
                ),
            ],
          ),
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
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gray100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.help_outline, size: 16, color: AppColors.orange),
              const SizedBox(width: 8),
              Expanded(
                child: Text(question.question,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          for (final a in question.answers)
            Padding(
              padding: const EdgeInsets.only(left: 24, top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    a.isVendor ? Icons.storefront : Icons.reply,
                    size: 15,
                    color: a.isVendor ? AppColors.mint : AppColors.inkSoft,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(a.body, style: const TextStyle(height: 1.4)),
                        Text(
                          a.isVendor ? 'Reponse du vendeur' : (a.author ?? ''),
                          style: const TextStyle(
                              fontSize: 11, color: AppColors.inkSoft),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _MiniLoader extends StatelessWidget {
  const _MiniLoader();
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.orange),
        ),
      );
}
