import 'package:intl/intl.dart';

/// Represents a single Book entity in the application.
class Book {
  final String id;
  final String title;
  final String author;
  final String isbn;
  final String genre;
  final double price;
  final int quantity;
  final String description;
  final String publisher;
  final DateTime publishedDate;
  final String? coverImageUrl;

  const Book({
    this.id = '',
    required this.title,
    required this.author,
    required this.isbn,
    required this.genre,
    required this.price,
    required this.quantity,
    this.description = '',
    this.publisher = '',
    required this.publishedDate,
    this.coverImageUrl,
  });

  /// Formatted price with dollar currency symbol ($XX.XX)
  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  /// Human-friendly formatted published date (e.g. "Apr 10, 1925")
  String get formattedPublishedDate {
    try {
      return DateFormat.yMMMMd().format(publishedDate);
    } catch (_) {
      return publishedDate.toIso8601String().split('T').first;
    }
  }

  /// ISO date string format for API payload (YYYY-MM-DD)
  String get isoDateString =>
      '${publishedDate.year.toString().padLeft(4, '0')}-'
      '${publishedDate.month.toString().padLeft(2, '0')}-'
      '${publishedDate.day.toString().padLeft(2, '0')}';

  /// Stock availability status
  bool get isInStock => quantity > 0;

  /// Deserialize from backend JSON response
  factory Book.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    if (json['publishedDate'] != null) {
      parsedDate = DateTime.tryParse(json['publishedDate'].toString()) ?? DateTime.now();
    } else {
      parsedDate = DateTime.now();
    }

    double parsedPrice = 0.0;
    if (json['price'] != null) {
      parsedPrice = (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.tryParse(json['price'].toString()) ?? 0.0;
    }

    int parsedQuantity = 0;
    if (json['quantity'] != null) {
      parsedQuantity = (json['quantity'] is num)
          ? (json['quantity'] as num).toInt()
          : int.tryParse(json['quantity'].toString()) ?? 0;
    }

    return Book(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      author: json['author']?.toString() ?? '',
      isbn: json['isbn']?.toString() ?? '',
      genre: json['genre']?.toString() ?? '',
      price: parsedPrice,
      quantity: parsedQuantity,
      description: json['description']?.toString() ?? '',
      publisher: json['publisher']?.toString() ?? '',
      publishedDate: parsedDate,
      coverImageUrl: json['coverImageUrl']?.toString(),
    );
  }

  /// Serialize to JSON payload for backend REST API
  Map<String, dynamic> toJson() {
    return {
      'title': title.trim(),
      'author': author.trim(),
      'isbn': isbn.trim(),
      'genre': genre.trim(),
      'price': price,
      'quantity': quantity,
      'description': description.trim(),
      'publisher': publisher.trim(),
      'publishedDate': isoDateString,
      if (coverImageUrl != null && coverImageUrl!.isNotEmpty)
        'coverImageUrl': coverImageUrl,
    };
  }

  /// Create a copy with modified fields
  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? isbn,
    String? genre,
    double? price,
    int? quantity,
    String? description,
    String? publisher,
    DateTime? publishedDate,
    String? coverImageUrl,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      isbn: isbn ?? this.isbn,
      genre: genre ?? this.genre,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      description: description ?? this.description,
      publisher: publisher ?? this.publisher,
      publishedDate: publishedDate ?? this.publishedDate,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
    );
  }
}
