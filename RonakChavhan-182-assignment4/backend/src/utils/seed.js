require('dotenv').config();
const { db, isFirebaseInitialized } = require('../config/firebase');

const SAMPLE_BOOKS = [
  {
    title: 'The Great Gatsby',
    author: 'F. Scott Fitzgerald',
    isbn: '9780743273565',
    genre: 'Fiction',
    price: 14.99,
    quantity: 15,
    publisher: 'Scribner',
    publishedDate: '1925-04-10',
    description: 'A portrait of the Jazz Age in all its decadence and excess, following the mysterious millionaire Jay Gatsby and his obsession with Daisy Buchanan.',
  },
  {
    title: '1984',
    author: 'George Orwell',
    isbn: '9780451524935',
    genre: 'Science Fiction',
    price: 11.99,
    quantity: 25,
    publisher: 'Secker & Warburg',
    publishedDate: '1949-06-08',
    description: 'A dystopian social science fiction novel and cautionary tale about totalitarianism, mass surveillance, and repressive regimentation.',
  },
  {
    title: 'To Kill a Mockingbird',
    author: 'Harper Lee',
    isbn: '9780060935467',
    genre: 'Fiction',
    price: 13.99,
    quantity: 18,
    publisher: 'J. B. Lippincott & Co.',
    publishedDate: '1960-07-11',
    description: 'A gripping, heart-wrenching story of racial injustice and the destruction of innocence in the American South.',
  },
  {
    title: 'The Hobbit',
    author: 'J.R.R. Tolkien',
    isbn: '9780547928227',
    genre: 'Fantasy',
    price: 15.50,
    quantity: 12,
    publisher: 'George Allen & Unwin',
    publishedDate: '1937-09-21',
    description: 'Bilbo Baggins is a hobbit who enjoys a comfortable, unambitious life until Gandalf and thirteen dwarves sweep him away on an epic journey.',
  },
  {
    title: 'The Da Vinci Code',
    author: 'Dan Brown',
    isbn: '9780307474278',
    genre: 'Mystery',
    price: 9.99,
    quantity: 20,
    publisher: 'Doubleday',
    publishedDate: '2003-03-18',
    description: 'Symbologist Robert Langdon and cryptologist Sophie Neveu investigate a murder in the Louvre Museum, uncovering a battle between the Priory of Sion and Opus Dei.',
  },
  {
    title: 'Sapiens: A Brief History of Humankind',
    author: 'Yuval Noah Harari',
    isbn: '9780062316097',
    genre: 'History',
    price: 18.99,
    quantity: 8,
    publisher: 'Harper',
    publishedDate: '2014-02-10',
    description: 'Explores how biology and history have defined us and enhanced our understanding of what it means to be human.',
  },
  {
    title: 'Atomic Habits',
    author: 'James Clear',
    isbn: '9780735211292',
    genre: 'Self-Help',
    price: 16.20,
    quantity: 30,
    publisher: 'Avery',
    publishedDate: '2018-10-16',
    description: 'A supremely practical framework for improving every day through small changes that deliver remarkable results.',
  },
  {
    title: 'Steve Jobs',
    author: 'Walter Isaacson',
    isbn: '9781451648539',
    genre: 'Biography',
    price: 17.50,
    quantity: 10,
    publisher: 'Simon & Schuster',
    publishedDate: '2011-10-24',
    description: 'The exclusive biography based on more than forty interviews with Steve Jobs conducted over two years.',
  },
];

async function seedDatabase() {
  console.log('[Seed] Starting database seeding process...');

  if (!db) {
    console.error('[Seed Error] Firebase Firestore is not initialized. Please verify credentials.');
    process.exit(1);
  }

  try {
    const booksCollection = db.collection('books');
    let inserted = 0;
    let skipped = 0;

    for (const book of SAMPLE_BOOKS) {
      // Check if book with this ISBN already exists
      const existing = await booksCollection.where('isbn', '==', book.isbn).get();
      if (existing.empty) {
        const now = new Date().toISOString();
        await booksCollection.add({
          ...book,
          createdAt: now,
          updatedAt: now,
        });
        console.log(`  ✓ Inserted: "${book.title}" (ISBN: ${book.isbn})`);
        inserted++;
      } else {
        console.log(`  - Skipped (already exists): "${book.title}" (ISBN: ${book.isbn})`);
        skipped++;
      }
    }

    console.log(`\n[Seed Complete] Successfully inserted ${inserted} books, skipped ${skipped} existing books.`);
    process.exit(0);
  } catch (error) {
    console.error('[Seed Error] Failed to seed database:', error);
    process.exit(1);
  }
}

seedDatabase();
