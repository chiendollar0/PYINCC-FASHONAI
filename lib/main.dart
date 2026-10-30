import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show AssetManifest, rootBundle;
import 'production_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

void main() => runApp(const PyinccApp());

const cream = Color(0xFFFAF7F1);
const coffee = Color(0xFF42362F);
const sand = Color(0xFFF0E9DD);
const accent = Color(0xFFAA8563);

const List<StudioMenuItem> kStudioMenuItems = [
  StudioMenuItem(
    key: 'skin-care',
    label: 'Skin Care',
    icon: Icons.auto_awesome_outlined,
    accessibilityLabel: 'Mở điều khiển Skin Care',
  ),
  StudioMenuItem(
    key: 'wardrobe',
    label: 'Tủ đồ',
    icon: Icons.checkroom_outlined,
    accessibilityLabel: 'Mở danh mục Tủ đồ',
  ),
  StudioMenuItem(
    key: 'shop',
    label: 'Shop',
    icon: Icons.storefront_outlined,
    accessibilityLabel: 'Mở Shop',
  ),
  StudioMenuItem(
    key: 'big-bag',
    label: 'Big Bag',
    icon: Icons.shopping_bag_outlined,
    accessibilityLabel: 'Mở Big Bag',
  ),
];

class StudioMenuItem {
  final String key;
  final String label;
  final IconData icon;
  final String accessibilityLabel;

  const StudioMenuItem({
    required this.key,
    required this.label,
    required this.icon,
    required this.accessibilityLabel,
  });
}

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
      colorScheme: ColorScheme.fromSeed(seedColor: accent, surface: cream),
      appBarTheme: const AppBarTheme(backgroundColor: cream, centerTitle: false),
      cardTheme: CardThemeData(color: Colors.white, elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
    ),
    home: kDebugMode && !requireAuthentication
        ? const HomeShell()
        : ProductionAuthGate(authenticatedBuilder: (_) => const HomeShell()),
  );
}

/// Viewer for the user's actual scan meshes, loaded from bundled Flutter assets.
/// Never substitutes a third-party demo character when the scan is unavailable.
class SampleAvatar3DScreen extends StatefulWidget {
  const SampleAvatar3DScreen({super.key});

  @override
  State<SampleAvatar3DScreen> createState() => _SampleAvatar3DScreenState();
}

class _SampleAvatar3DScreenState extends State<SampleAvatar3DScreen> {
  static const _primary = 'assets/avatars/pyincc_avatar_primary.glb';
  // One approved avatar only.
  late final Future<Set<String>> _available = _loadAssets();

  Future<Set<String>> _loadAssets() async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    return manifest.listAssets().toSet();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('PYINCC · Nhân vật 3D')),
    body: SafeArea(child: FutureBuilder<Set<String>>(
      future: _available,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Không đọc được danh sách asset 3D.'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final available = snapshot.data!;
        if (!available.contains(_primary)) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(24),
            child: Text('Chưa đóng gói GLB nữ PYINCC vào ứng dụng. '
              'Cần thêm file trong assets/avatars/ và build lại. '
              'Không sử dụng nhân vật demo thay thế.',
              textAlign: TextAlign.center)));
        }
        return Column(children: [
          Expanded(child: const bool.fromEnvironment('PYINCC_WIDGET_TEST') ? const SizedBox.expand() : ModelViewer(
            key: const ValueKey(_primary),
            src: _primary,
            alt: 'Nhân vật nữ PYINCC GLB quét 3D',
            backgroundColor: sand,
            cameraControls: true,
            autoRotate: true,
            cameraOrbit: '0deg 90deg 120%',
            fieldOfView: '32deg',
            ar: false,
            loading: Loading.eager,
          )),

        ]);
      },
    )),
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
  int tab = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: tab, children: [
      const CharacterHomeScreen(),
      const UnifiedStudioScreen(),
      StoreScreen(onTryOn: () => setState(() => tab = 1)),
      const ProfileScreen(),
    ])),
    bottomNavigationBar: NavigationBar(
      backgroundColor: Colors.white,
      indicatorColor: sand,
      height: 68,
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'Studio'),
        NavigationDestination(icon: Icon(Icons.shopping_bag_outlined), label: 'Store'),
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
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ảnh không hợp lệ. Chọn PNG, JPG hoặc WEBP.')));
      }
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
    title: 'PYINCC', subtitle: 'Fashion Studio',
    children: [
      const Row(children: [
        Icon(Icons.face_retouching_natural_outlined, color: coffee),
        SizedBox(width: 10),
        Expanded(child: Text('Fake · Face Swap',
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
    
        ]))),
      const SizedBox(height: 12),
      FilledButton.tonalIcon(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const SampleAvatar3DScreen())),
        icon: const Icon(Icons.view_in_ar_outlined),
        label: const Text('Xem nhân vật 3D'),
      ),
      const SizedBox(height: 16),
      const Text('Thông số nhân vật', style: TextStyle(
        fontSize: 18, fontWeight: FontWeight.w600)),

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
      const Card(child: ListTile(
        leading: Icon(Icons.link, color: accent),
        title: Text('Nguồn sản phẩm'),
        subtitle: Text('Shopee · Lazada · TikTok Shop'),
      )), 
      const SizedBox(height: 16),
      OutlinedButton.icon(
        onPressed: onTryOn,
        icon: const Icon(Icons.auto_awesome),
        label: const Text('Về Studio để thử đồ'),
      ),
    ],
  );
}

/// Studio v2: 3D-only navigation; no 2D image-overlay workflow.
class UnifiedStudioScreen extends StatefulWidget {
  const UnifiedStudioScreen({super.key});
  @override
  State<UnifiedStudioScreen> createState() => _UnifiedStudioScreenState();
}

class _UnifiedStudioScreenState extends State<UnifiedStudioScreen> {
  String? _panel;
  double _brightness = .5, _blush = .2, _lip = .2;

  void _notice(String message) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(message)));

  Widget _menuButton(StudioMenuItem item) {
    final active = _panel == item.key;
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Semantics(
          button: true,
          selected: active,
          label: item.accessibilityLabel,
          child: Material(
            color: active ? coffee : Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() => _panel = active ? null : item.key),
              child: SizedBox(
                height: 66,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 22, color: active ? Colors.white : coffee),
                    const SizedBox(height: 5),
                    Text(item.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                        color: active ? Colors.white : coffee)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _panelContent() {
    switch (_panel) {
      case 'wardrobe':
        return OutlinedButton.icon(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const WardrobeScreen())),
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('Mở danh mục trang phục'),
        );
      case 'shop':
        return const Center(child: Text('Chưa chọn sản phẩm'));
      case 'big-bag':
        return const Center(child: Text('Chưa có trang phục'));
      case 'skin-care':
        return Column(children: [
          Row(children: [const SizedBox(width: 100, child: Text('Độ sáng')),
            Expanded(child: Slider(value: _brightness,
              onChanged: (v) => setState(() => _brightness = v)))]),
          Row(children: [const SizedBox(width: 100, child: Text('Má hồng')),
            Expanded(child: Slider(value: _blush,
              onChanged: (v) => setState(() => _blush = v)))]),
          Row(children: [const SizedBox(width: 100, child: Text('Son môi')),
            Expanded(child: Slider(value: _lip,
              onChanged: (v) => setState(() => _lip = v)))]),

        ]);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _viewport() {
    return Container(
      width: double.infinity,
      height: 340,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(color: sand,
        borderRadius: BorderRadius.circular(22)),
      child: FutureBuilder<AssetManifest>(
        future: AssetManifest.loadFromAssetBundle(rootBundle),
        builder: (context, snapshot) {
          const model = 'assets/avatars/pyincc_avatar_primary.glb';
          if (snapshot.hasError) {
            return const Center(child: Text('Không đọc được asset 3D.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.data!.listAssets().contains(model)) {
            return const Center(child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Chưa có GLB PYINCC trong bản build. '
                'Thêm assets/avatars/pyincc_avatar_primary.glb để '
                'hiển thị avatar 3D offline.',
                textAlign: TextAlign.center)));
          }
          return Stack(children: [
            Positioned.fill(child: const bool.fromEnvironment('PYINCC_WIDGET_TEST') ? const SizedBox.expand() : ModelViewer(
              src: model,
              alt: 'Avatar PYINCC toàn thân xoay 360 độ',
              backgroundColor: sand,
              cameraControls: true,
              autoRotate: true,
              cameraOrbit: '0deg 90deg auto',
              fieldOfView: '30deg',
              ar: false,
              loading: Loading.eager,
            )),
            Positioned(top: 8, right: 8, child: IconButton.filledTonal(
              tooltip: 'Xem toàn màn hình',
              icon: const Icon(Icons.fullscreen),
              onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) =>
                  const SampleAvatar3DScreen())),
            )),
          ]);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Column(children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          const Expanded(child: Text('Studio · 3D',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600,
              color: coffee))),
          IconButton(tooltip: 'Hoàn tác', icon: const Icon(Icons.undo),
            onPressed: () => _notice('Chưa có thao tác phối đồ để hoàn tác.')),
          IconButton(tooltip: 'Đặt lại', icon: const Icon(Icons.restart_alt),
            onPressed: () => setState(() {
              _panel = null; _brightness = .5; _blush = .2; _lip = .2;
            })),
        ])),
      _viewport(),
      Padding(
        padding: const EdgeInsets.fromLTRB(9, 10, 9, 10),
        child: Row(
          children: kStudioMenuItems.map(_menuButton).toList(),
        ),
      ),
      if (_panel != null) Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        constraints: const BoxConstraints(maxHeight: 190),
        decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(child: _panelContent())),

    ])),
  );
}

class SectionPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const SectionPage({super.key, required this.title, required this.subtitle, required this.children});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: ListView(padding: const EdgeInsets.fromLTRB(20, 18, 20, 28), children: [
    Text(title, style: const TextStyle(fontSize: 27, fontWeight: FontWeight.w700, color: coffee)),
    const SizedBox(height: 5),
    Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.black54)),
    const SizedBox(height: 18),
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
      Card(child: ListTile(
        leading: const Icon(Icons.checkroom_outlined, color: accent),
        title: Text(category),
        subtitle: const Text('Chưa có trang phục'),
      )),
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
