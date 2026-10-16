import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyincc_fashionai/main.dart';
import 'package:pyincc_fashionai/outfit_editor.dart';
import 'package:pyincc_fashionai/production_auth.dart';

Future<void> openStudio(WidgetTester tester) async {
  await tester.pumpWidget(const PyinccApp());
  await tester.pumpAndSettle();
  // Home is the product entry point; navigate explicitly to Studio.
  expect(find.text('Fashion Studio'), findsOneWidget);
  expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 0);
  await tester.tap(find.text('Studio'));
  await tester.pumpAndSettle();
  expect(find.byType(UnifiedStudioScreen), findsOneWidget);
}

void main() {
  testWidgets('2D editor prevents exporting without two images', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: OutfitEditorScreen()));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('1. Chọn ảnh người mẫu'), 160);
    expect(find.text('1. Chọn ảnh người mẫu'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('2. Chọn ảnh trang phục'), 120);
    expect(find.text('2. Chọn ảnh trang phục'), findsOneWidget);
    expect(find.text('Xuất PNG và chia sẻ'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Production stays locked without Firebase configuration', (tester) async {
    await tester.pumpWidget(const PyinccApp(requireAuthentication: true));
    await tester.pumpAndSettle();
    expect(find.text('Đăng nhập chưa sẵn sàng'), findsOneWidget);
    expect(find.byType(HomeShell), findsNothing);
    expect(find.byType(NavigationBar), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Debug opens Home without a login prompt', (tester) async {
    await tester.pumpWidget(const PyinccApp());
    await tester.pumpAndSettle();
    expect(find.text('Fashion Studio'), findsOneWidget);
    expect(find.byType(SignInScreen), findsNothing);
    expect(tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Studio opens with 3D-first preview and tools', (tester) async {
    await openStudio(tester);
    expect(find.text('Studio · 3D'), findsOneWidget);
    expect(find.text('Studio · 3D'), findsOneWidget);
    expect(find.text('Tủ đồ'), findsOneWidget);
    expect(find.text('Shop'), findsOneWidget);
    expect(find.text('Big Bag'), findsOneWidget);
    expect(find.text('Skin Care'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Big Bag states the 3D garment pipeline is unavailable', (tester) async {
    await openStudio(tester);
    await tester.tap(find.text('Big Bag'));
    await tester.pumpAndSettle();
    expect(find.text('Chưa có trang phục'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Studio opens wardrobe catalog', (tester) async {
    await openStudio(tester);
    await tester.tap(find.text('Tủ đồ'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mở danh mục trang phục'));
    await tester.pumpAndSettle();
    expect(find.text('Tủ Đồ AI'), findsOneWidget);
    expect(find.text('Áo'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Studio displays Skin Care controls without claiming 3D effects', (tester) async {
    await openStudio(tester);
    await tester.tap(find.text('Skin Care'));
    await tester.pumpAndSettle();
    expect(find.text('Độ sáng'), findsOneWidget);
    expect(find.text('Má hồng'), findsOneWidget);
    expect(find.text('Son môi'), findsOneWidget);

    expect(tester.takeException(), isNull);
  });

  testWidgets('Studio, Home, Store and Account are primary tabs', (tester) async {
    await openStudio(tester);
    final navigation = tester.widget<NavigationBar>(find.byType(NavigationBar));
    expect(navigation.selectedIndex, 1);
    expect(navigation.destinations.map((item) => (item as NavigationDestination).label).toList(),
        ['Home', 'Studio', 'Store', 'Account']);
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();
    expect(find.text('Fashion Studio'), findsOneWidget);
    await tester.tap(find.text('Store'));
    await tester.pumpAndSettle();
    expect(find.text('Chọn trang phục thật để thử'), findsOneWidget);
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(find.text('Local-first'), findsOneWidget);
  });

  testWidgets('Cloud backup remains disabled', (tester) async {
    await openStudio(tester);
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    final backup = tester.widget<SwitchListTile>(find.byType(SwitchListTile));
    expect(backup.value, isFalse);
    expect(backup.onChanged, isNull);
  });
}
