// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:breworder/main.dart';

void main() {
  testWidgets('Landing page renders key CTA text', (WidgetTester tester) async {
    await tester.pumpWidget(const BrewOrderApp());

    expect(find.text('Fresh Coffee, Just a Tap Away'), findsOneWidget);
    expect(find.text('Start Ordering'), findsOneWidget);

    // With slivers, parts of the page might be below the initial viewport.
    // Scroll a bit so we can verify the bottom CTA.
    final browseMenuFinder = find.text('Browse Menu');
    var safety = 0;
    while (browseMenuFinder.evaluate().isEmpty && safety < 6) {
      await tester.drag(find.byType(Scrollable).first, const Offset(0, -400));
      await tester.pumpAndSettle();
      safety++;
    }
    expect(browseMenuFinder, findsOneWidget);
  });
}
