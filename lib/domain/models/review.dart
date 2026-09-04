import '../../utils/parse.dart';

class Review {
  const Review({
    required this.id,
    required this.rating,
    this.title,
    this.body,
    this.author,
    this.verifiedPurchase = false,
  });

  final int id;
  final int rating;
  final String? title;
  final String? body;
  final String? author;
  final bool verifiedPurchase;

  factory Review.fromJson(Map<String, dynamic> json) => Review(
        id: asInt(json['id']),
        rating: asInt(json['rating']),
        title: asStringOrNull(json['title']),
        body: asStringOrNull(json['body']),
        author: asStringOrNull(json['author']),
        verifiedPurchase: asBool(json['verified_purchase']),
      );
}

class ProductAnswer {
  const ProductAnswer({required this.body, this.role, this.author});

  final String body;
  final String? role;
  final String? author;

  bool get isVendor => role == 'vendor';

  factory ProductAnswer.fromJson(Map<String, dynamic> json) => ProductAnswer(
        body: asString(json['body']),
        role: asStringOrNull(json['role']),
        author: asStringOrNull(json['author']),
      );
}

class ProductQuestion {
  const ProductQuestion({
    required this.question,
    this.author,
    this.answers = const [],
  });

  final String question;
  final String? author;
  final List<ProductAnswer> answers;

  factory ProductQuestion.fromJson(Map<String, dynamic> json) => ProductQuestion(
        question: asString(json['question']),
        author: asStringOrNull(json['author']),
        answers: asList(json['answers'])
            .map((e) => ProductAnswer.fromJson(asMap(e)))
            .toList(),
      );
}
