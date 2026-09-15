const assert = require('assert');

// Test input validation logic
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

console.log('Running Backend Validation Tests...');

// 1. Valid Book
const validBook = {
  title: 'The Great Gatsby',
  author: 'F. Scott Fitzgerald',
  isbn: '9780743273565',
  genre: 'Fiction',
  price: 14.99,
  quantity: 10,
  publishedDate: '1925-04-10',
};
const validErrors = validateBookInput(validBook);
assert.strictEqual(validErrors.length, 0, 'Valid book should have 0 validation errors');
console.log('  ✓ Valid book passes validation');

// 2. Missing Title
const missingTitleBook = { ...validBook, title: '' };
const missingTitleErrors = validateBookInput(missingTitleBook);
assert.ok(missingTitleErrors.some((e) => e.includes('Title is required')));
console.log('  ✓ Missing title is caught');

// 3. Negative Price
const negativePriceBook = { ...validBook, price: -5 };
const negativePriceErrors = validateBookInput(negativePriceBook);
assert.ok(negativePriceErrors.some((e) => e.includes('Price must be a valid number')));
console.log('  ✓ Negative price is rejected');

// 4. Invalid Quantity (decimal)
const decimalQuantityBook = { ...validBook, quantity: 2.5 };
const decimalQuantityErrors = validateBookInput(decimalQuantityBook);
assert.ok(decimalQuantityErrors.some((e) => e.includes('Quantity must be an integer')));
console.log('  ✓ Non-integer quantity is rejected');

// 5. Invalid Published Date
const invalidDateBook = { ...validBook, publishedDate: 'not-a-date' };
const invalidDateErrors = validateBookInput(invalidDateBook);
assert.ok(invalidDateErrors.some((e) => e.includes('valid date format')));
console.log('  ✓ Invalid date string is rejected');

console.log('\nAll Backend Validation Tests Passed Successfully!\n');
