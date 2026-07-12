import 'package:flutter/material.dart' hide Badge;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../widgets/common_widgets.dart';
import '../../models/enums.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final marketplace = ref.watch(marketplaceControllerProvider);
    final verifiedCount =
        marketplace.opportunities.where((opportunity) => opportunity.verifiedStartup).length;

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
                        Text(
                          authState.role == UserRole.startup
                              ? 'Startup founder at ALU'
                              : 'ALU student profile',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.black.withOpacity(0.65),
                              ),
                        ),
                      ],
                    ),
                  ),
                  Badge(
                    label: authState.verifiedStartup ? 'Verified startup' : 'ALU verified student',
                  ),
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
            children: [
              Text('Startup verification', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                'Only startups recognized inside the ALU ecosystem should be able to publish live roles. Verification requests are captured separately from opportunity creation so that moderation can happen before a posting is visible.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withOpacity(0.66),
                    ),
              ),
              const SizedBox(height: 14),
              FilledButton.tonal(
                onPressed: () => ref.read(authControllerProvider.notifier).toggleStartupVerification(),
                child: Text(
                  authState.verifiedStartup ? 'Verification submitted' : 'Request startup verification',
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        SurfaceCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Research and portfolio prompts'),
              SizedBox(height: 12),
              PromptTile(
                title: 'Update your student portfolio',
                body: 'Showcase skills, class projects, GitHub, Figma, or case studies.',
              ),
              PromptTile(
                title: 'Surface ALU impact metrics',
                body: 'Track how many verified startups and submitted applications are active.',
              ),
              PromptTile(
                title: 'Prepare the final demo narrative',
                body: 'Explain the Firebase flow, state management, UX rationale, and scale path.',
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        OutlinedButton.icon(
          onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Reset session'),
        ),
      ],
    );
  }
}
