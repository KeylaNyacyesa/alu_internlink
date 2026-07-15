import 'package:flutter/material.dart' hide Badge;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/enums.dart';
import '../../providers/providers.dart';
import '../../widgets/common_widgets.dart';

class StudentProfileScreen extends ConsumerWidget {
  const StudentProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final marketplace = ref.watch(marketplaceControllerProvider);

    final verifiedCount = marketplace.opportunities.where((opportunity) => opportunity.verifiedStartup).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      children: [
        Text('Profile', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 16),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF0F766E), Color(0xFF7DD3FC)],
                      ),
                    ),
                    child: const Icon(Icons.person, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(authState.displayName, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 4),
                        const Text(
                          'ALU student profile',
                          style: TextStyle(color: Color(0xA6000000)),
                        ),
                      ],
                    ),
                  ),
                  AppBadge(label: 'ALU verified student'),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: StatMiniCard(
                      title: 'Saved',
                      value: '${marketplace.bookmarkedOpportunityIds.length}',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatMiniCard(title: 'Verified roles', value: '$verifiedCount'),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: StatMiniCard(title: 'State', value: authState.role?.label ?? 'Guest'),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Student portfolio prompts'),
              SizedBox(height: 12),
              PromptTile(
                title: 'Update your skills & projects',
                body: 'Add recent projects, tech stack, achievements, and links to your portfolio.',
              ),
              PromptTile(
                title: 'Keep a clean internship narrative',
                body: 'Explain impact, learning, and the kind of role you’re excited to contribute to.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Logout'),
        ),
      ],
    );
  }
}

