import 'package:flutter_test/flutter_test.dart';
import 'package:handong_eats/main.dart';

void main() {
  testWidgets('Login screen render test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const HandongEatsApp());

    // Verify that the login screen header and button render.
    expect(find.text('HandongEats'), findsOneWidget);
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}
