import 'package:flutter/material.dart' hide Badge;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../models/enums.dart';

import '../../widgets/common_widgets.dart';

class StartupProfileScreen extends ConsumerWidget {
  const StartupProfileScreen({super.key});

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
                          'Startup founder at ALU',
                          style: TextStyle(color: Color(0xA6000000)),
                        ),
                      ],
                    ),
                  ),
                  AppBadge(label: authState.verifiedStartup ? 'Verified startup' : 'Pending verification'),
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
                'Request moderation approval before your opportunities become visible to students.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.black.withOpacity(0.66),
                    ),
              ),
              const SizedBox(height: 14),
              FilledButton.tonal(
                onPressed: authState.verifiedStartup
                    ? null
                    : () async {
                        await ref.read(authControllerProvider.notifier).requestStartupVerification();
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Verification requested — an ALU admin will review it shortly.'),
                            ),
                          );
                        }
                      },
                child: Text(
                  authState.verifiedStartup ? 'Verified startup' : 'Request startup verification',
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
              Text('Startup posting checklist'),
              SizedBox(height: 12),
              PromptTile(
                title: 'Write a clear role summary',
                body: 'Include responsibilities, required skills, and expected outcomes for the internship period.',
              ),
              PromptTile(
                title: 'Update application workflow',
                body: 'Move applicants through applied → shortlist → interview → accepted.',
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

