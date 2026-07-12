import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:alu_internlink/main.dart';
import 'package:alu_internlink/providers/providers.dart';

void main() {
  testWidgets('renders onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [firebaseReadyProvider.overrideWithValue(true)],
        child: const ALUInternLinkApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ALU InternLink'), findsWidgets);
    expect(find.text('Continue as student'), findsOneWidget);
    expect(find.text('Continue as startup'), findsOneWidget);
  });
}
