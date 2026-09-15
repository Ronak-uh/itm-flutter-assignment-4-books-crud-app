import 'package:flutter/material.dart';
import '../models/book.dart';

/// A card widget displaying summary information for a Book
class BookCard extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;

  const BookCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  /// Get color tone for genre tag
  Color _getGenreColor(String genre, ThemeData theme) {
    switch (genre.toLowerCase()) {
      case 'fiction':
        return Colors.indigo;
      case 'non-fiction':
        return Colors.teal;
      case 'mystery':
        return Colors.deepPurple;
      case 'fantasy':
        return Colors.purple;
      case 'science fiction':
        return Colors.blue;
      case 'romance':
        return Colors.pink;
      case 'biography':
        return Colors.amber.shade800;
      case 'history':
        return Colors.brown;
      case 'self-help':
        return Colors.green.shade700;
      default:
        return theme.colorScheme.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final genreColor = _getGenreColor(book.genre, theme);

    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Title and Genre Chip
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Book Icon Thumbnail Container
                  Container(
                    width: 46,
                    height: 58,
                    decoration: BoxDecoration(
                      color: genreColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: genreColor.withValues(alpha: 0.3)),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        color: genreColor,
                        size: 26,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Title and Author
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          book.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person_outline_rounded,
                              size: 15,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                book.author,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Genre and Date Row
              Row(
                children: [
                  // Genre Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: genreColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      book.genre,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: genreColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Published Year
                  Text(
                    'Pub: ${book.publishedDate.year}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Divider(height: 20),
              // Footer: Price and Stock Quantity
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Price
                  Text(
                    book.formattedPrice,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  // Stock Status Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: book.isInStock
                          ? Colors.green.shade50
                          : Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: book.isInStock
                            ? Colors.green.shade300
                            : Colors.red.shade300,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          book.isInStock
                              ? Icons.inventory_2_outlined
                              : Icons.warning_amber_rounded,
                          size: 14,
                          color: book.isInStock
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          book.isInStock
                              ? 'Stock: ${book.quantity}'
                              : 'Out of Stock',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: book.isInStock
                                ? Colors.green.shade800
                                : Colors.red.shade800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
