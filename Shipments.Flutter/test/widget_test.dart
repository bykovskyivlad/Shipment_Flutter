import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:shipments_flutter/main.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const ShipmentsApp());

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}