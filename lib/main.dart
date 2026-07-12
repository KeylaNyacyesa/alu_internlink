import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'firebase_options.dart';
import 'screens/applications/applications_screen.dart';
import 'screens/discover/discover_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'models/enums.dart';
import 'providers/providers.dart';
import 'widgets/common_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var firebaseReady = false;
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseReady = true;
  } catch (_) {
    firebaseReady = false;
  }

  runApp(
    ProviderScope(
      overrides: [firebaseReadyProvider.overrideWithValue(firebaseReady)],
      child: const ALUInternLinkApp(),
    ),
  );
}

class ALUInternLinkApp extends StatelessWidget {
  const ALUInternLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ALU InternLink',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
        scaffoldBackgroundColor: Colors.transparent,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
        ),
      ),
      home: const AppGate(),
    );
  }
}

class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final firebaseReady = ref.watch(firebaseReadyProvider);

    if (!firebaseReady) {
      return const _BackendUnavailableScreen();
    }

    return authState.onboardingComplete ? const MarketplaceShell() : const OnboardingScreen();
  }
}

class _BackendUnavailableScreen extends StatelessWidget {
  const _BackendUnavailableScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundCanvas(),
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SurfaceCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Backend unavailable', style: Theme.of(context).textTheme.headlineSmall),
                      const SizedBox(height: 12),
                      Text(
                        'Firebase could not be initialized on this device. The UI shell is still available, but live authentication and Firestore sync are disabled until the backend connection is restored.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MarketplaceShell extends ConsumerWidget {
  const MarketplaceShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = ref.watch(selectedTabProvider);
    final authState = ref.watch(authControllerProvider);

    final pages = <Widget>[
      HomeTab(role: authState.role ?? UserRole.student),
      const DiscoverTab(),
      const ApplicationsTab(),
      const ProfileTab(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const BackgroundCanvas(),
          SafeArea(child: IndexedStack(index: index, children: pages)),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        backgroundColor: Colors.white.withOpacity(0.92),
        selectedIndex: index,
        onDestinationSelected: (newIndex) => ref.read(selectedTabProvider.notifier).state = newIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore_rounded),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox_rounded),
            label: 'Applications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline_rounded),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
