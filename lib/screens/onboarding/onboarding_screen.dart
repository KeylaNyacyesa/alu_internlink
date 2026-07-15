import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/common_widgets.dart';
import '../../providers/providers.dart';
import '../auth/startup_login_screen.dart';
import '../auth/student_login_screen.dart';

class OnboardingScreen extends ConsumerWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          const BackgroundCanvas(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: size.height - 52),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF134E4A), Color(0xFF7DD3FC)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(Icons.school_rounded, color: Colors.white),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'ALU InternLink',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 4),
                              Text('Student-to-startup internship marketplace'),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 28),
                      Text(
                        'Find meaningful startup experiences inside the ALU ecosystem.',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Discover verified student-led ventures, apply with your skill portfolio, and keep track of every opportunity from one place.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.black.withOpacity(0.68),
                            ),
                      ),
                      const SizedBox(height: 24),
                      const OnboardingHighlights(),
                      const SizedBox(height: 24),
                      RoleCard(
                        title: 'Continue as student',
                        description:
                            'Browse opportunities, bookmark roles, and manage your applications.',
                        icon: Icons.person_rounded,
                        accent: const Color(0xFF0F766E),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => StudentLoginScreen(
                                onLogin: (email, password, _) async =>
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .loginWithEmailAndPassword(
                                          roleLabel: 'Student',
                                          displayName: '',
                                          email: email,
                                          password: password,
                                        ),
                                onRegister: (email, password, displayName) async =>
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .registerWithEmailAndPassword(
                                          roleLabel: 'Student',
                                          displayName: displayName,
                                          email: email,
                                          password: password,
                                        ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 14),
                      RoleCard(
                        title: 'Continue as startup',
                        description:
                            'Post opportunities, verify your venture, and review incoming interest.',
                        icon: Icons.rocket_launch_rounded,
                        accent: const Color(0xFFB45309),
                    onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => StartupLoginScreen(
                                onLogin: (email, password, _) async =>
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .loginWithEmailAndPassword(
                                          roleLabel: 'Startup',
                                          displayName: '',
                                          email: email,
                                          password: password,
                                        ),
                                onRegister: (email, password, displayName) async =>
                                    ref
                                        .read(authControllerProvider.notifier)
                                        .registerWithEmailAndPassword(
                                          roleLabel: 'Startup',
                                          displayName: displayName,
                                          email: email,
                                          password: password,
                                        ),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      const SizedBox(height: 18),
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
