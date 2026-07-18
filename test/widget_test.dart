import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:smart_market/providers/prices_provider.dart';
import 'package:smart_market/screens/markets/markets_screen.dart';
import 'package:smart_market/services/firestore_service.dart';
import 'package:smart_market/services/storage_service.dart';

class _TestStorageService extends StorageService {
  @override
  Future<String> uploadImage(dynamic file, String bucket, String filename) async => '';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Markets screen shows a product price comparison after search',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (_) => PricesProvider(FirestoreService(), _TestStorageService()),
          ),
        ],
        child: const MaterialApp(home: MarketsScreen()),
      ),
    );

    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    await tester.enterText(searchField, 'Maize');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('Price comparison'), findsOneWidget);
    expect(find.textContaining('Maize'), findsWidgets);
  });
}
