const { initializeApp, cert, applicationDefault, getApps } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const path = require('path');
const fs = require('fs');

/**
 * Initialize Firebase Admin SDK & Cloud Firestore
 * Supports loading credentials from:
 * 1. FIREBASE_SERVICE_ACCOUNT_PATH (specified in .env)
 * 2. serviceAccountKey.json located in the backend root
 * 3. Individual environment variables (FIREBASE_PROJECT_ID, FIREBASE_CLIENT_EMAIL, FIREBASE_PRIVATE_KEY)
 * 4. Google Application Default Credentials (GOOGLE_APPLICATION_CREDENTIALS)
 */

let db = null;
let isInitialized = false;

try {
  const serviceAccountPath = process.env.FIREBASE_SERVICE_ACCOUNT_PATH || path.join(__dirname, '../../serviceAccountKey.json');
  const resolvedPath = path.resolve(serviceAccountPath);

  if (fs.existsSync(resolvedPath)) {
    // 1. Load from service account JSON file
    const serviceAccount = require(resolvedPath);
    if (!getApps().length) {
      initializeApp({
        credential: cert(serviceAccount),
      });
    }
    isInitialized = true;
    db = getFirestore();
    console.log(`[Firebase] Initialized successfully using key file: ${path.basename(resolvedPath)}`);
  } else if (process.env.FIREBASE_PROJECT_ID && process.env.FIREBASE_CLIENT_EMAIL && process.env.FIREBASE_PRIVATE_KEY) {
    // 2. Load from individual environment variables
    if (!getApps().length) {
      initializeApp({
        credential: cert({
          projectId: process.env.FIREBASE_PROJECT_ID,
          clientEmail: process.env.FIREBASE_CLIENT_EMAIL,
          privateKey: process.env.FIREBASE_PRIVATE_KEY.replace(/\\n/g, '\n'),
        }),
      });
    }
    isInitialized = true;
    db = getFirestore();
    console.log(`[Firebase] Initialized successfully using environment variables for project: ${process.env.FIREBASE_PROJECT_ID}`);
  } else if (process.env.GOOGLE_APPLICATION_CREDENTIALS) {
    // 3. Load from Google Application Default Credentials
    if (!getApps().length) {
      initializeApp({
        credential: applicationDefault(),
      });
    }
    isInitialized = true;
    db = getFirestore();
    console.log('[Firebase] Initialized successfully using Google Application Default Credentials');
  } else {
    console.warn(
      '\n====================================================================\n' +
      '[Firebase Warning] No Firebase credentials found!\n' +
      'To connect to real Firestore:\n' +
      '  1. Download your serviceAccountKey.json from Firebase Console:\n' +
      '     Project Settings -> Service Accounts -> Generate New Private Key\n' +
      '  2. Place it in the backend/ folder as "serviceAccountKey.json"\n' +
      '  3. Or configure .env with FIREBASE_SERVICE_ACCOUNT_PATH\n' +
      '====================================================================\n'
    );
    try {
      if (!getApps().length) {
        initializeApp();
      }
      db = getFirestore();
    } catch {
      // Ignore if credentials missing
    }
  }

  if (db && typeof db.settings === 'function') {
    db.settings({ ignoreUndefinedProperties: true });
  }
} catch (error) {
  console.error('[Firebase Error] Failed to initialize Firebase Admin SDK:', error.message);
}

module.exports = {
  getDb: () => db,
  get db() {
    return db;
  },
  isFirebaseInitialized: () => isInitialized,
};
