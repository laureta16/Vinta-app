import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:vinta/core/providers/auth_provider.dart';
import 'package:vinta/core/providers/clothing_provider.dart';
import 'package:vinta/main.dart';

void main() {
  testWidgets('App renders login when unauthenticated',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => AuthProvider()),
          ChangeNotifierProvider(create: (_) => ClothingProvider()),
        ],
        child: const VintaApp(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('VINTA'), findsOneWidget);
  });
}
