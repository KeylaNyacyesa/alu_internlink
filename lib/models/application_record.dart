import 'enums.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ApplicationRecord {
  ApplicationRecord({
    required this.id,
    required this.opportunityId,
    required this.title,
    required this.startupName,
    required this.status,
    required this.submittedAt,
    required this.note,
    this.applicantId = '',
    this.applicantName = '',
    this.startupOwnerId = '',
  });

  final String id;
  final String opportunityId;
  final String title;
  final String startupName;

  /// uid of the student who applied.
  final String applicantId;

  /// Display name of the applicant, denormalized so startups can render the
  /// pipeline without an extra read per applicant.
  final String applicantName;

  /// uid of the startup that owns the opportunity. This is what lets a startup
  /// query "applications for opportunities I own" with a single indexed field.
  final String startupOwnerId;

  final ApplicationStatus status;
  final DateTime submittedAt;
  final String note;

  factory ApplicationRecord.fromMap(Map<String, dynamic> data, String id) {
    final rawSubmittedAt = data['submittedAt'];
    final submittedAt = switch (rawSubmittedAt) {
      Timestamp timestamp => timestamp.toDate(),
      DateTime dateTime => dateTime,
      String value => DateTime.tryParse(value) ?? DateTime.now(),
      _ => DateTime.now(),
    };

    return ApplicationRecord(
      id: id,
      opportunityId: data['opportunityId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      applicantId: data['applicantId'] as String? ?? '',
      applicantName: data['applicantName'] as String? ?? '',
      startupOwnerId: data['startupOwnerId'] as String? ?? '',
      status: _statusFromValue(data['status'] as String?),
      submittedAt: submittedAt,
      note: data['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() => {
        'opportunityId': opportunityId,
        'title': title,
        'startupName': startupName,
        'applicantId': applicantId,
        'applicantName': applicantName,
        'startupOwnerId': startupOwnerId,
        'status': status.label,
        'note': note,
        'submittedAt': Timestamp.fromDate(submittedAt),
      };

  ApplicationRecord copyWith({ApplicationStatus? status}) => ApplicationRecord(
        id: id,
        opportunityId: opportunityId,
        title: title,
        startupName: startupName,
        applicantId: applicantId,
        applicantName: applicantName,
        startupOwnerId: startupOwnerId,
        status: status ?? this.status,
        submittedAt: submittedAt,
        note: note,
      );
}

ApplicationStatus _statusFromValue(String? value) {
  return ApplicationStatus.values.firstWhere(
    (s) => s.label.toLowerCase() == value?.toLowerCase(),
    orElse: () => ApplicationStatus.pending,
  );
}
