import 'package:flutter_test/flutter_test.dart';

import 'package:xlints_example/main.dart';

void main() {
  testWidgets('App loads and shows Xlints Bad Examples', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const XlintsExampleApp());

    expect(find.text('Xlints Bad Examples'), findsOneWidget);
  });
}
