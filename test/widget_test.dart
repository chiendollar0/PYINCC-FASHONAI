import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyincc_fashionai/main.dart';

Future<void> openHome(WidgetTester tester) async {
  await tester.pumpWidget(const PyinccApp());
  expect(find.text('Thử đồ ảo. Phong cách thật.'), findsOneWidget);
  await tester.tap(find.text('Bắt đầu xem giao diện'));
  await tester.pumpAndSettle();
  expect(find.text('Trang Chủ'), findsOneWidget);
}

void main() {
  testWidgets('Welcome opens dashboard', (tester) async {
    await openHome(tester);
    expect(find.text('Tủ Đồ AI'), findsWidgets);
  });

  testWidgets('Dashboard feature tiles open core modules', (tester) async {
    await openHome(tester);
    await tester.tap(find.text('Thử Đồ AI'));
    await tester.pumpAndSettle();
    expect(find.text('Chất lượng hình ảnh'), findsOneWidget);
  });

  testWidgets('Bottom navigation opens wardrobe and beauty', (tester) async {
    await openHome(tester);
    await tester.tap(find.byIcon(Icons.inventory_2_outlined).last);
    await tester.pumpAndSettle();
    expect(find.text('Thêm món đồ'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.face_retouching_natural_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Studio Làm Đẹp'), findsOneWidget);
  });

  testWidgets('Try-on result is explicitly a preview', (tester) async {
    await openHome(tester);
    await tester.tap(find.byIcon(Icons.checkroom_outlined).last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Xem bố cục kết quả mẫu'));
    await tester.tap(find.text('Xem bố cục kết quả mẫu'));
    await tester.pumpAndSettle();
    expect(find.text('Kết quả Thử Đồ'), findsOneWidget);
    expect(find.textContaining('Chưa có ảnh kết quả AI'), findsOneWidget);
  });

  testWidgets('Avatar 3D is labeled future feature', (tester) async {
    await openHome(tester);
    await tester.tap(find.text('Avatar 3D'));
    await tester.pumpAndSettle();
    expect(find.textContaining('chưa triển khai trong MVP'), findsOneWidget);
  });

  testWidgets('Cloud backup is disabled by default', (tester) async {
    await openHome(tester);
    await tester.tap(find.byIcon(Icons.person_outline).last);
    await tester.pumpAndSettle();
    final backup = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(backup.value, isFalse);
    expect(backup.onChanged, isNull);
  });
}
