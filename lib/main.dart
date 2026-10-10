import 'package:flutter/material.dart';

void main() => runApp(const PyinccApp());

const cream = Color(0xFFF9F6F0);
const coffee = Color(0xFF6E5749);
const sand = Color(0xFFEDE3D7);

class PyinccApp extends StatelessWidget {
  const PyinccApp({super.key});

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
    home: const WelcomeScreen(),
  );
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Spacer(),
        const Icon(Icons.checkroom_outlined, size: 90, color: coffee),
        const SizedBox(height: 22),
        const Text('Pyincc\nFashionAI', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 42, height: 1.08, fontWeight: FontWeight.w700, color: coffee)),
        const SizedBox(height: 12),
        const Text('Thử đồ ảo. Phong cách thật.', textAlign: TextAlign.center,
          style: TextStyle(fontSize: 17)),
        const SizedBox(height: 24),
        const Text('Khám phá phong cách qua trải nghiệm thời trang số. Ảnh cá nhân được giữ trên thiết bị theo mặc định.',
          textAlign: TextAlign.center),
        const Spacer(),
        const DemoNotice(),
        const SizedBox(height: 18),
        FilledButton(onPressed: () => Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeShell())),
          child: const Padding(padding: EdgeInsets.all(12), child: Text('Bắt đầu xem giao diện'))),
        const SizedBox(height: 12),
        const Text('Chế độ xem trước UI · Chưa kích hoạt đăng nhập hoặc AI',
          textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.black54)),
      ]),
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
  int tab = 0;
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: IndexedStack(index: tab, children: [
      const UnifiedStudioScreen(),
      Dashboard(onOpen: (_) => setState(() => tab = 0)),
      const ProfileScreen(),
    ])),
    bottomNavigationBar: NavigationBar(
      selectedIndex: tab,
      onDestinationSelected: (i) => setState(() => tab = i),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), label: 'Studio'),
        NavigationDestination(icon: Icon(Icons.explore_outlined), label: 'Khám phá'),
        NavigationDestination(icon: Icon(Icons.person_outline), label: 'Cá nhân'),
      ],
    ),
  );
}

class UnifiedStudioScreen extends StatelessWidget {
  const UnifiedStudioScreen({super.key});
  @override
  Widget build(BuildContext context) => SectionPage(
    title: 'Studio',
    subtitle: 'Nhân vật · Tủ đồ · Thử đồ · Làm đẹp',
    children: [
      const DemoNotice(),
      const SizedBox(height: 16),
      const PreviewPanel(icon: Icons.add_photo_alternate_outlined, title: 'Bước 1 · Import ảnh PNG chân dung thật',
        caption: 'Ảnh của bạn hoặc ảnh được phép sử dụng. Chọn ảnh trên thiết bị sẽ được tích hợp ở giai đoạn xử lý ảnh cục bộ.'),
      const SizedBox(height: 12),
      const Text('Bước 2 · Chọn cách tạo nhân vật', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      const ListTile(leading: Icon(Icons.person_outline), title: Text('Render nhân vật 2D'),
        subtitle: Text('Từ ảnh chân dung đã nhập · Chưa khả dụng')),
      const ListTile(leading: Icon(Icons.swap_horiz), title: Text('Face swap với mẫu có sẵn'),
        subtitle: Text('Chỉ dùng ảnh có sự đồng ý · Chưa khả dụng')),
      const SizedBox(height: 8),
      const Text('Bước 3 · Chỉnh sửa trong Studio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 18),
      FeatureTile(icon: Icons.inventory_2_outlined, title: 'Tủ đồ',
        detail: 'Quản lý và chọn trang phục', onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const WardrobeScreen()))),
      FeatureTile(icon: Icons.checkroom_outlined, title: 'Thử đồ',
        detail: 'Xem bố cục thử đồ 2D', onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const TryOnScreen()))),
      FeatureTile(icon: Icons.face_retouching_natural_outlined, title: 'Làm đẹp',
        detail: 'Điều chỉnh phong cách trong Studio', onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const BeautyScreen()))),
      FeatureTile(icon: Icons.view_in_ar_outlined, title: 'Avatar 3D',
        detail: 'Tính năng tương lai, chưa có trong MVP', onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const FutureScreen()))),
    ],
  );
}

class SectionPage extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  const SectionPage({super.key, required this.title, required this.subtitle, required this.children});
  @override
  Widget build(BuildContext context) => ListView(padding: const EdgeInsets.all(20), children: [
    Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: coffee)),
    const SizedBox(height: 6),
    Text(subtitle, style: const TextStyle(color: Colors.black54)),
    const SizedBox(height: 22),
    ...children,
  ]);
}

class FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String detail;
  final VoidCallback onTap;
  const FeatureTile({super.key, required this.icon, required this.title, required this.detail, required this.onTap});
  @override
  Widget build(BuildContext context) => Card(child: ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
    leading: CircleAvatar(backgroundColor: sand, child: Icon(icon, color: coffee)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
    subtitle: Text(detail),
    trailing: const Icon(Icons.chevron_right),
    onTap: onTap,
  ));
}

class Dashboard extends StatelessWidget {
  final ValueChanged<int> onOpen;
  const Dashboard({super.key, required this.onOpen});
  @override
  Widget build(BuildContext context) => SectionPage(
    title: 'Trang Chủ',
    subtitle: 'Bảng điều khiển thời trang · PYINCC FashionAI',
    children: [
      const DemoNotice(), const SizedBox(height: 16),
      FeatureTile(icon: Icons.checkroom, title: 'Thử Đồ AI',
        detail: 'Trải nghiệm trang phục 2D', onTap: () => onOpen(1)),
      FeatureTile(icon: Icons.inventory_2_outlined, title: 'Tủ Đồ AI',
        detail: 'Danh mục trang phục cá nhân', onTap: () => onOpen(2)),
      FeatureTile(icon: Icons.face_retouching_natural, title: 'Làm Đẹp',
        detail: 'Son, má hồng và phong cách', onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const BeautyScreen()))),
      FeatureTile(icon: Icons.auto_awesome, title: 'Fashion Studio',
        detail: 'Ý tưởng và bối cảnh sáng tạo', onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const StudioScreen()))),
      FeatureTile(icon: Icons.view_in_ar, title: 'Avatar 3D',
        detail: 'Tính năng tương lai', onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const FutureScreen()))),
    ],
  );
}

class TryOnScreen extends StatefulWidget {
  const TryOnScreen({super.key});
  @override
  State<TryOnScreen> createState() => _TryOnScreenState();
}
class _TryOnScreenState extends State<TryOnScreen> {
  String quality = 'Cân bằng';
  @override
  Widget build(BuildContext context) => SectionPage(
    title: 'Thử Đồ AI', subtitle: 'Trình chỉnh sửa thử đồ ảo 2D',
    children: [
      const PreviewPanel(icon: Icons.person_outline, title: 'Ảnh toàn thân',
        caption: 'Chọn ảnh hoặc chụp ảnh sẽ được tích hợp sau'),
      const SizedBox(height: 16),
      const Text('Chọn trang phục để thử', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 10),
      const Wrap(spacing: 8, children: [
        Chip(label: Text('Áo')), Chip(label: Text('Quần')),
        Chip(label: Text('Váy')), Chip(label: Text('Phụ kiện')),
      ]),
      const SizedBox(height: 18),
      const Text('Chất lượng hình ảnh', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      SegmentedButton<String>(segments: const [
        ButtonSegment(value: 'Tiết kiệm', label: Text('Tiết kiệm')),
        ButtonSegment(value: 'Cân bằng', label: Text('Cân bằng')),
        ButtonSegment(value: 'HD', label: Text('HD')),
      ], selected: {quality}, onSelectionChanged: (v) => setState(() => quality = v.first)),
      const SizedBox(height: 16),
      OutlinedButton.icon(onPressed: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => const BeautyScreen())),
        icon: const Icon(Icons.face_retouching_natural), label: const Text('Mở Studio Làm Đẹp')),
      const SizedBox(height: 20),
      FilledButton(onPressed: () => Navigator.push(context,
        MaterialPageRoute(builder: (_) => const ResultScreen())),
        child: const Text('Xem bố cục kết quả mẫu')),
      const SizedBox(height: 8),
      const Text('Chưa chạy AI. Không tạo ảnh giả hoặc gửi ảnh lên máy chủ.',
        style: TextStyle(fontSize: 12, color: Colors.black54)),
    ],
  );
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

class BeautyScreen extends StatefulWidget {
  const BeautyScreen({super.key});
  @override
  State<BeautyScreen> createState() => _BeautyScreenState();
}
class _BeautyScreenState extends State<BeautyScreen> {
  double lipstick = .65, blush = .48, eyes = .55;
  @override
  Widget build(BuildContext context) => SectionPage(
    title: 'Studio Làm Đẹp', subtitle: 'Tinh chỉnh diện mạo tự nhiên',
    children: [
      const PreviewPanel(icon: Icons.face_retouching_natural, title: 'Xem trước',
        caption: 'Các thanh điều khiển chỉ mô phỏng UI, chưa chỉnh sửa ảnh'),
      const SizedBox(height: 18),
      _control('Son môi', lipstick, (v) => setState(() => lipstick = v)),
      _control('Má hồng', blush, (v) => setState(() => blush = v)),
      _control('Mắt', eyes, (v) => setState(() => eyes = v)),
      const Wrap(spacing: 8, children: [
        Chip(label: Text('Tự nhiên')), Chip(label: Text('Thanh lịch')),
        Chip(label: Text('Hồng nhẹ')), Chip(label: Text('Glowy')),
      ]),
    ],
  );
  Widget _control(String name, double value, ValueChanged<double> onChanged) =>
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('$name · ${(value * 100).round()}%'),
      Slider(value: value, onChanged: onChanged),
    ]);
}

class StudioScreen extends StatelessWidget {
  const StudioScreen({super.key});
  @override
  Widget build(BuildContext context) => SectionPage(
    title: 'Fashion Studio', subtitle: 'Không gian sáng tạo phong cách',
    children: [
      const PreviewPanel(icon: Icons.auto_awesome_outlined, title: 'Studio',
        caption: 'Bối cảnh, ánh sáng và góc chụp sẽ được kết nối với AI sau'),
      const SizedBox(height: 16),
      FeatureTile(icon: Icons.view_in_ar, title: 'Studio Avatar 3D',
        detail: 'Tính năng tương lai, ngoài MVP', onTap: () =>
          Navigator.push(context, MaterialPageRoute(builder: (_) => const FutureScreen()))),
    ],
  );
}

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key});
  @override
  State<ResultScreen> createState() => _ResultScreenState();
}
class _ResultScreenState extends State<ResultScreen> {
  double compare = .5;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kết quả Thử Đồ')),
    body: ListView(padding: const EdgeInsets.all(20), children: [
      const DemoNotice(), const SizedBox(height: 16),
      const PreviewPanel(icon: Icons.compare_outlined, title: 'Trước / Sau',
        caption: 'Chưa có ảnh kết quả AI. Khu vực này dành cho so sánh ảnh thật.'),
      const SizedBox(height: 16),
      Text('Thanh trượt Trước / Sau · ${(compare * 100).round()}%'),
      Slider(value: compare, onChanged: (v) => setState(() => compare = v)),
      const Wrap(spacing: 10, children: [
        Chip(label: Text('Lưu · Chưa khả dụng')),
        Chip(label: Text('Chia sẻ · Chưa khả dụng')),
        Chip(label: Text('Thử lại · Chưa khả dụng')),
      ]),
    ]),
  );
}

class FutureScreen extends StatelessWidget {
  const FutureScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Studio Avatar 3D')),
    body: const Center(child: Padding(padding: EdgeInsets.all(24),
      child: Text('Avatar 3D là tính năng tương lai, chưa triển khai trong MVP.',
        textAlign: TextAlign.center))),
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
        subtitle: Text('Firebase Authentication sẽ được tích hợp sau khi UI ổn định')),
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
