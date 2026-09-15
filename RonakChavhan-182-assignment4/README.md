# 📚 Books CRUD Full-Stack Application

A modern, student-friendly, and production-ready **Full-Stack Books CRUD Application** built with **Flutter** for the mobile frontend, **Node.js + Express Server (Port 5050)** for the REST API backend, and **Firebase Cloud Firestore** for persistent cloud database storage.

---

## 🏛️ Architecture Overview

The system strictly follows the full-stack multi-tier architecture pattern:

```text
┌──────────────────────────────────────────────────────────┐
│                   Flutter Mobile App                     │
│  (Material 3 UI • Provider State Management • ApiService) │
└────────────────────────────┬─────────────────────────────┘
                             │  HTTP REST Requests (JSON)
                             ▼
┌──────────────────────────────────────────────────────────┐
│               Node.js + Express Backend                  │
│       (Express 5 • CORS • Validation • Controllers)       │
└────────────────────────────┬─────────────────────────────┘
                             │  Firebase Admin SDK
                             ▼
┌──────────────────────────────────────────────────────────┐
│                Firebase Cloud Firestore                  │
│           ('books' Collection Document Store)            │
└──────────────────────────────────────────────────────────┘
```

> [!NOTE]
> All book operations flow through the Node.js REST API. The Flutter app never accesses Firebase credentials or direct Firestore references directly, ensuring security and proper separation of concerns.

---

## ✨ Features

- **📖 View Book Catalog:** Browse all library books with real-time stock indicators, genre tags, and formatted pricing.
- **🔍 Search:** Instant, case-insensitive search across title, author, ISBN, and genre.
- **🏷️ Genre Filtering:** Dynamic horizontal filter chips for categories (`Fiction`, `Non-Fiction`, `Mystery`, `Fantasy`, `Science Fiction`, `Romance`, `Biography`, `History`, `Self-Help`, `Other`).
- **➕ Add Book:** Full-featured form with dropdowns, custom date picker, and input validations (title, author, ISBN, price, quantity, publisher, description).
- **✏️ Edit Book:** Pre-populated edit screen to update book details with duplicate-ISBN prevention.
- **🗑️ Delete Book:** Safe deletion workflow with a confirmation dialog and visual feedback.
- **🔄 Pull to Refresh:** Smooth pull-to-refresh integration with `RefreshIndicator`.
- **⚡ Reactive Feedback:** Material SnackBars for creation, update, deletion, and error notifications.
- **🛡️ State & Error Handling:** Gracefully handles loading spinners, empty search results, empty library states, and server connection failures.
- **⚙️ Configurable API Base URL:** Built-in dialog to toggle between `localhost`, `10.0.2.2` (Android Emulator), or custom LAN IP.

---

## 📁 Project Directory Structure

```text
books-crud-application/
│
├── backend/                             # Node.js + Express REST API
│   ├── src/
│   │   ├── config/
│   │   │   └── firebase.js              # Firebase Admin SDK & Firestore initialization
│   │   ├── controllers/
│   │   │   └── bookController.js        # CRUD handlers, validations, ISBN uniqueness
│   │   ├── models/
│   │   │   └── bookModel.js             # Firestore data access layer
│   │   ├── routes/
│   │   │   └── bookRoutes.js            # Express endpoint routing
│   │   └── utils/
│   │       └── seed.js                  # Database seed script with sample books
│   ├── test/
│   │   └── bookController.test.js       # Backend validation unit tests
│   ├── .env.example                     # Environment variables template
│   ├── .gitignore                       # Ignored node_modules, keys, .env
│   ├── package.json                     # Dependencies & npm scripts
│   └── server.js                        # Express server entry point
│
├── books_crud_app/                      # Flutter Frontend Application
│   ├── lib/
│   │   ├── models/
│   │   │   └── book.dart                # Book data model & JSON serializers
│   │   ├── providers/
│   │   │   └── book_provider.dart       # State management (ChangeNotifier)
│   │   ├── screens/
│   │   │   ├── add_book.dart            # Add book form screen with validation
│   │   │   ├── book_detail.dart         # Detail view with edit & delete actions
│   │   │   ├── book_list.dart           # Home catalog screen with search & filter
│   │   │   └── edit_book.dart           # Edit existing book form screen
│   │   ├── services/
│   │   │   └── api_service.dart         # HTTP REST communication client
│   │   ├── widgets/
│   │   │   ├── book_card.dart           # Book summary item card
│   │   │   └── empty_state.dart         # Empty & error state placeholder widgets
│   │   └── main.dart                    # App entry point & Material 3 theme
│   ├── test/
│   │   ├── unit_test.dart               # Dart model & provider unit tests
│   │   └── widget_test.dart             # Flutter UI widget test
│   └── pubspec.yaml                     # Flutter dependencies
│
└── README.md                            # Complete Project Documentation
```

---

## 📋 Prerequisites

Before running the application, ensure you have:

1. **Node.js** (v18 or higher) & **npm**
2. **Flutter SDK** (v3.0 or higher) & **Dart SDK**
3. A **Firebase Account** (free tier / Spark plan)

---

## 🔥 Step 1: Firebase & Firestore Setup

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Create a project** (or add to an existing project) and name it (e.g. `books-crud-db`).
3. Under the **Build** menu on the left sidebar, click **Firestore Database**.
4. Click **Create database**, select a nearby location, and start in **Test mode** (or Production mode).
5. Click on the ⚙️ **Settings icon** next to *Project Overview* -> **Project settings**.
6. Select the **Service accounts** tab.
7. Click **Generate new private key** and confirm by clicking **Generate key**.
8. A JSON file will download (e.g. `your-project-firebase-adminsdk-xxx.json`).
9. Rename this file to:
   ```text
   serviceAccountKey.json
   ```
10. Move `serviceAccountKey.json` into the `backend/` directory:
    ```text
    books-crud-application/backend/serviceAccountKey.json
    ```

> [!TIP]
> The backend automatically detects `serviceAccountKey.json` located in `backend/`!

---

## 💻 Step 2: Backend Setup & Execution

1. Open a terminal and navigate to the `backend/` folder:
   ```bash
   cd backend
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. (Optional) Create your `.env` file from the example:
   ```bash
   cp .env.example .env
   ```

4. **Seed Sample Books (Optional)**:
   Populate your Firestore database with 8 sample books:
   ```bash
   npm run seed
   ```

5. **Start the Backend Server**:
   ```bash
   npm start
   ```
   Or run in watch mode for development:
   ```bash
   npm run dev
   ```

6. Verify server health in your browser or with cURL:
   ```bash
   curl http://localhost:5000/api/health
   ```
   Expected Response:
   ```json
   {
     "success": true,
     "message": "Books API is running",
     "firebaseConnected": true
   }
   ```

---

## 📱 Step 3: Flutter App Setup & Execution

1. Open a new terminal and navigate to the `books_crud_app/` folder:
   ```bash
   cd books_crud_app
   ```

2. Fetch Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. **Configure API Base URL**:
   The app automatically selects the correct URL based on your target platform:
   - **macOS / iOS Simulator / Web / Windows / Linux**: `http://localhost:5000/api`
   - **Android Emulator**: `http://10.0.2.2:5000/api`
   - **Physical Device**: Tap the **⚙️ Settings icon** in the app's top bar to enter your computer's local Wi-Fi IP (e.g., `http://192.168.1.150:5000/api`).

4. **Launch the Application**:
   ```bash
   # Run on connected device or simulator
   flutter run
   ```

---

## 📡 REST API Reference

Base URL: `http://localhost:5000/api/books`

### 1. Health Check
- **Method:** `GET`
- **Path:** `/api/health`
- **Response:** `200 OK`
```json
{
  "success": true,
  "message": "Books API is running",
  "firebaseConnected": true
}
```

---

### 2. Get All Books
- **Method:** `GET`
- **Path:** `/api/books`
- **cURL:**
  ```bash
  curl -X GET http://localhost:5000/api/books
  ```
- **Response:** `200 OK`
```json
{
  "success": true,
  "count": 1,
  "data": [
    {
      "id": "abc123DocId",
      "title": "The Great Gatsby",
      "author": "F. Scott Fitzgerald",
      "isbn": "9780743273565",
      "genre": "Fiction",
      "price": 14.99,
      "quantity": 15,
      "description": "A classic American novel set in the Jazz Age.",
      "publisher": "Scribner",
      "publishedDate": "1925-04-10",
      "coverImageUrl": "",
      "createdAt": "2026-09-04T12:00:00.000Z",
      "updatedAt": "2026-09-04T12:00:00.000Z"
    }
  ]
}
```

---

### 3. Get Single Book by ID
- **Method:** `GET`
- **Path:** `/api/books/:id`
- **cURL:**
  ```bash
  curl -X GET http://localhost:5000/api/books/abc123DocId
  ```
- **Response:** `200 OK` (or `404 Not Found` if nonexistent)

---

### 4. Create Book
- **Method:** `POST`
- **Path:** `/api/books`
- **Headers:** `Content-Type: application/json`
- **cURL:**
  ```bash
  curl -X POST http://localhost:5000/api/books \
    -H "Content-Type: application/json" \
    -d '{
      "title": "1984",
      "author": "George Orwell",
      "isbn": "9780451524935",
      "genre": "Science Fiction",
      "price": 11.99,
      "quantity": 25,
      "publisher": "Secker & Warburg",
      "publishedDate": "1949-06-08",
      "description": "A classic dystopian novel."
    }'
  ```
- **Response:** `201 Created`
```json
{
  "success": true,
  "message": "Book created successfully",
  "data": {
    "id": "newDocId123",
    "title": "1984",
    "author": "George Orwell",
    "isbn": "9780451524935",
    "genre": "Science Fiction",
    "price": 11.99,
    "quantity": 25,
    "description": "A classic dystopian novel.",
    "publisher": "Secker & Warburg",
    "publishedDate": "1949-06-08",
    "createdAt": "2026-09-04T12:00:00.000Z",
    "updatedAt": "2026-09-04T12:00:00.000Z"
  }
}
```

---

### 5. Update Book
- **Method:** `PUT`
- **Path:** `/api/books/:id`
- **Headers:** `Content-Type: application/json`
- **cURL:**
  ```bash
  curl -X PUT http://localhost:5000/api/books/newDocId123 \
    -H "Content-Type: application/json" \
    -d '{
      "title": "1984 (Special Edition)",
      "author": "George Orwell",
      "isbn": "9780451524935",
      "genre": "Science Fiction",
      "price": 13.50,
      "quantity": 30,
      "publisher": "Secker & Warburg",
      "publishedDate": "1949-06-08",
      "description": "Updated edition description."
    }'
  ```
- **Response:** `200 OK`
```json
{
  "success": true,
  "message": "Book updated successfully",
  "data": { ... }
}
```

---

### 6. Delete Book
- **Method:** `DELETE`
- **Path:** `/api/books/:id`
- **cURL:**
  ```bash
  curl -X DELETE http://localhost:5000/api/books/newDocId123
  ```
- **Response:** `200 OK`
```json
{
  "success": true,
  "message": "Book deleted successfully"
}
```

---

## 🧪 Automated Testing

### Backend Unit Tests
Run the backend validation suite:
```bash
cd backend
npm test
```

### Flutter Unit & Widget Tests
Run the Flutter test suite:
```bash
cd books_crud_app
flutter test
```

Run Flutter static analysis:
```bash
cd books_crud_app
flutter analyze
```

---

## 🛡️ Key Implementation Details

1. **ISBN Uniqueness:** The backend enforces application-level uniqueness on `POST` and `PUT` operations. Attempting to create or update a book with an ISBN that belongs to another record returns `409 Conflict`.
2. **State Management:** The Flutter frontend uses `Provider` (`BookProvider`) with `ChangeNotifier` to maintain single-source-of-truth state across screens and filters.
3. **Responsive UI:** Built with Flutter Material 3, custom Card designs, adaptive color schemes, and flexible scrollable containers.
4. **Network Resiliency:** Handled connection timeouts, offline states, and parsing errors with user-friendly alerts and retry buttons.
