const express = require('express');
const router = express.Router();
const BookController = require('../controllers/bookController');

/**
 * Books API Routes
 * Base Path: /api/books
 */

// GET /api/books - Get all books
router.get('/', BookController.getBooks);

// GET /api/books/:id - Get single book by ID
router.get('/:id', BookController.getBookById);

// POST /api/books - Create new book
router.post('/', BookController.createBook);

// PUT /api/books/:id - Update existing book
router.put('/:id', BookController.updateBook);

// DELETE /api/books/:id - Delete book
router.delete('/:id', BookController.deleteBook);

module.exports = router;
