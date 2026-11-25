import 'package:flutter_test/flutter_test.dart';
import 'package:novavault_flutter/main.dart';

void main() {
  testWidgets('NovaVaultApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const NovaVaultApp());
    expect(find.byType(NovaVaultApp), findsOneWidget);
  });
}
