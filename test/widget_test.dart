import 'package:flutter_test/flutter_test.dart';

import 'package:traveling_app/main.dart';

void main() {
  testWidgets('renders login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Continue with Apple'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
  });
}
