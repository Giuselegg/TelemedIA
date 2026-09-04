import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:telemedia/screens/home_screen.dart';

void main() {
  testWidgets('TelemedIA si avvia correttamente', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: HomeScreen(),
      ),
    );

    expect(find.text('TelemedIA'), findsOneWidget);
  });
}