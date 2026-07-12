import 'enums.dart';

class ApplicationRecord {
  ApplicationRecord({
    required this.id,
    required this.opportunityId,
    required this.title,
    required this.startupName,
    required this.status,
    required this.submittedAt,
    required this.note,
  });

  final String id;
  final String opportunityId;
  final String title;
  final String startupName;
  final ApplicationStatus status;
  final DateTime submittedAt;
  final String note;

  factory ApplicationRecord.fromMap(Map<String, dynamic> data, String id) {
    return ApplicationRecord(
      id: id,
      opportunityId: data['opportunityId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      status: _statusFromValue(data['status'] as String?),
      submittedAt: (data['submittedAt'] as String?) != null
          ? DateTime.parse(data['submittedAt'] as String)
          : DateTime.now(),
      note: data['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'opportunityId': opportunityId,
        'title': title,
        'startupName': startupName,
        'status': status.label,
        'note': note,
        'submittedAt': submittedAt.toIso8601String(),
      };
}

ApplicationStatus _statusFromValue(String? value) {
  return ApplicationStatus.values.firstWhere(
    (s) => s.label.toLowerCase() == value?.toLowerCase(),
    orElse: () => ApplicationStatus.pending,
  );
}
