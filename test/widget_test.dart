import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zambia_sign_hub/main.dart';

void main() {
  testWidgets('Welcome screen shows title and Open Dictionary button',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ZambiaSignHubApp());

    expect(find.text('Zambia Sign\nLanguage Hub'), findsOneWidget);
    expect(find.text('Open Dictionary'), findsOneWidget);
  });
}
