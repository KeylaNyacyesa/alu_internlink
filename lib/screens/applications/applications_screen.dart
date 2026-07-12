import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../models/enums.dart';
import '../../models/application_record.dart';
import '../../widgets/common_widgets.dart';
import '../opportunity/opportunity_details.dart';

class ApplicationsTab extends ConsumerWidget {
  const ApplicationsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marketplace = ref.watch(marketplaceControllerProvider);
    final grouped = <ApplicationStatus, List<ApplicationRecord>>{
      for (final status in ApplicationStatus.values) status: [],
    };

    for (final application in marketplace.applications) {
      grouped[application.status]!.add(application);
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
      children: [
        Text('Applications', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(
          'Every submission is tracked in Firestore and reflected instantly in the local workflow.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.black.withOpacity(0.65),
              ),
        ),
        const SizedBox(height: 16),
        for (final status in const [
          ApplicationStatus.pending,
          ApplicationStatus.shortlisted,
          ApplicationStatus.interview,
          ApplicationStatus.accepted,
        ]) ...[
          SurfaceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(status.label, style: Theme.of(context).textTheme.titleMedium),
                    const Spacer(),
                    Text(
                      '${grouped[status]!.length}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: const Color(0xFF0F766E),
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                if (grouped[status]!.isEmpty)
                  Text(
                    'No applications in this stage yet.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.black.withOpacity(0.55),
                        ),
                  )
                else
                  for (final application in grouped[status]!) ...[
                    ApplicationCard(application: application),
                    if (application != grouped[status]!.last) const SizedBox(height: 10),
                  ],
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],
      ],
    );
  }
}
