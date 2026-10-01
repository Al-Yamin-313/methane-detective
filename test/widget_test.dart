import 'package:flutter_test/flutter_test.dart';
import 'package:methane_detective/main.dart';

void main() {
  testWidgets('App renders shell', (WidgetTester tester) async {
    await tester.pumpWidget(const MethaneDetectiveApp());
    await tester.pump();
    expect(find.text('METHANE'), findsWidgets);
  });
}