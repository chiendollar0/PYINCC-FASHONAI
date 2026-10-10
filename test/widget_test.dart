import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pyincc_fashionai/main.dart';

void main() {
  testWidgets('Welcome screen opens dashboard', (tester) async {
    await tester.pumpWidget(const PyinccApp());
    expect(find.text('Thử đồ ảo. Phong cách thật.'), findsOneWidget);
    await tester.tap(find.text('Bắt đầu xem giao diện'));
    await tester.pumpAndSettle();
    expect(find.text('Trang Chủ'), findsOneWidget);
    expect(find.text('Tủ Đồ AI'), findsWidgets);
  });

  testWidgets('Navigation opens try-on and beauty UI', (tester) async {
    await tester.pumpWidget(const PyinccApp());
    await tester.tap(find.text('Bắt đầu xem giao diện'));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.checkroom_outlined).last);
    await tester.pumpAndSettle();
    expect(find.text('Chất lượng hình ảnh'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.face_retouching_natural_outlined));
    await tester.pumpAndSettle();
    expect(find.text('Studio Làm Đẹp'), findsOneWidget);
  });
}
