import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyincc_fashionai/main.dart';

Future<void> openHome(WidgetTester tester) async {
  await tester.pumpWidget(const PyinccApp());
  await tester.tap(find.text('Bắt đầu xem giao diện'));
  await tester.pumpAndSettle();
  expect(find.text('Nhân vật 2D'), findsOneWidget);
}

void main() {
  testWidgets('Welcome opens unified Studio', (tester) async {
    await openHome(tester);
    expect(find.text('Tủ đồ'), findsWidgets);
    expect(find.text('Thử đồ'), findsWidgets);
    expect(find.text('Làm đẹp'), findsOneWidget);
  });

  testWidgets('Studio opens wardrobe', (tester) async {
    await openHome(tester);
    await tester.tap(find.text('Tủ đồ').last);
    await tester.pumpAndSettle();
    expect(find.text('Thêm món đồ'), findsOneWidget);
  });

  testWidgets('Studio opens try-on', (tester) async {
    await openHome(tester);
    await tester.tap(find.text('Thử đồ').last);
    await tester.pumpAndSettle();
    expect(find.text('Chất lượng hình ảnh'), findsOneWidget);
  });

  testWidgets('Studio opens beauty', (tester) async {
    await openHome(tester);
    await tester.tap(find.text('Làm đẹp'));
    await tester.pumpAndSettle();
    expect(find.text('Studio Làm Đẹp'), findsOneWidget);
  });

  testWidgets('Explore and profile are primary tabs', (tester) async {
    await openHome(tester);
    await tester.tap(find.text('Khám phá'));
    await tester.pumpAndSettle();
    expect(find.text('Trang Chủ'), findsOneWidget);
    await tester.tap(find.text('Cá nhân'));
    await tester.pumpAndSettle();
    expect(find.text('Local-first'), findsOneWidget);
  });

  testWidgets('Cloud backup remains disabled', (tester) async {
    await openHome(tester);
    await tester.tap(find.text('Cá nhân'));
    await tester.pumpAndSettle();
    final backup = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(backup.value, isFalse);
    expect(backup.onChanged, isNull);
  });
}
