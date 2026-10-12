import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyincc_fashionai/main.dart';

Future<void> openHome(WidgetTester tester) async {
  await tester.pumpWidget(const PyinccApp());
  await tester.pumpAndSettle();
  expect(find.byType(UnifiedStudioScreen), findsOneWidget);
  await tester.scrollUntilVisible(find.text('Khu vực người mẫu toàn thân'), 160,
      scrollable: find.descendant(of: find.byType(UnifiedStudioScreen), matching: find.byType(Scrollable)).first);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Production stays locked without Firebase configuration', (tester) async {
    await tester.pumpWidget(const PyinccApp(requireAuthentication: true));
    await tester.pumpAndSettle();
    expect(find.text('Đăng nhập chưa sẵn sàng'), findsOneWidget);
    expect(find.byType(HomeShell), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Studio opens with main preview and compact tools', (tester) async {
    await openHome(tester);
    await tester.scrollUntilVisible(find.text('Khuôn mặt'), -160,
        scrollable: find.descendant(of: find.byType(UnifiedStudioScreen), matching: find.byType(Scrollable)).first);
    expect(find.text('Trang phục'), findsWidgets);
    expect(find.text('Khuôn mặt'), findsOneWidget);
    expect(find.text('Tủ đồ'), findsOneWidget);
    expect(find.text('Makeup'), findsOneWidget);
    expect(find.text('Bước 1 · Add ảnh chân dung PNG'), findsNothing);
  });

  testWidgets('Studio switches to Face Swap controls', (tester) async {
    await openHome(tester);
    await tester.scrollUntilVisible(find.text('Khuôn mặt'), -160,
        scrollable: find.descendant(of: find.byType(UnifiedStudioScreen), matching: find.byType(Scrollable)).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Khuôn mặt'));
    await tester.pumpAndSettle();
    expect(find.text('Chọn ảnh khuôn mặt'), findsOneWidget);
    expect(find.text('Áp dụng Face Swap'), findsOneWidget);
  });

  testWidgets('Studio opens wardrobe', (tester) async {
    await openHome(tester);
    await tester.scrollUntilVisible(find.text('Tủ đồ'), -160,
        scrollable: find.descendant(of: find.byType(UnifiedStudioScreen), matching: find.byType(Scrollable)).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tủ đồ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mở tủ đồ'));
    await tester.pumpAndSettle();
    expect(find.text('Thêm món đồ'), findsOneWidget);
  });

  testWidgets('Studio displays compact makeup controls', (tester) async {
    await openHome(tester);
    await tester.scrollUntilVisible(find.text('Makeup'), -160,
        scrollable: find.descendant(of: find.byType(UnifiedStudioScreen), matching: find.byType(Scrollable)).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Makeup'));
    await tester.pumpAndSettle();
    expect(find.text('Son môi'), findsOneWidget);
    expect(find.text('Kẻ mắt'), findsOneWidget);
    expect(find.text('Mascara/mi'), findsOneWidget);
    expect(find.text('Má hồng'), findsOneWidget);
  });

  testWidgets('Studio, Home, Store and Account are primary tabs', (tester) async {
    await openHome(tester);
    final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.selectedIndex, 2);
    expect(navigation.destinations.map((item) => (item as NavigationDestination).label).toList(),
        ['Store', 'Home', 'Studio', 'Account']);
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
