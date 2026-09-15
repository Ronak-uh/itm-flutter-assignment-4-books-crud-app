import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/book.dart';

/// Custom Exception for API errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

/// Service class responsible for communicating with the Node.js Express REST API.
class ApiService {
  /// Default base URL detection:
  /// - Android emulator uses 10.0.2.2:5000
  /// - iOS simulator / Web / Desktop uses localhost:5000
  /// - Physical device can override via [setCustomBaseUrl]
  static String get defaultBaseUrl {
    if (kIsWeb) {
      return 'http://localhost:5050/api';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:5050/api';
      }
    } catch (_) {
      // Fallback if platform check is unavailable
    }
    return 'http://localhost:5050/api';
  }

  static String _baseUrl = defaultBaseUrl;

  /// Get active base URL
  static String get baseUrl => _baseUrl;

  /// Override base URL (e.g. for physical devices: "http://192.168.1.100:5000/api")
  static void setCustomBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  /// Reset to platform default URL
  static void resetBaseUrl() {
    _baseUrl = defaultBaseUrl;
  }

  final http.Client _client;
  static const Duration _timeout = Duration(seconds: 15);

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Headers sent with JSON requests
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Helper to extract error message from API response body
  String _parseErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      if (body is Map<String, dynamic> && body.containsKey('message')) {
        return body['message'].toString();
      }
    } catch (_) {}
    return 'Server returned error status: ${response.statusCode}';
  }

  /// GET /api/books - Fetch all books
  Future<List<Book>> getBooks() async {
    final uri = Uri.parse('$_baseUrl/books');
    try {
      final response = await _client.get(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] is List) {
          final List list = body['data'];
          return list.map((item) => Book.fromJson(item as Map<String, dynamic>)).toList();
        }
        return [];
      } else {
        throw ApiException(_parseErrorMessage(response), statusCode: response.statusCode);
      }
    } on SocketException {
      throw ApiException(
        'Cannot connect to backend server at $_baseUrl. '
        'Please make sure the Node.js server is running on port 5000.',
      );
    } on TimeoutException {
      throw ApiException('Connection timed out. Please check your network and server.');
    } on FormatException {
      throw ApiException('Failed to parse server response.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  /// GET /api/books/:id - Fetch single book by ID
  Future<Book> getBook(String id) async {
    final uri = Uri.parse('$_baseUrl/books/$id');
    try {
      final response = await _client.get(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return Book.fromJson(body['data'] as Map<String, dynamic>);
        }
        throw ApiException('Malformed book data received from server');
      } else {
        throw ApiException(_parseErrorMessage(response), statusCode: response.statusCode);
      }
    } on SocketException {
      throw ApiException('Unable to connect to backend server.');
    } on TimeoutException {
      throw ApiException('Request timed out.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  /// POST /api/books - Create a new book
  Future<Book> createBook(Book book) async {
    final uri = Uri.parse('$_baseUrl/books');
    try {
      final response = await _client
          .post(
            uri,
            headers: _headers,
            body: jsonEncode(book.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return Book.fromJson(body['data'] as Map<String, dynamic>);
        }
        throw ApiException('Failed to parse created book');
      } else {
        throw ApiException(_parseErrorMessage(response), statusCode: response.statusCode);
      }
    } on SocketException {
      throw ApiException('Unable to connect to backend server.');
    } on TimeoutException {
      throw ApiException('Request timed out.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  /// PUT /api/books/:id - Update an existing book
  Future<Book> updateBook(String id, Book book) async {
    final uri = Uri.parse('$_baseUrl/books/$id');
    try {
      final response = await _client
          .put(
            uri,
            headers: _headers,
            body: jsonEncode(book.toJson()),
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true && body['data'] != null) {
          return Book.fromJson(body['data'] as Map<String, dynamic>);
        }
        throw ApiException('Failed to parse updated book');
      } else {
        throw ApiException(_parseErrorMessage(response), statusCode: response.statusCode);
      }
    } on SocketException {
      throw ApiException('Unable to connect to backend server.');
    } on TimeoutException {
      throw ApiException('Request timed out.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }

  /// DELETE /api/books/:id - Delete a book
  Future<void> deleteBook(String id) async {
    final uri = Uri.parse('$_baseUrl/books/$id');
    try {
      final response = await _client.delete(uri, headers: _headers).timeout(_timeout);

      if (response.statusCode == 200) {
        return;
      } else {
        throw ApiException(_parseErrorMessage(response), statusCode: response.statusCode);
      }
    } on SocketException {
      throw ApiException('Unable to connect to backend server.');
    } on TimeoutException {
      throw ApiException('Request timed out.');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(e.toString());
    }
  }
}
