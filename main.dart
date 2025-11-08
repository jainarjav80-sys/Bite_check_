import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const ProviderScope(child: BiteCheckApp()));
}

/// Simple provider to hold authentication/onboarding state in this demo
final appStateProvider = StateProvider<AppState>((ref) => AppState());

class AppState {
  bool onboarded = false;
  bool loggedIn = false;
}

/// App entry
class BiteCheckApp extends ConsumerWidget {
  const BiteCheckApp({super.key});

  static const _maxPhoneWidth = 420.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'BiteCheck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFFDF6F9),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 18),
          ),
        ),
      ),
      home: LayoutBuilder(builder: (context, constraints) {
        // Constrain to phone-like width so web/desktop shows mobile layout centered
        final width = constraints.maxWidth;
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: width < _maxPhoneWidth ? width : _maxPhoneWidth,
              maxHeight: constraints.maxHeight,
            ),
            child: const RootNavigator(),
          ),
        );
      }),
    );
  }
}

/// Root navigator decides which initial screen to show
class RootNavigator extends ConsumerWidget {
  const RootNavigator({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appStateProvider);
    // Show splash first, then onboarding/login flow automatically
    return const SplashScreen();
  }
}

// --------------------------- SPLASH ---------------------------
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
    Future.delayed(const Duration(seconds: 2), _navigateNext);
  }

  void _navigateNext() {
    // After splash show onboarding
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const OnboardingFlow(),
        transitionsBuilder: (_, a, __, c) {
          return FadeTransition(opacity: a, child: c);
        },
      ),
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final logoSize = 110.0;
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(24),
          color: Theme.of(context).primaryColor.withOpacity(0.06),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: CurvedAnimation(parent: _anim, curve: Curves.easeOutBack),
                  child: Container(
                    width: logoSize,
                    height: logoSize,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.restaurant_menu, color: Colors.green, size: 56),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'BiteCheck',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                const Text('Scan food • Get nutrition • Chat AI'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --------------------------- ONBOARDING FLOW ---------------------------
class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});
  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageC = PageController();
  int _page = 0;

  void _goNext() {
    if (_page < 2) {
      _pageC.nextPage(duration: const Duration(milliseconds: 400), curve: Curves.ease);
    } else {
      // finish -> go to Login
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  void dispose() {
    _pageC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _OnboardCard(
        title: 'Welcome to BiteCheck',
        subtitle: 'Snap a picture of your meal and get nutrition insights instantly.',
        icon: Icons.camera_alt,
      ),
      _OnboardCard(
        title: 'Track macros',
        subtitle: 'Easily maintain daily goals and see macro breakdowns.',
        icon: Icons.pie_chart,
      ),
      _OnboardCard(
        title: 'Ask the AI',
        subtitle: 'Get advice, recipes and tips using our AI chat assistant.',
        icon: Icons.chat_bubble,
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageC,
                  onPageChanged: (p) => setState(() => _page = p),
                  children: pages,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    margin: const EdgeInsets.all(6),
                    width: _page == i ? 22 : 10,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _page == i ? Colors.green : Colors.green.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton(
                onPressed: _goNext,
                child: Text(_page == pages.length - 1 ? 'Get Started' : 'Next'),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _OnboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _OnboardCard({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 22),
        Container(
          height: 220,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12)],
          ),
          child: Center(
            child: Icon(icon, color: Colors.green, size: 86),
          ),
        ),
        const SizedBox(height: 22),
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
        ),
      ],
    );
  }
}

// --------------------------- LOGIN ---------------------------


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _pw = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 18),
              TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pw,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              const SizedBox(height: 18),
              ElevatedButton(
                onPressed: () {
                  // ✅ Now 'ref' works correctly here
                  ref.read(appStateProvider.notifier).state.loggedIn = true;

                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainTabs()),
                  );
                },
                child: const Text('Login'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainTabs()),
                  );
                },
                child: const Text('Continue as Guest'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// --------------------------- MAIN TABS ---------------------------
class MainTabs extends StatefulWidget {
  const MainTabs({super.key});
  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _index = 1; // show Scan by default

  final List<Widget> _pages = const [
    HomeScreen(),
    ScanScreen(),
    ChatScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_index]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        selectedItemColor: Colors.green[800],
        type: BottomNavigationBarType.fixed,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt_outlined), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

// --------------------------- HOME SCREEN ---------------------------
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BiteCheck Home'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Welcome!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                Text('Scan your meal or chat with the AI for tips and recipes.'),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: () {
              // go to scan
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScanScreen()));
            },
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scan a meal'),
          ),
          const SizedBox(height: 18),
          // quick cards
          Row(
            children: [
              _InfoTile(title: 'Calories', value: '—'),
              const SizedBox(width: 10),
              _InfoTile(title: 'Protein', value: '—'),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String value;
  const _InfoTile({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title, style: const TextStyle(color: Colors.black54)), Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))],
        ),
      ),
    );
  }
}

// --------------------------- SCAN SCREEN ---------------------------
class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});
  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  XFile? _picked;
  final ImagePicker _picker = ImagePicker();
  bool _busy = false;
  String _predicted = '';

  Future<void> _pickFromGallery() async {
    final f = await _picker.pickImage(source: ImageSource.gallery, maxWidth: 1024);
    if (f == null) return;
    setState(() { _picked = f; });
  }

  Future<void> _pickFromCamera() async {
    final f = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1024);
    if (f == null) return;
    setState(() { _picked = f; });
  }

  Future<void> _predict() async {
    if (_picked == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select an image first')));
      return;
    }
    setState(() { _busy = true; _predicted = ''; });
    // TODO: integrate backend or TFLite call here. For demo we mock result.
    await Future.delayed(const Duration(seconds: 2));
    setState(() { _predicted = 'Mock Pizza 🍕 (45%)'; _busy = false; });
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      height: 180,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(child: Text('No image selected', style: TextStyle(color: Colors.black54))),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Scan Your Meal 🍽️')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            children: [
              if (_picked != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(File(_picked!.path), height: 180, width: double.infinity, fit: BoxFit.cover),
                )
              else
                placeholder,
              const SizedBox(height: 18),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                ElevatedButton.icon(onPressed: _pickFromCamera, icon: const Icon(Icons.camera_alt), label: const Text('Camera')),
                ElevatedButton.icon(onPressed: _pickFromGallery, icon: const Icon(Icons.photo_library), label: const Text('Gallery')),
              ]),
              const SizedBox(height: 18),
              ElevatedButton(onPressed: _busy ? null : _predict, child: _busy ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Predict Food 🍔')),
              const SizedBox(height: 12),
              if (_predicted.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.all(14),
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: Text('Result: $_predicted', style: const TextStyle(fontSize: 16)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// --------------------------- CHAT SCREEN ---------------------------
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final List<_Msg> _messages = [
    _Msg(text: 'Hi there — I can help estimate nutrition. Try "pizza 1 slice".', fromUser: false)
  ];
  final TextEditingController _ctrl = TextEditingController();
  bool _sending = false;

  void _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(text: text, fromUser: true));
      _ctrl.clear();
      _sending = true;
    });
    // Simulate response
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _messages.add(_Msg(text: 'Mock reply: That looks like ~250 kcal per slice.', fromUser: false));
      _sending = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Chat')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  return Align(
                    alignment: m.fromUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: m.fromUser ? Colors.green[600] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(m.text, style: TextStyle(color: m.fromUser ? Colors.white : Colors.black87)),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(hintText: 'Ask me about food, recipes or calories...'),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  IconButton(
                    icon: _sending ? const CircularProgressIndicator() : const Icon(Icons.send, color: Colors.green),
                    onPressed: _sending ? null : _send,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Msg {
  final String text;
  final bool fromUser;
  _Msg({required this.text, required this.fromUser});
}

// --------------------------- PROFILE ---------------------------
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          CircleAvatar(radius: 40, backgroundColor: Colors.green[200], child: const Icon(Icons.person, size: 42)),
          const SizedBox(height: 14),
          const Text('Guest User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          const Text('you@demo.app', style: TextStyle(color: Colors.black54)),
          const SizedBox(height: 22),
          ElevatedButton(
            onPressed: () {
              // sign out / goto login
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
            child: const Text('Sign out'),
          )
        ],
      ),
    );
  }
}
