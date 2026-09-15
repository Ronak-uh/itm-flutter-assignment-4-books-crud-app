import 'package:flutter/foundation.dart';
import '../models/book.dart';
import '../services/api_service.dart';

/// Available Genres for filtering and selection
const List<String> kAvailableGenres = [
  'All',
  'Fiction',
  'Non-Fiction',
  'Mystery',
  'Fantasy',
  'Science Fiction',
  'Romance',
  'Biography',
  'History',
  'Self-Help',
  'Other',
];

/// Genres available in Add / Edit forms (excluding 'All')
const List<String> kFormGenres = [
  'Fiction',
  'Non-Fiction',
  'Mystery',
  'Fantasy',
  'Science Fiction',
  'Romance',
  'Biography',
  'History',
  'Self-Help',
  'Other',
];

/// State management Provider for Books CRUD operations and filtering
class BookProvider extends ChangeNotifier {
  final ApiService _apiService;

  List<Book> _books = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _selectedGenre = 'All';

  BookProvider({ApiService? apiService}) : _apiService = apiService ?? ApiService();

  // Getters
  List<Book> get books => _books;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get searchQuery => _searchQuery;
  String get selectedGenre => _selectedGenre;
  bool get hasError => _errorMessage != null;

  /// Returns filtered and searched books based on current criteria
  List<Book> get filteredBooks {
    return _books.where((book) {
      // 1. Genre filter
      final matchesGenre = _selectedGenre == 'All' ||
          book.genre.trim().toLowerCase() == _selectedGenre.trim().toLowerCase();

      // 2. Search query filter (title, author, isbn, genre)
      if (_searchQuery.trim().isEmpty) {
        return matchesGenre;
      }

      final query = _searchQuery.trim().toLowerCase();
      final matchesTitle = book.title.toLowerCase().contains(query);
      final matchesAuthor = book.author.toLowerCase().contains(query);
      final matchesIsbn = book.isbn.toLowerCase().contains(query);
      final matchesBookGenre = book.genre.toLowerCase().contains(query);

      return matchesGenre && (matchesTitle || matchesAuthor || matchesIsbn || matchesBookGenre);
    }).toList();
  }

  /// Total count of all loaded books
  int get totalCount => _books.length;

  /// Count of books currently matching filter/search
  int get filteredCount => filteredBooks.length;

  /// Set search query and notify UI
  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  /// Set selected genre filter and notify UI
  void setSelectedGenre(String genre) {
    _selectedGenre = genre;
    notifyListeners();
  }

  /// Clear all active search and filter controls
  void clearFilters() {
    _searchQuery = '';
    _selectedGenre = 'All';
    notifyListeners();
  }

  /// Clear any error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Fetch all books from the REST API
  Future<void> fetchBooks() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetchedBooks = await _apiService.getBooks();
      _books = fetchedBooks;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _books = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new book via REST API
  Future<bool> addBook(Book newBook) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final createdBook = await _apiService.createBook(newBook);
      // Prepend newly created book to list
      _books.insert(0, createdBook);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Update an existing book via REST API
  Future<bool> updateBook(String id, Book updatedData) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedBook = await _apiService.updateBook(id, updatedData);
      final index = _books.indexWhere((b) => b.id == id);
      if (index != -1) {
        _books[index] = updatedBook;
      }
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Delete a book via REST API
  Future<bool> deleteBook(String id) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteBook(id);
      _books.removeWhere((b) => b.id == id);
      _errorMessage = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
