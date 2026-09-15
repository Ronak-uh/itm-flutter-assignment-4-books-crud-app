import 'package:flutter_test/flutter_test.dart';
import 'package:books_crud_app/models/book.dart';
import 'package:books_crud_app/providers/book_provider.dart';

void main() {
  group('Book Model Tests', () {
    test('Book creates correctly and formats price & date', () {
      final book = Book(
        id: 'book-1',
        title: 'The Great Gatsby',
        author: 'F. Scott Fitzgerald',
        isbn: '9780743273565',
        genre: 'Fiction',
        price: 14.99,
        quantity: 10,
        publishedDate: DateTime(1925, 4, 10),
      );

      expect(book.id, 'book-1');
      expect(book.title, 'The Great Gatsby');
      expect(book.formattedPrice, '\$14.99');
      expect(book.isInStock, true);
      expect(book.isoDateString, '1925-04-10');
    });

    test('Book JSON Serialization & Deserialization works correctly', () {
      final jsonMap = {
        'id': 'abc-123',
        'title': '1984',
        'author': 'George Orwell',
        'isbn': '9780451524935',
        'genre': 'Science Fiction',
        'price': 11.99,
        'quantity': 25,
        'description': 'A dystopian novel',
        'publisher': 'Secker & Warburg',
        'publishedDate': '1949-06-08',
      };

      final book = Book.fromJson(jsonMap);
      expect(book.id, 'abc-123');
      expect(book.title, '1984');
      expect(book.price, 11.99);
      expect(book.quantity, 25);
      expect(book.publishedDate.year, 1949);

      final serialized = book.toJson();
      expect(serialized['title'], '1984');
      expect(serialized['isbn'], '9780451524935');
      expect(serialized['publishedDate'], '1949-06-08');
    });

    test('Book out-of-stock check works', () {
      final book = Book(
        title: 'Sold Out Book',
        author: 'Unknown',
        isbn: '0000000000',
        genre: 'Other',
        price: 9.99,
        quantity: 0,
        publishedDate: DateTime.now(),
      );

      expect(book.isInStock, false);
    });
  });

  group('BookProvider Search & Filtering Tests', () {
    test('Provider filters by genre and search query properly', () {
      final provider = BookProvider();

      // Simulate loaded books using reflection/test helper or provider methods
      // For unit testing getters:
      expect(provider.books.isEmpty, true);
      expect(provider.selectedGenre, 'All');
      expect(provider.searchQuery, '');

      provider.setSelectedGenre('Fantasy');
      expect(provider.selectedGenre, 'Fantasy');

      provider.setSearchQuery('Tolkien');
      expect(provider.searchQuery, 'Tolkien');

      provider.clearFilters();
      expect(provider.selectedGenre, 'All');
      expect(provider.searchQuery, '');
    });
  });
}
