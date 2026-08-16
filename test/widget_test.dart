import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homebase_finance/data/database.dart';
import 'package:homebase_finance/main.dart';

void main() {
  testWidgets('first run shows profile setup', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);
    await tester.pumpWidget(ProviderScope(
      overrides: [databaseProvider.overrideWithValue(db)],
      child: const HomebaseApp(),
    ));
    await tester.pumpAndSettle();
    expect(find.text('Welcome to Homebase Finance'), findsOneWidget);
  });
}
