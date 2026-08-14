import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:homebase/main.dart';

void main() {
  testWidgets('app shell renders', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: HomebaseApp()));
    expect(find.text('Homebase'), findsOneWidget);
  });
}
