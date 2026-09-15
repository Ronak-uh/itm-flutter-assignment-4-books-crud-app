import 'package:flutter_test/flutter_test.dart';
import 'package:books_crud_app/main.dart';

void main() {
  testWidgets('App renders BookListScreen and AppBar correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BooksCrudApp());

    // Verify AppBar title is present
    expect(find.text('Books Library'), findsOneWidget);

    // Verify Search Field hint is present
    expect(find.text('Search by title, author, ISBN, or genre...'), findsOneWidget);

    // Verify FAB is present
    expect(find.text('Add Book'), findsOneWidget);
  });
}
