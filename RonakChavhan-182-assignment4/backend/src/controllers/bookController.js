const BookModel = require('../models/bookModel');

/**
 * Helper to validate book payload
 * @param {Object} data
 * @returns {Array<string>} Array of error messages (empty if valid)
 */
const validateBookInput = (data) => {
  const errors = [];

  if (!data.title || typeof data.title !== 'string' || data.title.trim().length === 0) {
    errors.push('Title is required and cannot be empty');
  }

  if (!data.author || typeof data.author !== 'string' || data.author.trim().length === 0) {
    errors.push('Author is required and cannot be empty');
  }

  if (!data.isbn || typeof data.isbn !== 'string' || data.isbn.trim().length === 0) {
    errors.push('ISBN is required and cannot be empty');
  }

  if (!data.genre || typeof data.genre !== 'string' || data.genre.trim().length === 0) {
    errors.push('Genre is required and cannot be empty');
  }

  if (data.price === undefined || data.price === null || isNaN(Number(data.price)) || Number(data.price) < 0) {
    errors.push('Price must be a valid number greater than or equal to 0');
  }

  if (
    data.quantity === undefined ||
    data.quantity === null ||
    isNaN(Number(data.quantity)) ||
    !Number.isInteger(Number(data.quantity)) ||
    Number(data.quantity) < 0
  ) {
    errors.push('Quantity must be an integer greater than or equal to 0');
  }

  if (!data.publishedDate || typeof data.publishedDate !== 'string' || data.publishedDate.trim().length === 0) {
    errors.push('Published date is required');
  } else {
    const parsedDate = Date.parse(data.publishedDate);
    if (isNaN(parsedDate)) {
      errors.push('Published date must be a valid date format (e.g. YYYY-MM-DD)');
    }
  }

  return errors;
};

/**
 * Controller methods for Book CRUD operations
 */
const BookController = {
  /**
   * GET /api/books
   * Fetch all books
   */
  async getBooks(req, res) {
    try {
      const books = await BookModel.getAllBooks();
      return res.status(200).json({
        success: true,
        count: books.length,
        data: books,
      });
    } catch (error) {
      console.error('[BookController] Error in getBooks:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to retrieve books from database',
        error: error.message,
      });
    }
  },

  /**
   * GET /api/books/:id
   * Fetch single book by ID
   */
  async getBookById(req, res) {
    try {
      const { id } = req.params;
      const book = await BookModel.getBookById(id);

      if (!book) {
        return res.status(404).json({
          success: false,
          message: `Book with ID '${id}' not found`,
        });
      }

      return res.status(200).json({
        success: true,
        data: book,
      });
    } catch (error) {
      console.error(`[BookController] Error in getBookById (${req.params.id}):`, error);
      return res.status(500).json({
        success: false,
        message: 'Failed to retrieve book',
        error: error.message,
      });
    }
  },

  /**
   * POST /api/books
   * Create a new book
   */
  async createBook(req, res) {
    try {
      const validationErrors = validateBookInput(req.body);
      if (validationErrors.length > 0) {
        return res.status(400).json({
          success: false,
          message: validationErrors.join(', '),
          errors: validationErrors,
        });
      }

      // Check ISBN uniqueness
      const existingBookWithIsbn = await BookModel.findByIsbn(req.body.isbn);
      if (existingBookWithIsbn) {
        return res.status(409).json({
          success: false,
          message: `A book with ISBN '${req.body.isbn.trim()}' already exists`,
        });
      }

      const newBook = await BookModel.createBook(req.body);
      return res.status(201).json({
        success: true,
        message: 'Book created successfully',
        data: newBook,
      });
    } catch (error) {
      console.error('[BookController] Error in createBook:', error);
      return res.status(500).json({
        success: false,
        message: 'Failed to create book',
        error: error.message,
      });
    }
  },

  /**
   * PUT /api/books/:id
   * Update an existing book
   */
  async updateBook(req, res) {
    try {
      const { id } = req.params;

      // Check if book exists
      const existingBook = await BookModel.getBookById(id);
      if (!existingBook) {
        return res.status(404).json({
          success: false,
          message: `Book with ID '${id}' not found`,
        });
      }

      // Validate inputs
      const validationErrors = validateBookInput(req.body);
      if (validationErrors.length > 0) {
        return res.status(400).json({
          success: false,
          message: validationErrors.join(', '),
          errors: validationErrors,
        });
      }

      // Check ISBN uniqueness across OTHER books
      const duplicateIsbnBook = await BookModel.findByIsbn(req.body.isbn, id);
      if (duplicateIsbnBook) {
        return res.status(409).json({
          success: false,
          message: `Another book with ISBN '${req.body.isbn.trim()}' already exists`,
        });
      }

      const updatedBook = await BookModel.updateBook(id, req.body);
      return res.status(200).json({
        success: true,
        message: 'Book updated successfully',
        data: updatedBook,
      });
    } catch (error) {
      console.error(`[BookController] Error in updateBook (${req.params.id}):`, error);
      return res.status(500).json({
        success: false,
        message: 'Failed to update book',
        error: error.message,
      });
    }
  },

  /**
   * DELETE /api/books/:id
   * Delete a book
   */
  async deleteBook(req, res) {
    try {
      const { id } = req.params;

      const existingBook = await BookModel.getBookById(id);
      if (!existingBook) {
        return res.status(404).json({
          success: false,
          message: `Book with ID '${id}' not found`,
        });
      }

      const deleted = await BookModel.deleteBook(id);
      if (!deleted) {
        return res.status(500).json({
          success: false,
          message: 'Failed to delete book from database',
        });
      }

      return res.status(200).json({
        success: true,
        message: 'Book deleted successfully',
      });
    } catch (error) {
      console.error(`[BookController] Error in deleteBook (${req.params.id}):`, error);
      return res.status(500).json({
        success: false,
        message: 'Failed to delete book',
        error: error.message,
      });
    }
  },
};

module.exports = BookController;
