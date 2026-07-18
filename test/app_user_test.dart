import 'package:flutter_test/flutter_test.dart';
import 'package:smart_market/models/app_user.dart';

void main() {
  test('preferred products round-trip through app user map', () {
    final user = AppUser(
      uid: 'u1',
      fullName: 'Jane',
      phoneNumber: '0700000000',
      email: 'jane@example.com',
      district: 'Kampala',
      role: UserRole.buyer,
      preferredProducts: const ['Maize', 'Beans'],
      createdAt: DateTime(2024),
    );

    final map = user.toMap();
    final restored = AppUser.fromMap(map);

    expect(restored.preferredProducts, ['Maize', 'Beans']);
  });
}
