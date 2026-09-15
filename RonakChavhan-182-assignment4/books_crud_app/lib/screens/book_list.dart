import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import '../services/api_service.dart';
import '../widgets/book_card.dart';
import '../widgets/empty_state.dart';
import 'add_book.dart';
import 'book_detail.dart';

/// Main screen displaying book catalog with search, filter, and CRUD navigation
class BookListScreen extends StatefulWidget {
  const BookListScreen({super.key});

  @override
  State<BookListScreen> createState() => _BookListScreenState();
}

class _BookListScreenState extends State<BookListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Load books on initial screen render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookProvider>().fetchBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Dialog allowing user/student to easily configure the backend URL
  void _showServerConfigDialog() {
    final textController = TextEditingController(text: ApiService.baseUrl);
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.settings_ethernet_rounded, color: Colors.indigo),
            SizedBox(width: 8),
            Text('API Configuration', style: TextStyle(fontSize: 18)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Node.js backend base URL:',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: 'http://localhost:5050/api',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.link_rounded),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Quick presets:\n'
              '• Android Emulator: http://10.0.2.2:5050/api\n'
              '• iOS / macOS / Web: http://localhost:5050/api\n'
              '• Physical Device: http://<YOUR_IP>:5050/api',
              style: TextStyle(fontSize: 11, color: Colors.black54),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ApiService.resetBaseUrl();
              Navigator.pop(dialogCtx);
              context.read<BookProvider>().fetchBooks();
            },
            child: const Text('Reset Default'),
          ),
          FilledButton(
            onPressed: () {
              final newUrl = textController.text.trim();
              if (newUrl.isNotEmpty) {
                ApiService.setCustomBaseUrl(newUrl);
                Navigator.pop(dialogCtx);
                context.read<BookProvider>().fetchBooks();
              }
            },
            child: const Text('Save & Reload'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = context.watch<BookProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.auto_stories_rounded, size: 26),
            const SizedBox(width: 10),
            const Text('Books Library'),
            const SizedBox(width: 8),
            if (!provider.isLoading && provider.totalCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${provider.totalCount}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Server Settings',
            icon: const Icon(Icons.settings_outlined),
            onPressed: _showServerConfigDialog,
          ),
          IconButton(
            tooltip: 'Refresh Books',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => provider.fetchBooks(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search & Filter Header Section
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            color: theme.colorScheme.surface,
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  onChanged: (query) => provider.setSearchQuery(query),
                  decoration: InputDecoration(
                    hintText: 'Search by title, author, ISBN, or genre...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded),
                            onPressed: () {
                              _searchController.clear();
                              provider.setSearchQuery('');
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Horizontal Genre Filter Chips
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: kAvailableGenres.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final genre = kAvailableGenres[index];
                      final isSelected = provider.selectedGenre == genre;
                      return ChoiceChip(
                        label: Text(genre),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            provider.setSelectedGenre(genre);
                          }
                        },
                        selectedColor: theme.colorScheme.primaryContainer,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.onPrimaryContainer
                              : theme.colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Content Area
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => provider.fetchBooks(),
              child: Builder(
                builder: (context) {
                  // 1. Initial Loading State
                  if (provider.isLoading && provider.books.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Loading library books...'),
                        ],
                      ),
                    );
                  }

                  // 2. Error State
                  if (provider.hasError && provider.books.isEmpty) {
                    return ErrorStateWidget(
                      errorMessage: provider.errorMessage!,
                      onRetry: () => provider.fetchBooks(),
                    );
                  }

                  final books = provider.filteredBooks;

                  // 3. Empty State (No books at all OR No search results)
                  if (books.isEmpty) {
                    final isFiltering = provider.searchQuery.isNotEmpty || provider.selectedGenre != 'All';
                    return LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(minHeight: constraints.maxHeight),
                          child: EmptyStateWidget(
                            isSearchResult: isFiltering,
                            onAction: () {
                              if (isFiltering) {
                                _searchController.clear();
                                provider.clearFilters();
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => const AddBookScreen()),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    );
                  }

                  // 4. Book List View
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: books.length,
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return BookCard(
                        book: book,
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookDetailScreen(bookId: book.id),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddBookScreen()),
          );
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Book'),
        tooltip: 'Add a new book',
      ),
    );
  }
}
