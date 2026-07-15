import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/application_record.dart';
import '../../models/enums.dart';
import '../../providers/providers.dart';
import '../../widgets/common_widgets.dart';

class StudentApplicationsScreen extends ConsumerWidget {
  const StudentApplicationsScreen({super.key});

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
        Text(
          'Your applications',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Track your interest submissions. Status updates are reflected in real time.',
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
                    Text(
                      status.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
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
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9F5EE),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE7DDD0)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: application.status.color.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Icon(
                              application.status.icon,
                              color: application.status.color,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  application.title,
                                  style: Theme.of(context).textTheme.titleSmall,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  application.startupName,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.black.withOpacity(0.62),
                                      ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          AppBadge(label: application.status.label),
                        ],
                      ),
                    ),
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

