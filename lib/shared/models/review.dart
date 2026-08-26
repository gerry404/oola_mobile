import '../../core/utils/parse.dart';

/// Avis client sur un produit.
class Review {
  const Review({
    required this.id,
    required this.rating,
    this.title,
    this.body,
    this.author,
    this.verifiedPurchase = false,
    this.helpfulCount = 0,
    this.createdAt,
  });

  final int id;
  final int rating;
  final String? title;
  final String? body;
  final String? author;
  final bool verifiedPurchase;
  final int helpfulCount;
  final DateTime? createdAt;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: asInt(json['id']),
        rating: asInt(json['rating']),
        title: asStringOrNull(json['title']),
        body: asStringOrNull(json['body']),
        author: asStringOrNull(json['author']),
        verifiedPurchase: asBool(json['verified_purchase']),
        helpfulCount: asInt(json['helpful_count']),
        createdAt: asDate(json['created_at']),
      );
}

/// Reponse a une question produit.
class ProductAnswer {
  const ProductAnswer({
    required this.id,
    required this.body,
    this.role,
    this.author,
    this.createdAt,
  });

  final int id;
  final String body;
  final String? role;
  final String? author;
  final DateTime? createdAt;

  bool get isVendor => role == 'vendor';

  factory ProductAnswer.fromJson(Map<String, dynamic> json) => ProductAnswer(
        id: asInt(json['id']),
        body: asString(json['body']),
        role: asStringOrNull(json['role']),
        author: asStringOrNull(json['author']),
        createdAt: asDate(json['created_at']),
      );
}

/// Question posee sur un produit, avec ses reponses.
class ProductQuestion {
  const ProductQuestion({
    required this.id,
    required this.question,
    this.author,
    this.createdAt,
    this.answers = const [],
  });

  final int id;
  final String question;
  final String? author;
  final DateTime? createdAt;
  final List<ProductAnswer> answers;

  factory ProductQuestion.fromJson(Map<String, dynamic> json) => ProductQuestion(
        id: asInt(json['id']),
        question: asString(json['question']),
        author: asStringOrNull(json['author']),
        createdAt: asDate(json['created_at']),
        answers: asList(json['answers'])
            .map((e) => ProductAnswer.fromJson(asMap(e)))
            .toList(),
      );
}
