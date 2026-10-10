import 'package:flutter/material.dart';

void main() => runApp(const PyinccApp());

class PyinccApp extends StatelessWidget {
  const PyinccApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PYINCC FashionAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB89B7C)),
        scaffoldBackgroundColor: const Color(0xFFF8F5EF),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.checkroom_outlined, size: 64),
                  SizedBox(height: 16),
                  Text('PYINCC FashionAI', style: TextStyle(fontSize: 26)),
                  SizedBox(height: 16),
                  Text('Bản nền tảng Android. Đăng nhập và AI thử đồ chưa được kích hoạt.', textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  Text('Ảnh cá nhân không tự động tải lên Cloud.', textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
