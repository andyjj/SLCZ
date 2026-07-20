import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:zambia_sign_hub/data/auth_repository.dart';
import 'package:zambia_sign_hub/main.dart';

void main() {
  testWidgets('Welcome screen shows title and Open Dictionary button',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      ZambiaSignHubApp(
        authRepositoryOverride: AuthRepository(firebaseAuth: MockFirebaseAuth()),
      ),
    );

    expect(find.text('SLCZ'), findsOneWidget);
    expect(find.text('Open Dictionary'), findsOneWidget);
    expect(find.text('My Learning List'), findsOneWidget);
    expect(find.text('Quiz / Practice'), findsOneWidget);
  });
}
