import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyincc_fashionai/main.dart';

Future<void> openHome(WidgetTester tester) async {
  await tester.pumpWidget(const PyinccApp());
  await tester.tap(find.text('Bắt đầu xem giao diện'));
  await tester.pumpAndSettle();
  expect(find.text('Add ảnh PNG'), findsOneWidget);
}

void main() {
  testWidgets('Welcome opens unified Studio', (tester) async {
    await openHome(tester);
    final studioScroll = find.byType(Scrollable).first;
    await tester.scrollUntilVisible(find.text('Tạo nhân vật 3D từ ảnh thật'), 180,
        scrollable: studioScroll);
    expect(find.text('Tạo nhân vật 3D từ ảnh thật'), findsOneWidget);
    for (final label in ['Tủ đồ', 'Thử đồ', 'Làm đẹp']) {
      await tester.scrollUntilVisible(find.text(label), 180,
          scrollable: studioScroll);
      expect(find.text(label), findsOneWidget);
    }
    expect(find.text('Render thành nhân vật 2D'), findsNothing);
    expect(find.text('Face Swap với mẫu nhân vật'), findsNothing);
  });

  testWidgets('Studio opens wardrobe', (tester) async {
    await openHome(tester);
    await tester.scrollUntilVisible(find.text('Tủ đồ'), 180,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Tủ đồ'));
    await tester.pumpAndSettle();
    expect(find.text('Thêm món đồ'), findsOneWidget);
  });

  testWidgets('Studio opens try-on', (tester) async {
    await openHome(tester);
    // Scroll to the following tile so Try-on is clear of the bottom navigation.
    await tester.scrollUntilVisible(find.text('Làm đẹp'), 180,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Thử đồ'));
    await tester.pumpAndSettle();
    expect(find.text('Chất lượng hình ảnh'), findsOneWidget);
  });

  testWidgets('Studio opens beauty', (tester) async {
    await openHome(tester);
    await tester.scrollUntilVisible(find.text('Làm đẹp'), 180,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(find.text('Làm đẹp'));
    await tester.pumpAndSettle();
    expect(find.text('Studio Làm Đẹp'), findsOneWidget);
  });

  testWidgets('Studio, Home, Store and Account are primary tabs', (tester) async {
    await openHome(tester);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Nhân vật của bạn'), findsOneWidget);
    await tester.tap(find.text('Store'));
    await tester.pumpAndSettle();
    expect(find.text('Chọn trang phục thật để thử'), findsOneWidget);
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.text('Local-first'), findsOneWidget);
  });

  testWidgets('Cloud backup remains disabled', (tester) async {
    await openHome(tester);
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    final backup = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(backup.value, isFalse);
    expect(backup.onChanged, isNull);
  });
}
