import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class OutfitEditorScreen extends StatefulWidget {
  const OutfitEditorScreen({super.key});
  @override
  State<OutfitEditorScreen> createState() => _OutfitEditorState();
}
class _OutfitEditorState extends State<OutfitEditorScreen> {
  final picker = ImagePicker();
  final capture = GlobalKey();
  XFile? person, outfit;
  bool busy = false;
  double x = .5, y = .45, size = .5, angle = 0;

  Future<void> choose(bool personImage) async {
    if (busy) return;
    setState(() => busy = true);
    try {
      final image = await picker.pickImage(source: ImageSource.gallery,
          maxWidth: 1600, maxHeight: 2000);
      if (image == null || !mounted) return;
      final header = await File(image.path).openRead(0, 12)
          .fold<List<int>>(<int>[], (a, b) => a..addAll(b));
      final png = header.length >= 8 && header[0] == 137 &&
          header[1] == 80 && header[2] == 78 && header[3] == 71;
      final jpeg = header.length >= 3 && header[0] == 255 &&
          header[1] == 216 && header[2] == 255;
      final webp = header.length >= 12 &&
          String.fromCharCodes(header.sublist(0, 4)) == 'RIFF' &&
          String.fromCharCodes(header.sublist(8, 12)) == 'WEBP';
      if (!png && !jpeg && !webp) throw const FormatException();
      setState(() {
        if (personImage) { person = image; } else { outfit = image; }
      });
    } catch (_) {
      if (mounted) notice('Không đọc được ảnh PNG/JPG/WEBP.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
  void notice(String value) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(value)));

  Future<void> export() async {
    if (busy || person == null || outfit == null) return;
    setState(() => busy = true);
    try {
      await WidgetsBinding.instance.endOfFrame;
      final boundary = capture.currentContext!.findRenderObject()
          as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 2);
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      if (data == null) throw StateError('PNG');
      final folder = await getApplicationDocumentsDirectory();
      final path = folder.path + '/pyincc-look-' +
          DateTime.now().millisecondsSinceEpoch.toString() + '.png';
      await File(path).writeAsBytes(data.buffer.asUint8List(), flush: true);
      if (!mounted) return;
      notice('Đã lưu ảnh PNG trong dữ liệu ứng dụng.');
      await Share.shareXFiles([XFile(path)], text: 'PYINCC FashionAI');
    } catch (_) {
      if (mounted) notice('Không thể xuất ảnh.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Widget slider(String label, double value, double min, double max,
      ValueChanged<double> change) => Row(children: [
        SizedBox(width: 85, child: Text(label)),
        Expanded(child: Slider(value: value, min: min, max: max,
            onChanged: change)),
      ]);

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Studio · Ghép ảnh 2D')),
    body: ListView(padding: const EdgeInsets.all(16), children: [
      AspectRatio(aspectRatio: 3 / 4, child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: LayoutBuilder(builder: (context, bounds) {
          final w = bounds.maxWidth, h = bounds.maxHeight;
          return RepaintBoundary(key: capture, child: ColoredBox(
            color: const Color(0xFFEDE3D7),
            child: Stack(children: [
              if (person == null)
                const Center(child: Text('Chọn ảnh người mẫu toàn thân'))
              else
                Positioned.fill(child: Image.file(File(person!.path),
                    fit: BoxFit.contain)),
              if (person != null && outfit != null)
                Positioned(
                  left: x * w - size * w / 2,
                  top: y * h - size * w / 2,
                  width: size * w, height: size * w,
                  child: Transform.rotate(angle: angle,
                    child: Image.file(File(outfit!.path),
                        fit: BoxFit.contain)),
                ),
            ]),
          ));
        }),
      )),
      const SizedBox(height: 12),
      OutlinedButton(onPressed: busy ? null : () => choose(true),
          child: const Text('1. Chọn ảnh người mẫu')),
      OutlinedButton(onPressed: busy ? null : () => choose(false),
          child: const Text('2. Chọn ảnh trang phục')),
      if (person != null && outfit != null) ...[
        slider('Ngang', x, 0, 1, (v) => setState(() => x = v)),
        slider('Dọc', y, 0, 1, (v) => setState(() => y = v)),
        slider('Cỡ', size, .15, 1.3, (v) => setState(() => size = v)),
        slider('Xoay', angle, -.8, .8, (v) => setState(() => angle = v)),
        OutlinedButton(onPressed: () => setState(() {
          x = .5; y = .45; size = .5; angle = 0;
        }), child: const Text('Đặt lại căn chỉnh')),
        FilledButton(onPressed: busy ? null : export,
            child: const Text('Xuất PNG và chia sẻ')),
      ] else
        const Text('Nhập đủ hai ảnh để căn chỉnh và xuất kết quả.'),
      const SizedBox(height: 12),
      const Text('Ghép lớp ảnh thủ công trên thiết bị, không phải AI. '
          'Ảnh trang phục nền trong suốt cho kết quả tốt nhất.'),
    ]),
  );
}
