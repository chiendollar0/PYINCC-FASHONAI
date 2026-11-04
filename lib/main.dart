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
  // Gracy Lee is a temporary technical test asset, not the official PYINCC avatar.
  bool _autoRotate = true;
  int _viewerGeneration = 0;
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
            child: Text('Chưa đóng gói GLB test vào ứng dụng. '
              'Kiểm tra assets/avatars/pyincc_avatar_primary.glb. '
              'GLB PYINCC chính thức sẽ được bổ sung sau.',
              textAlign: TextAlign.center)));
        }
        return Column(children: [
          Expanded(child: const bool.fromEnvironment('PYINCC_WIDGET_TEST') ? const SizedBox.expand() : ModelViewer(
            key: ValueKey('$_primary-$_viewerGeneration'),
            src: _primary,
            alt: 'Mô hình GLB thử nghiệm Gracy Lee',
            backgroundColor: sand,
            cameraControls: true,
            disablePan: true,
            disableZoom: true,
            autoRotate: _autoRotate,
            autoRotateDelay: 0,
            rotationPerSecond: '10deg',
            cameraOrbit: '0deg 90deg 120%',
            minCameraOrbit: '-180deg 65deg 120%',
            maxCameraOrbit: '180deg 115deg 120%',
            fieldOfView: '32deg',
            ar: false,
            loading: Loading.eager,
          )),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
            child: Column(children: [
              const Text('GLB Gracy Lee — mô hình thử nghiệm kỹ thuật. '
                'Avatar PYINCC chính thức sẽ được bổ sung sau.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: Colors.black54)),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                IconButton.filledTonal(
                  tooltip: _autoRotate ? 'Tạm dừng xoay tự động' : 'Tiếp tục xoay tự động',
                  icon: Icon(_autoRotate ? Icons.pause : Icons.play_arrow),
                  onPressed: () => setState(() => _autoRotate = !_autoRotate),
                ),
                IconButton.filledTonal(
                  tooltip: 'Đặt lại góc nhìn 3D',
                  icon: const Icon(Icons.restart_alt),
                  onPressed: () => setState(() {
                    _autoRotate = true;
                    _viewerGeneration++;
                  }),
                ),
              ]),
            ]),
          ),
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
      CharacterHomeScreen(
        onOpenStudio: () => setState(() => tab = 1),
        onOpenStore: () => setState(() => tab = 2),
        onOpenAccount: () => setState(() => tab = 3),
      ),
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
  final VoidCallback onOpenStudio;
  final VoidCallback onOpenStore;
  final VoidCallback onOpenAccount;
  const CharacterHomeScreen({
    super.key,
    required this.onOpenStudio,
    required this.onOpenStore,
    required this.onOpenAccount,
  });
  @override
  State<CharacterHomeScreen> createState() => _CharacterHomeScreenState();
}

class _CharacterHomeScreenState extends State<CharacterHomeScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _face;
  bool _loading = false;


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

  @override
  Widget build(BuildContext context) => SectionPage(
    title: 'PYINCC', subtitle: 'Fashion Studio',
    children: [
      GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.65,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _HomeQuickAction(icon: Icons.auto_awesome_outlined, title: 'Studio',
            subtitle: 'Không gian 3D', onTap: widget.onOpenStudio),
          _HomeQuickAction(icon: Icons.storefront_outlined, title: 'Store',
            subtitle: 'Danh mục sản phẩm', onTap: widget.onOpenStore),
          _HomeQuickAction(icon: Icons.checkroom_outlined, title: 'Tủ đồ',
            subtitle: 'Quản lý trang phục', onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const WardrobeScreen()))),
          _HomeQuickAction(icon: Icons.person_outline, title: 'Account',
            subtitle: 'Cài đặt cá nhân', onTap: widget.onOpenAccount),
        ],
      ),
      const SizedBox(height: 12),
      const Row(children: [
        Icon(Icons.face_retouching_natural_outlined, color: coffee),
        SizedBox(width: 10),
        Expanded(child: Text('Ảnh khuôn mặt',
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
          const Text('Ảnh chỉ được xem trong phiên hiện tại và chưa gửi lên máy chủ.',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
          FilledButton.icon(
            onPressed: null,
            icon: const Icon(Icons.lock_outline),
            label: const Text('Face Swap 3D chưa khả dụng'),
          ),
          const Text('Ảnh chỉ được xem trong phiên hiện tại. Chưa có engine '
            'Face Swap 3D đã kiểm chứng; không tạo kết quả giả.',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
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
      const Card(child: ListTile(
        leading: Icon(Icons.tune_outlined, color: accent),
        title: Text('Tùy chỉnh mô hình 3D'),
        subtitle: Text('Cấu hình tạo hình sẽ mở khi model PYINCC cuối cùng được tích hợp. '
          'Các thông số chưa được nối với GLB nên hiện chưa hiển thị điều khiển giả.'),
      )),

    ],
  );
}

/// Store deliberately contains no invented prices, brands or purchase URLs.
class _HomeQuickAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  const _HomeQuickAction({required this.icon, required this.title,
    required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: coffee, size: 20),
            const SizedBox(height: 3),
            Text(title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, height: 1.1,
                fontWeight: FontWeight.w700, color: coffee)),
            const SizedBox(height: 1),
            Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 9, height: 1.1,
                color: Colors.black54)),
          ],
        ),
      ),
    ),
  );
}

class StoreScreen extends StatelessWidget {
  final VoidCallback onTryOn;
  const StoreScreen({super.key, required this.onTryOn});
  @override
  Widget build(BuildContext context) => SectionPage(
    title: 'Store',
    subtitle: 'Chọn trang phục thật để thử',
    children: [
      const Card(child: ListTile(
        leading: Icon(Icons.inventory_2_outlined, color: accent),
        title: Text('Danh mục sản phẩm chưa kết nối'),
        subtitle: Text('Chưa có catalog, giá hoặc liên kết mua hàng đã xác minh.'),
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
  StudioTool? _activeTool;
  bool _autoRotate = true;
  int _viewerGeneration = 0;
  late final Future<AssetManifest> _assetManifest;

  @override
  void initState() {
    super.initState();
    _assetManifest = AssetManifest.loadFromAssetBundle(rootBundle);
  }

  Widget _menu(StudioTool tool) {
    final active = _activeTool?.key == tool.key;
    return Expanded(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: active ? coffee : Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: Semantics(
          button: true,
          selected: active,
          label: tool.semanticsLabel,
          child: Tooltip(
            message: tool.semanticsLabel,
            child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => setState(() => _activeTool = active ? null : tool),
            child: SizedBox(height: 66, child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(tool.icon, size: 22, color: active ? Colors.white : coffee),
                const SizedBox(height: 5),
                Text(tool.label, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                    color: active ? Colors.white : coffee)),
              ],
            )),
          ),
          ),
        ),
      ),
    ));
  }

  Widget _panelContent(StudioTool tool) {
    switch (tool.action) {
      case StudioToolAction.wardrobe:
        return OutlinedButton.icon(
          onPressed: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const WardrobeScreen())),
          icon: const Icon(Icons.inventory_2_outlined),
          label: const Text('Mở danh mục trang phục'),
        );
      case StudioToolAction.shop:
        return const Center(child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Chưa có catalog sản phẩm đã xác minh. '
            'Không hiển thị giá hoặc sản phẩm mẫu giả.',
            textAlign: TextAlign.center),
        ));
      case StudioToolAction.bigBag:
        return const Center(child: Padding(
          padding: EdgeInsets.all(12),
          child: Text('Tủ đồ hiện chưa có trang phục 3D. '
            'Chưa thể thử đồ hoặc tạo phối cảnh giả.',
            textAlign: TextAlign.center),
        ));
      case StudioToolAction.skinCare:
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Các hiệu ứng Skin Care chưa được kết nối với vật liệu GLB. '
            'Điều khiển đang khóa để tránh tạo cảm giác đã chỉnh sửa avatar.',
            style: TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 8),
          const _UnavailableEffectControl(label: 'Độ sáng', value: .5),
          const _UnavailableEffectControl(label: 'Má hồng', value: .2),
          const _UnavailableEffectControl(label: 'Son môi', value: .2),
        ]);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: SingleChildScrollView(child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
      Padding(padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Row(children: [
          const Expanded(child: Text('Studio · 3D',
            style: TextStyle(fontSize: 23, fontWeight: FontWeight.w600,
              color: coffee))),
          IconButton(tooltip: 'Đóng công cụ đang mở',
            icon: const Icon(Icons.close),
            onPressed: () => setState(() => _activeTool = null)),
        ])),
      SizedBox(
        height: (MediaQuery.sizeOf(context).height * 0.48).clamp(320.0, 520.0),
        child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(color: sand,
          borderRadius: BorderRadius.circular(22)),
        child: FutureBuilder<AssetManifest>(
          future: _assetManifest,
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
                child: Text('Chưa có GLB test trong bản build. '
                  'Kiểm tra assets/avatars/pyincc_avatar_primary.glb. '
                  'GLB PYINCC chính thức sẽ được bổ sung sau.',
                  textAlign: TextAlign.center)));
            }
            return Stack(children: [
              Positioned.fill(child: const bool.fromEnvironment('PYINCC_WIDGET_TEST') ? const SizedBox.expand() : ModelViewer(
                key: ValueKey('studio-avatar-$_viewerGeneration'),
                src: model,
                alt: 'Mô hình GLB thử nghiệm Gracy Lee',
                backgroundColor: sand,
                // Keep the avatar anchored in the viewport; slow auto-rotation
                // lets users inspect the model without dragging it off-center.
                cameraControls: true,
                disablePan: true,
                disableZoom: true,
                autoRotate: _autoRotate,
                autoRotateDelay: 0,
                rotationPerSecond: '10deg',
                cameraOrbit: '0deg 90deg 145%',
                minCameraOrbit: '-180deg 65deg 145%',
                maxCameraOrbit: '180deg 115deg 145%',
                fieldOfView: '38deg',
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
      )),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
        child: Column(children: [
          const Text('GLB Gracy Lee — mô hình thử nghiệm kỹ thuật. '
            'Avatar PYINCC chính thức sẽ được bổ sung sau.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: Colors.black54)),
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            IconButton(
              tooltip: _autoRotate ? 'Tạm dừng xoay tự động' : 'Tiếp tục xoay tự động',
              visualDensity: VisualDensity.compact,
              icon: Icon(_autoRotate ? Icons.pause : Icons.play_arrow),
              onPressed: () => setState(() => _autoRotate = !_autoRotate),
            ),
            IconButton(
              tooltip: 'Đặt lại góc nhìn 3D',
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.restart_alt),
              onPressed: () => setState(() {
                _autoRotate = true;
                _viewerGeneration++;
              }),
            ),
            const Text('Xoay tự động chậm · Kéo một ngón để đổi góc nhìn',
              style: TextStyle(fontSize: 10, color: Colors.black54)),
          ]),
        ]),
      ),
      Padding(padding: const EdgeInsets.fromLTRB(9, 8, 9, 10),
        child: Row(children: [
          ...StudioTool.all.map(_menu),
        ])),
      if (_activeTool != null) Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 16),
        constraints: const BoxConstraints(maxHeight: 240),
        decoration: BoxDecoration(color: Colors.white,
          borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(children: [
              Expanded(child: Text(_activeTool!.label,
                style: const TextStyle(fontSize: 14,
                  fontWeight: FontWeight.w700, color: coffee))),
              IconButton(
                tooltip: 'Đóng bảng công cụ',
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 20),
                onPressed: () => setState(() => _activeTool = null),
              ),
            ]),
            Flexible(child: SingleChildScrollView(child: _panelContent(_activeTool!))),
          ],
        )),

    ]))),
  );
}

enum StudioToolAction { skinCare, wardrobe, shop, bigBag }

class StudioTool {
  final String key;
  final String label;
  final String semanticsLabel;
  final IconData icon;
  final StudioToolAction action;
  const StudioTool({required this.key, required this.label,
    required this.semanticsLabel, required this.icon, required this.action});

  static const all = <StudioTool>[
    StudioTool(key: 'skin-care', label: 'Skin Care', semanticsLabel: 'Mở công cụ Skin Care', icon: Icons.auto_awesome_outlined, action: StudioToolAction.skinCare),
    StudioTool(key: 'wardrobe', label: 'Tủ đồ', semanticsLabel: 'Mở công cụ Tủ đồ', icon: Icons.checkroom_outlined, action: StudioToolAction.wardrobe),
    StudioTool(key: 'shop', label: 'Shop', semanticsLabel: 'Mở công cụ Shop', icon: Icons.storefront_outlined, action: StudioToolAction.shop),
    StudioTool(key: 'big-bag', label: 'Big Bag', semanticsLabel: 'Mở công cụ Big Bag', icon: Icons.shopping_bag_outlined, action: StudioToolAction.bigBag),
  ];
}

class _UnavailableEffectControl extends StatelessWidget {
  final String label;
  final double value;
  const _UnavailableEffectControl({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(children: [
    SizedBox(width: 100, child: Text(label)),
    Expanded(child: Slider(value: value, onChanged: null)),
    const SizedBox(width: 8),
    const Icon(Icons.lock_outline, size: 16, color: Colors.black45),
  ]);
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
