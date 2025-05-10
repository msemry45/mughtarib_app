import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mughtarib_app/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('end-to-end test', () {
    testWidgets('تأكد من ظهور الصفحة الرئيسية', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.byType(MaterialApp), findsOneWidget);
    });
  });
} 