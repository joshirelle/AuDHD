import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:kiko_app/modules/screening/screens/screening_home_screen.dart';

void main() {
  testWidgets('Ipinapakita ng screening hub ang tatlong opsyon', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: ScreeningHomeScreen()));

    expect(find.text('M-CHAT-R Autism Screening'), findsOneWidget);
    expect(find.text('Vanderbilt ADHD Screening'), findsOneWidget);
    expect(find.text('Tala ng mga Nakaraang Test'), findsOneWidget);
  });
}
