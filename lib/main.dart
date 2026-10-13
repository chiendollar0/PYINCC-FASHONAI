import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'production_auth.dart';
import 'outfit_editor.dart';
import 'package:image_picker/image_picker.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

void main() => runApp(const PyinccApp());

const cream = Color(0xFFF9F6F0);
const coffee = Color(0xFF6E5749);
const sand = Color(0xFFEDE3D7);

class PyinccApp extends StatelessWidget {
  final bool requireAuthentication;
  const PyinccApp({super.key, this.requireAuthentication = false});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'PYINCC FashionAI',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(seedColor: coffee, surface: cream),
      appBarTheme: const AppBarTheme(backgroundColor: cream, centerTitle: false),
      cardTheme: CardThemeData(color: Colors.white, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    ),
    home: kDebugMode && !requireAuthentication
        ? const HomeShell()
        : ProductionAuthGate(authenticatedBuilder: (_) => const HomeShell()),
  );
}

/// Licensed sample model: CesiumMan, Cesium, CC BY 4.0.
/// Source: Khronos glTF Sample Assets (GLB served by GitHub).
/// A live network connection and modern Android System WebView are required.
class SampleAvatar3DScreen extends StatelessWidget {
  const SampleAvatar3DScreen({super.key});

  static const modelUrl =
      'https://raw.githubusercontent.com/KhronosGroup/glTF-Sample-Assets/main/Models/CesiumMan/glTF-Binary/CesiumMan.glb';

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Nhân vật mẫu 3D')),
    body: SafeArea(child: Column(children: [
      const Expanded(child: ModelViewer(
        src: modelUrl,
        alt: 'Nhân vật CesiumMan toàn thân 3D',
        backgroundColor: sand,
        cameraControls: true,
        autoRotate: true,
        ar: false,
        loading: Loading.eager,
      )),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text('Vuốt để xoay · Chụm để phóng to. Mô hình cần Internet và Android WebView mới.',
            textAlign: TextAlign.center),
      ),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, 18),
        child: Text('CesiumMan © Cesium · CC BY 4.0 · Khronos glTF Sample Assets. '
            'Mẫu thử hiển thị 3D, chưa thay trang phục hoặc Face Swap.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: Colors.black54)),
      ),
    ])),
  );
}

class DemoNotice extends StatelessWidget {
  const DemoNotice({super.key});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: sand, borderRadius: BorderRadius.circular(14)),
    child: const Row(children: [
      Icon(Icons.info_outline, color: coffee),
      SizedBox(width: 10),
      Expanded(child: Text('Bản xem trước giao diện. Chưa xử lý ảnh hoặc kết nối AI.',
        style: TextStyle(fontSize: 12))),
    ]),
  );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  // Home is the entry point for face identity and avatar setup.
  int tab = 1;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: tab, children: [
      StoreScreen(onTryOn: () => setState(() => tab = 2)),
      const CharacterHomeScreen(),
      const UnifiedStudioScreen(),
      const ProfileScreen(),
    ])),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Store'),
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'Studio'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Account'),
      ],
    ),
  );
}

/// Home owns the face image and avatar preferences for this app session.
/// A selected photo is never represented as a completed 3D face swap.
class CharacterHomeScreen extends StatefulWidget {
  const CharacterHomeScreen({super.key});
  @override
  State<CharacterHomeScreen> createState() => _CharacterHomeScreenState();
}

class _CharacterHomeScreenState extends State<CharacterHomeScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _face;
  bool _loading = false;
  bool _consent = false;
  double _height = 165;
  double _weight = 60;
  String _form = 'M';

  Future<void> _selectFace() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final selected = await _picker.pickImage(
        source: ImageSource.gallery, maxWidth: 1200,
        maxHeight: 1200, imageQuality: 85);
      if (selected == null || !mounted) return;
      final bytes = await File(selected.path).openRead(0, 12)
          .fold<List<int>>(<int>[], (a, b) => a..addAll(b));
      final png = bytes.length >= 8 && bytes[0] == 137 &&
          bytes[1] == 80 && bytes[2] == 78 && bytes[3] == 71;
      final jpeg = bytes.length >= 3 && bytes[0] == 255 &&
          bytes[1] == 216 && bytes[2] == 255;
      final webp = bytes.length >= 12 &&
          String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
          String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
      if (!png && !jpeg && !webp) throw const FormatException();
      setState(() => _face = selected);
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ảnh không hợp lệ. Chọn PNG, JPG hoặc WEBP.')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _faceSwapStatus() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('Chưa có engine Face Swap 3D đã kiểm chứng. '
          'Không ghép giả hoặc gửi ảnh lên máy chủ.')));
  }

  Widget _measure(String label, double value, double min, double max,
      String unit, ValueChanged<double> onChanged) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label), Text('${value.round()} $unit'),
      ]),
      Slider(value: value, min: min, max: max, onChanged: onChanged),
    ],
  );

  @override
  Widget build(BuildContext context) => SectionPage(
    title: 'Home', subtitle: 'Khuôn mặt và nhân vật của bạn',
    children: [
      Row(children: [
        const Icon(Icons.face_retouching_natural_outlined, color: coffee),
        const SizedBox(width: 10),
        const Expanded(child: Text('Fake · Face Swap',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600))),
      ]),
      const SizedBox(height: 10),
      Card(child: Padding(padding: const EdgeInsets.all(12), child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          if (_face == null)
            const SizedBox(height: 112, child: Center(
              child: Icon(Icons.add_a_photo_outlined, size: 48, color: coffee)))
          else
            ClipRRect(borderRadius: BorderRadius.circular(12),
              child: Image.file(File(_face!.path), height: 180,
                fit: BoxFit.contain, errorBuilder: (_, __, ___) =>
                  const Text('Không thể đọc ảnh khuôn mặt'))),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _loading ? null : _selectFace,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(_face == null ? '1. Tải ảnh khuôn mặt' : 'Đổi ảnh khuôn mặt'),
          ),
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _consent,
            onChanged: (value) => setState(() => _consent = value ?? false),
            title: const Text('Tôi có quyền sử dụng khuôn mặt trong ảnh'),
            subtitle: const Text('Ảnh chỉ dùng trong phiên hiện tại; chưa tải lên cloud.'),
            controlAffinity: ListTileControlAffinity.leading,
          ),
          FilledButton.icon(
            onPressed: _face != null && _consent ? _faceSwapStatus : null,
            icon: const Icon(Icons.face_outlined),
            label: const Text('2. Face Swap lên avatar 3D'),
          ),
          const SizedBox(height: 8),
          const Text('Chưa có kết quả Face Swap 3D. Ảnh trên là ảnh nguồn, '
              'không phải khuôn mặt đã ánh xạ.',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
        ]))),
      const SizedBox(height: 12),
      FilledButton.tonalIcon(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SampleAvatar3DScreen())),
        icon: const Icon(Icons.view_in_ar_outlined),
        label: const Text('Xem avatar GLB mẫu · Xoay 360°'),
      ),
      const SizedBox(height: 16),
      const Text('Thông số nhân vật', style: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600)),
      const Text('Giá trị tham khảo, không phải số đo cơ thể được suy ra từ ảnh.',
        style: TextStyle(fontSize: 12, color: Colors.black54)),
      const SizedBox(height: 8),
      _measure('Chiều cao', _height, 120, 210, 'cm',
          (v) => setState(() => _height = v)),
      _measure('Cân nặng', _weight, 30, 150, 'kg',
          (v) => setState(() => _weight = v)),
      const Text('Form nhân vật · X / M / N'),
      const SizedBox(height: 8),
      SegmentedButton<String>(
        segments: const [
          ButtonSegment(value: 'X', label: Text('X')),
          ButtonSegment(value: 'M', label: Text('M')),
          ButtonSegment(value: 'N', label: Text('N')),
        ],
        selected: {_form},
        onSelectionChanged: (v) => setState(() => _form = v.first),
      ),
      const SizedBox(height: 8),
      const Text('Các thanh trượt chưa thay đổi mesh 3D. '
        'Cần avatar tương thích morph targets để áp dụng thực tế.',
        style: TextStyle(fontSize: 12, color: Colors.black54)),
    ],
  );
}

/// Store deliberately contains no invented prices, brands or purchase URLs.
class StoreScreen extends StatelessWidget {
  final VoidCallback onTryOn;
  const StoreScreen({super.key, required this.onTryOn});
  @override
  Widget build(BuildContext context) => SectionPage(
    title: 'Store',
    subtitle: 'Chọn trang phục thật để thử',
    children: [
      const DemoNotice(),
      const SizedBox(height: 16),
      const PreviewPanel(
        icon: Icons.shopping_bag_outlined,
        title: 'Danh mục sản phẩm',
        caption: 'Đang chờ nguồn dữ liệu sản phẩm và liên kết '
          'Shopee / TikTok Shop được xác minh.',
      ),
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: onTryOn,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Về Studio để thử đồ'),
      ),
    ],
  );
}

class UnifiedStudioScreen extends StatefulWidget {
  const UnifiedStudioScreen({super.key});
  @override
  State<UnifiedStudioScreen> createState() => _UnifiedStudioScreenState();
}

class _UnifiedStudioScreenState extends State<UnifiedStudioScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _portrait;
  XFile? _outfit;
  bool _importing = false;
  String _panel = 'Trang phục';
  double _lipstick = .35, _eyes = .25, _lashes = .20, _blush = .25;

  Future<void> _pickPhoto({required bool outfit}) async {
    if (_importing) return;
    setState(() => _importing = true);
    try {
      final selected = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 2000,
      );
      if (selected == null || !mounted) return;
      final file = File(selected.path);
      final bytes = await file.openRead(0, 12).fold<List<int>>(
        <int>[], (value, chunk) => value..addAll(chunk));
      final isPng = bytes.length >= 8 &&
          bytes[0] == 137 && bytes[1] == 80 &&
          bytes[2] == 78 && bytes[3] == 71;
      final isJpeg = bytes.length >= 3 &&
          bytes[0] == 255 && bytes[1] == 216 && bytes[2] == 255;
      final isWebp = bytes.length >= 12 &&
          String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
          String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP';
      if (!isPng && !isJpeg && !isWebp) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Chỉ hỗ trợ ảnh PNG, JPG hoặc WEBP hợp lệ.')));
        return;
      }
      if (!mounted) return;
      setState(() {
        if (outfit) {
          _outfit = selected;
          _panel = 'Trang phục';
        } else {
          _portrait = selected;
          _panel = 'Khuôn mặt';
        }
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Không đọc được ảnh. Hãy chọn ảnh khác.')));
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  void _notReady(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('$feature đang chờ tích hợp AI. Ảnh chưa được gửi đi.')));
  }

  Widget _tool(String title, IconData icon) => ChoiceChip(
    avatar: Icon(icon, size: 18),
    label: Text(title),
    selected: _panel == title,
    onSelected: (_) => setState(() => _panel = title),
  );

  Widget _slider(String title, double value, ValueChanged<double> onChange) =>
      Row(children: [
        SizedBox(width: 95, child: Text(title)),
        Expanded(child: Slider(value: value, onChanged: onChange)),
      ]);

  Widget _activePanel() {
    switch (_panel) {
      case 'Khuôn mặt':
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Face Swap', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _importing ? null : () => _pickPhoto(outfit: false),
            icon: const Icon(Icons.face_outlined),
            label: Text(_portrait == null ? 'Chọn ảnh khuôn mặt' : 'Đổi ảnh khuôn mặt'),
          ),
          FilledButton.tonal(
            onPressed: _portrait == null ? null : () => _notReady('Face Swap'),
            child: const Text('Áp dụng Face Swap'),
          ),
        ]);
      case 'Makeup':
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Makeup nhanh · Bản điều khiển xem trước',
              style: TextStyle(fontWeight: FontWeight.bold)),
          _slider('Son môi', _lipstick, (v) => setState(() => _lipstick = v)),
          _slider('Kẻ mắt', _eyes, (v) => setState(() => _eyes = v)),
          _slider('Mascara/mi', _lashes, (v) => setState(() => _lashes = v)),
          _slider('Má hồng', _blush, (v) => setState(() => _blush = v)),
          const Text('Chưa áp dụng hiệu ứng lên ảnh.',
              style: TextStyle(fontSize: 12, color: Colors.black54)),
        ]);
      case 'Tủ đồ':
        return OutlinedButton.icon(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const WardrobeScreen())),
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('Mở tủ đồ'),
        );
      default:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Chọn ảnh trang phục để thử',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _importing ? null : () => _pickPhoto(outfit: true),
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: Text(_outfit == null ? 'Tải ảnh trang phục' : 'Đổi ảnh trang phục'),
          ),
          if (_outfit != null)
            Padding(padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                ClipRRect(borderRadius: BorderRadius.circular(10),
                  child: Image.file(File(_outfit!.path), width: 64, height: 72,
                    fit: BoxFit.cover, cacheWidth: 128,
                    errorBuilder: (_, __, ___) => const Icon(Icons.broken_image))),
                const SizedBox(width: 12),
                const Expanded(child: Text('Đã chọn ảnh trang phục trên thiết bị')),
              ])),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) => SectionPage(
    title: 'Studio',
    subtitle: 'Phòng thử đồ PYINCC FashionAI',
    children: [
      Wrap(spacing: 8, runSpacing: 6, children: [
        _tool('Trang phục', Icons.checkroom_outlined),
        _tool('Khuôn mặt', Icons.face_outlined),
        _tool('Tủ đồ', Icons.inventory_2_outlined),
        _tool('Makeup', Icons.brush_outlined),
      ]),
      const SizedBox(height: 12),
      Card(child: Padding(padding: const EdgeInsets.all(14),
        child: _activePanel())),
      const SizedBox(height: 12),
      Container(
        height: 350,
        decoration: BoxDecoration(
          color: sand, borderRadius: BorderRadius.circular(22)),
        clipBehavior: Clip.antiAlias,
        child: _portrait == null
          ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.accessibility_new_outlined, size: 92, color: coffee),
              SizedBox(height: 12),
              Text('Khu vực người mẫu toàn thân',
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Padding(padding: EdgeInsets.symmetric(horizontal: 28),
                child: Text('Chưa có ảnh người mẫu được tích hợp. '
                    'Chọn ảnh của bạn để xem trước tại đây.',
                    textAlign: TextAlign.center)),
            ])
          : Image.file(File(_portrait!.path), fit: BoxFit.contain,
              width: double.infinity, cacheWidth: 900,
              errorBuilder: (_, __, ___) =>
                const Center(child: Text('Không thể hiển thị ảnh'))),
      ),
      const SizedBox(height: 10),
      OutlinedButton.icon(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SampleAvatar3DScreen())),
        icon: const Icon(Icons.view_in_ar_outlined),
        label: const Text('Xem người mẫu 3D GLB'),
      ),
      const SizedBox(height: 8),
      const Text('Ảnh chỉ được xem trước trên thiết bị. '
          'Chưa có Face Swap hoặc thử đồ AI thực tế.',
          style: TextStyle(fontSize: 12, color: Colors.black54)),
      const SizedBox(height: 14),
      FilledButton.tonalIcon(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const OutfitEditorScreen())),
        icon: const Icon(Icons.layers_outlined),
        label: const Text('Ghép trang phục 2D · Sử dụng ngay'),
      ),
      const SizedBox(height: 8),
      FilledButton.icon(
        onPressed: _outfit == null ? null : () => _notReady('Thử đồ AI'),
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Thử đồ AI'),
      ),
      const SizedBox(height: 8),
      const Text('Xem kết quả toàn thân và xuất PNG trong trình phối đồ 2D; '
          'chưa có ảnh trước/sau AI thật.',
          style: TextStyle(fontSize: 12, color: Colors.black54)),
    ],
  );
}

class SectionPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const SectionPage({super.key, required this.title, required this.subtitle, required this.children});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView(padding: const EdgeInsets.all(20), children: [
    Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: coffee)),
    const SizedBox(height: 6),
    Text(subtitle, style: const TextStyle(color: Colors.black54)),
    const SizedBox(height: 22),
    ...children,
  ]));
}

class PreviewPanel extends StatelessWidget {
  final IconData icon;
  final String title;
  final String caption;
  const PreviewPanel({super.key, required this.icon, required this.title, required this.caption});
  @override
  Widget build(BuildContext context) => Container(
    height: 250, padding: const EdgeInsets.all(22),
    decoration: BoxDecoration(color: sand, borderRadius: BorderRadius.circular(22)),
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Icon(icon, size: 76, color: coffee),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      Text(caption, textAlign: TextAlign.center),
    ]),
  );
}

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});
  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}
class _WardrobeScreenState extends State<WardrobeScreen> {
  String category = 'Áo';
  @override
  Widget build(BuildContext context) => SectionPage(
    title: 'Tủ Đồ AI', subtitle: 'Quản lý trang phục và gợi ý phối đồ',
    children: [
      Wrap(spacing: 8, children: ['Áo', 'Quần', 'Váy', 'Phụ kiện'].map((x) =>
        ChoiceChip(label: Text(x), selected: category == x,
          onSelected: (_) => setState(() => category = x))).toList()),
      const SizedBox(height: 16),
      PreviewPanel(icon: Icons.inventory_2_outlined, title: 'Danh mục $category',
        caption: 'Chưa có món đồ nào trong bản xem trước'),
      const SizedBox(height: 16),
      OutlinedButton.icon(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm ảnh trang phục sẽ được tích hợp ở bước xử lý ảnh cục bộ.'))),
        icon: const Icon(Icons.add), label: const Text('Thêm món đồ')),
    ],
  );
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}
class _ProfileScreenState extends State<ProfileScreen> {
  bool cloudBackup = false;
  @override
  Widget build(BuildContext context) => SectionPage(
    title: 'Cá nhân', subtitle: 'Quyền riêng tư và dữ liệu',
    children: [
      const DemoNotice(), const SizedBox(height: 14),
      const ListTile(leading: Icon(Icons.lock_outline), title: Text('Đăng nhập'),
        subtitle: Text('Firebase Authentication áp dụng cho bản production; bản debug dùng giao diện phát triển')),
      SwitchListTile(
        value: cloudBackup,
        onChanged: null,
        title: const Text('Cloud Backup'),
        subtitle: const Text('Mặc định TẮT · Chưa triển khai · Không tự động tải dữ liệu'),
      ),
      const ListTile(leading: Icon(Icons.phone_android), title: Text('Local-first'),
        subtitle: Text('Ảnh cá nhân không được tự động tải lên Cloud')),
      const ListTile(leading: Icon(Icons.favorite_border), title: Text('Dream Wardrobe'),
        subtitle: Text('Danh sách yêu thích · Chưa triển khai lưu dữ liệu')),
    ],
  );
}
