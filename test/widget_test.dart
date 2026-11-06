import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_chef_app/widgets/rate_order_dialog.dart';

void main() {
  testWidgets('RateOrderDialog displays correctly with tags and rating', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RateOrderDialog(
            orderId: 'ORD-2026-7022',
            kitchenName: 'The British Hearth',
          ),
        ),
      ),
    );

    expect(find.text('How was your meal?'), findsOneWidget);
    expect(find.textContaining('The British Hearth'), findsOneWidget);
    expect(find.text('Super Tasty 😋'), findsOneWidget);
    expect(find.text('Hot & Fresh ♨️'), findsOneWidget);
  });
}
