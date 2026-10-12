import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProductionAuthGate extends StatefulWidget {
  final WidgetBuilder authenticatedBuilder;
  const ProductionAuthGate({super.key, required this.authenticatedBuilder});
  @override
  State<ProductionAuthGate> createState() => _ProductionAuthGateState();
}

class _ProductionAuthGateState extends State<ProductionAuthGate> {
  late final Future<FirebaseApp> _initialization = _initialize();
  Future<FirebaseApp> _initialize() async {
    const apiKey = String.fromEnvironment('FIREBASE_API_KEY');
    const appId = String.fromEnvironment('FIREBASE_APP_ID');
    const senderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
    const projectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
    if ([apiKey, appId, senderId, projectId].any((v) => v.isEmpty)) {
      throw StateError('Missing Firebase configuration');
    }
    return Firebase.initializeApp(options: const FirebaseOptions(
      apiKey: apiKey, appId: appId, messagingSenderId: senderId,
      projectId: projectId,
      iosBundleId: 'com.pyincc.fashionai',
    )).timeout(const Duration(seconds: 20));
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<FirebaseApp>(
    future: _initialization,
    builder: (context, initialization) {
      if (initialization.hasError) {
        return const AuthBlockedScreen(
          message: 'Không thể khởi tạo đăng nhập. Kiểm tra cấu hình Firebase và kết nối mạng.');
      }
      if (initialization.connectionState != ConnectionState.done) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      final auth = FirebaseAuth.instanceFor(app: initialization.requireData);
      return StreamBuilder<User?>(
        stream: auth.authStateChanges(),
        builder: (context, session) {
          if (session.hasError) {
            return const AuthBlockedScreen(message: 'Không thể xác minh phiên đăng nhập.');
          }
          if (session.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          final user = session.data;
          if (user == null || user.isAnonymous) return SignInScreen(auth: auth);
          // All authenticated routes belong to this navigator. Signing out
          // disposes the navigator, including any pushed Studio routes.
          return Navigator(
            key: ValueKey(user.uid),
            onGenerateRoute: (_) => MaterialPageRoute<void>(
              builder: (context) => Scaffold(
                appBar: AppBar(title: const Text('PYINCC FashionAI'), actions: [
                  IconButton(
                    tooltip: 'Đăng xuất',
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      try {
                        await auth.signOut();
                      } catch (_) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Không thể đăng xuất. Hãy thử lại.')));
                        }
                      }
                    },
                  ),
                ]),
                body: widget.authenticatedBuilder(context),
              ),
            ),
          );
        },
      );
    },
  );
}

class AuthBlockedScreen extends StatelessWidget {
  final String message;
  const AuthBlockedScreen({super.key, required this.message});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(child: Center(child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.lock_outline, size: 48),
        const SizedBox(height: 16),
        const Text('Đăng nhập chưa sẵn sàng', style: TextStyle(fontSize: 22)),
        const SizedBox(height: 12),
        Text(message, textAlign: TextAlign.center),
      ]),
    ))),
  );
}

class SignInScreen extends StatefulWidget {
  final FirebaseAuth auth;
  const SignInScreen({super.key, required this.auth});
  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_busy || !_form.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() { _busy = true; _error = null; });
    try {
      await widget.auth.signInWithEmailAndPassword(
        email: _email.text.trim(), password: _password.text);
    } on FirebaseAuthException catch (error) {
      if (mounted) {
        setState(() => _error = switch (error.code) {
          'network-request-failed' => 'Không có kết nối mạng. Hãy thử lại.',
          'too-many-requests' => 'Có quá nhiều yêu cầu. Hãy thử lại sau.',
          'operation-not-allowed' => 'Đăng nhập email chưa được bật cho ứng dụng.',
          _ => 'Không đăng nhập được. Kiểm tra email và mật khẩu.',
        });
      }
    } catch (_) {
      if (mounted) setState(() => _error = 'Không đăng nhập được. Hãy thử lại.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Đăng nhập')),
    body: SafeArea(child: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420),
        child: Form(key: _form, child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min, children: [
          TextFormField(
            controller: _email, enabled: !_busy,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (v) => v != null && RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v.trim())
                ? null : 'Nhập email hợp lệ',
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _password, enabled: !_busy, obscureText: true,
            autofillHints: const [AutofillHints.password],
            decoration: const InputDecoration(labelText: 'Mật khẩu'),
            validator: (v) => v == null || v.isEmpty ? 'Nhập mật khẩu' : null,
            onFieldSubmitted: (_) => _signIn(),
          ),
          if (_error != null) Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(_error!),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _busy ? null : _signIn,
            child: Text(_busy ? 'Đang đăng nhập…' : 'Đăng nhập'),
          ),
        ])),
      ),
    ))),
  );
}
