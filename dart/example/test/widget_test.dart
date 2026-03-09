import 'package:flutter_test/flutter_test.dart';

import 'package:uniffi_xforge_example_app/main.dart';

void main() {
  testWidgets('renders UniFFI example screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ExampleApp());
    expect(find.text('UniFFI Example'), findsOneWidget);
  });
}
