const { getDb } = require('../config/firebase');

const COLLECTION_NAME = 'books';

/**
 * Format a Firestore DocumentSnapshot into a clean JS object
 * @param {FirebaseFirestore.DocumentSnapshot} doc
 * @returns {Object}
 */
const formatBookDoc = (doc) => {
  if (!doc.exists) return null;
  const data = doc.data();
  return {
    id: doc.id,
    title: data.title || '',
    author: data.author || '',
    isbn: data.isbn || '',
    genre: data.genre || '',
    price: typeof data.price === 'number' ? data.price : parseFloat(data.price) || 0,
    quantity: typeof data.quantity === 'number' ? data.quantity : parseInt(data.quantity, 10) || 0,
    description: data.description || '',
    publisher: data.publisher || '',
    publishedDate: data.publishedDate || '',
    coverImageUrl: data.coverImageUrl || '',
    createdAt: data.createdAt || null,
    updatedAt: data.updatedAt || null,
  };
};

/**
 * Ensure Firestore instance is ready
 */
const ensureDb = () => {
  const db = getDb();
  if (!db) {
    throw new Error(
      'Firestore database is not initialized. Please provide serviceAccountKey.json or set FIREBASE credentials in .env'
    );
  }
  return db;
};

/**
 * Book Model: Centralized Firestore operations for books collection
 */
const BookModel = {
  /**
   * Get all books from Firestore
   * @returns {Promise<Array>}
   */
  async getAllBooks() {
    const db = ensureDb();
    const snapshot = await db.collection(COLLECTION_NAME).orderBy('createdAt', 'desc').get();
    return snapshot.docs.map(formatBookDoc);
  },

  /**
   * Get a single book by Firestore document ID
   * @param {string} id
   * @returns {Promise<Object|null>}
   */
  async getBookById(id) {
    const db = ensureDb();
    if (!id || typeof id !== 'string') return null;
    const doc = await db.collection(COLLECTION_NAME).doc(id).get();
    if (!doc.exists) return null;
    return formatBookDoc(doc);
  },

  /**
   * Find a book by ISBN (for uniqueness check)
   * @param {string} isbn
   * @param {string} [excludeId] Optional document ID to exclude (used during updates)
   * @returns {Promise<Object|null>}
   */
  async findByIsbn(isbn, excludeId = null) {
    const db = ensureDb();
    if (!isbn) return null;
    const trimmedIsbn = isbn.trim();
    const snapshot = await db.collection(COLLECTION_NAME).where('isbn', '==', trimmedIsbn).get();
    
    if (snapshot.empty) return null;

    if (excludeId) {
      const match = snapshot.docs.find((doc) => doc.id !== excludeId);
      return match ? formatBookDoc(match) : null;
    }

    return formatBookDoc(snapshot.docs[0]);
  },

  /**
   * Create a new book document in Firestore
   * @param {Object} data
   * @returns {Promise<Object>}
   */
  async createBook(data) {
    const db = ensureDb();
    const now = new Date().toISOString();

    const bookPayload = {
      title: data.title.trim(),
      author: data.author.trim(),
      isbn: data.isbn.trim(),
      genre: data.genre.trim(),
      price: Number(parseFloat(data.price).toFixed(2)),
      quantity: parseInt(data.quantity, 10),
      description: data.description ? data.description.trim() : '',
      publisher: data.publisher ? data.publisher.trim() : '',
      publishedDate: data.publishedDate ? data.publishedDate.trim() : '',
      coverImageUrl: data.coverImageUrl ? data.coverImageUrl.trim() : '',
      createdAt: now,
      updatedAt: now,
    };

    const docRef = await db.collection(COLLECTION_NAME).add(bookPayload);
    const doc = await docRef.get();
    return formatBookDoc(doc);
  },

  /**
   * Update an existing book document in Firestore
   * @param {string} id
   * @param {Object} data
   * @returns {Promise<Object|null>}
   */
  async updateBook(id, data) {
    const db = ensureDb();
    const docRef = db.collection(COLLECTION_NAME).doc(id);
    const existing = await docRef.get();

    if (!existing.exists) return null;

    const now = new Date().toISOString();
    const updatePayload = {
      title: data.title.trim(),
      author: data.author.trim(),
      isbn: data.isbn.trim(),
      genre: data.genre.trim(),
      price: Number(parseFloat(data.price).toFixed(2)),
      quantity: parseInt(data.quantity, 10),
      description: data.description ? data.description.trim() : '',
      publisher: data.publisher ? data.publisher.trim() : '',
      publishedDate: data.publishedDate ? data.publishedDate.trim() : '',
      coverImageUrl: data.coverImageUrl !== undefined ? data.coverImageUrl.trim() : (existing.data().coverImageUrl || ''),
      updatedAt: now,
    };

    await docRef.update(updatePayload);
    const updatedDoc = await docRef.get();
    return formatBookDoc(updatedDoc);
  },

  /**
   * Delete a book document from Firestore
   * @param {string} id
   * @returns {Promise<boolean>}
   */
  async deleteBook(id) {
    const db = ensureDb();
    const docRef = db.collection(COLLECTION_NAME).doc(id);
    const existing = await docRef.get();

    if (!existing.exists) return false;

    await docRef.delete();
    return true;
  },
};

module.exports = BookModel;
