import 'package:flutter_test/flutter_test.dart';
import 'package:pyincc_fashionai/main.dart';

void main() {
  testWidgets('Shows project name', (tester) async {
    await tester.pumpWidget(const PyinccApp());
    expect(find.text('PYINCC FashionAI'), findsOneWidget);
  });
}
