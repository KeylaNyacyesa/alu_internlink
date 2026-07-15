import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/application_record.dart';
import '../models/enums.dart';
import '../models/opportunity.dart';
import '../models/seeds.dart';

class MarketplaceState {
  const MarketplaceState({
    required this.opportunities,
    required this.applications,
    required this.bookmarkedOpportunityIds,
    required this.searchQuery,
    required this.categoryFilter,
    required this.modeFilter,
  });

  factory MarketplaceState.initial() => MarketplaceState(
        opportunities: seedOpportunities,
        applications: const <ApplicationRecord>[],
        bookmarkedOpportunityIds: const <String>{},
        searchQuery: '',
        categoryFilter: OpportunityCategory.all,
        modeFilter: null,
      );

  final List<Opportunity> opportunities;
  final List<ApplicationRecord> applications;
  final Set<String> bookmarkedOpportunityIds;
  final String searchQuery;
  final OpportunityCategory categoryFilter;
  final OpportunityMode? modeFilter;

  List<Opportunity> get filteredOpportunities {
    final query = searchQuery.trim().toLowerCase();
    return opportunities.where((opportunity) {
      final matchesQuery = query.isEmpty ||
          opportunity.title.toLowerCase().contains(query) ||
          opportunity.startupName.toLowerCase().contains(query) ||
          opportunity.skills.any((skill) => skill.toLowerCase().contains(query));
      final matchesCategory =
          categoryFilter == OpportunityCategory.all || opportunity.category == categoryFilter;
      final matchesMode = modeFilter == null || opportunity.mode == modeFilter;
      return matchesQuery && matchesCategory && matchesMode;
    }).toList(growable: false);
  }

  List<Opportunity> get featuredOpportunities => opportunities
      .where((opportunity) => opportunity.verifiedStartup)
      .take(3)
      .toList(growable: false);

  MarketplaceState copyWith({
    List<Opportunity>? opportunities,
    List<ApplicationRecord>? applications,
    Set<String>? bookmarkedOpportunityIds,
    String? searchQuery,
    OpportunityCategory? categoryFilter,
    OpportunityMode? modeFilter,
  }) {
    return MarketplaceState(
      opportunities: opportunities ?? this.opportunities,
      applications: applications ?? this.applications,
      bookmarkedOpportunityIds: bookmarkedOpportunityIds ?? this.bookmarkedOpportunityIds,
      searchQuery: searchQuery ?? this.searchQuery,
      categoryFilter: categoryFilter ?? this.categoryFilter,
      modeFilter: modeFilter ?? this.modeFilter,
    );
  }
}

class MarketplaceController extends StateNotifier<MarketplaceState> {
  MarketplaceController() : super(MarketplaceState.initial()) {
    _bindOpportunities();
  }

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _opportunitiesSubscription;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _applicationsSubscription;

  // Latest known identity, kept in sync via [onAuthChanged] so that writes can
  // stamp the correct applicant / owner ids without re-reading auth each time.
  UserRole? _role;
  String? _uid;
  String _displayName = '';

  void updateSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
  }

  void setCategoryFilter(OpportunityCategory category) {
    state = state.copyWith(categoryFilter: category);
  }

  void setModeFilter(OpportunityMode mode) {
    state = state.copyWith(modeFilter: state.modeFilter == mode ? null : mode);
  }

  void clearFilters() {
    state = state.copyWith(
      searchQuery: '',
      categoryFilter: OpportunityCategory.all,
      modeFilter: null,
    );
  }

  void toggleBookmark(String opportunityId) {
    final next = <String>{...state.bookmarkedOpportunityIds};
    if (next.contains(opportunityId)) {
      next.remove(opportunityId);
    } else {
      next.add(opportunityId);
    }

    state = state.copyWith(bookmarkedOpportunityIds: next);
    unawaited(_persistBookmark(opportunityId, next.contains(opportunityId)));
  }

  /// Called whenever the authenticated identity changes (login, logout, role
  /// switch). Rebinds the applications stream to the query that matches the
  /// current role so a startup sees its inbound pipeline and a student sees
  /// only their own submissions.
  void onAuthChanged(UserRole? role, String? uid, String displayName) {
    _role = role;
    _uid = uid;
    _displayName = displayName;
    _bindApplications();
  }

  Future<void> submitApplication(Opportunity opportunity, String note) async {
    final uid = _uid ?? FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // Write to Firestore only; the bound stream reflects it back into state,
    // which avoids a duplicate entry from an optimistic local insert.
    await FirebaseFirestore.instance.collection('applications').add({
      'opportunityId': opportunity.id,
      'title': opportunity.title,
      'startupName': opportunity.startupName,
      'applicantId': uid,
      'applicantName': _displayName,
      'startupOwnerId': opportunity.ownerId,
      'status': ApplicationStatus.pending.label,
      'note': note,
      'submittedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Startup-side status transition (pending → shortlisted → interview →
  /// accepted / closed). Optimistically updates local state for instant
  /// feedback, then persists; the stream keeps it authoritative.
  Future<void> updateApplicationStatus(
    ApplicationRecord application,
    ApplicationStatus status,
  ) async {
    final next = [
      for (final record in state.applications)
        record.id == application.id ? record.copyWith(status: status) : record,
    ];
    state = state.copyWith(applications: next);

    try {
      await FirebaseFirestore.instance
          .collection('applications')
          .doc(application.id)
          .update({'status': status.label});
    } catch (_) {}
  }

  Future<void> upsertOpportunity(Opportunity opportunity) async {
    try {
      await FirebaseFirestore.instance.collection('opportunities').doc(opportunity.id).set(
            opportunity.toMap(),
            SetOptions(merge: true),
          );
    } catch (_) {}
  }

  Future<void> deleteOpportunity(String opportunityId) async {
    try {
      await FirebaseFirestore.instance.collection('opportunities').doc(opportunityId).delete();
    } catch (_) {}
  }

  void _bindOpportunities() {
    try {
      _opportunitiesSubscription = FirebaseFirestore.instance
          .collection('opportunities')
          .snapshots()
          .listen((snapshot) {
        final remote = snapshot.docs
            .map((doc) => Opportunity.fromMap(doc.data(), doc.id))
            .toList(growable: false);

        // Merge a local starter catalog with live Firestore postings so the
        // discover feed is never empty on a fresh backend, while real posts
        // (and their persistence) are still demonstrable. Remote wins on id.
        final remoteIds = remote.map((o) => o.id).toSet();
        final merged = <Opportunity>[
          ...remote,
          ...seedOpportunities.where((seed) => !remoteIds.contains(seed.id)),
        ];
        state = state.copyWith(opportunities: merged);
      });
    } catch (_) {}
  }

  void _bindApplications() {
    unawaited(_applicationsSubscription?.cancel());
    _applicationsSubscription = null;

    final uid = _uid;
    if (uid == null) {
      state = state.copyWith(applications: const <ApplicationRecord>[]);
      return;
    }

    // Students see applications they submitted; startups see applications for
    // opportunities they own. Same collection, two different indexed queries.
    final field = _role == UserRole.startup ? 'startupOwnerId' : 'applicantId';

    try {
      _applicationsSubscription = FirebaseFirestore.instance
          .collection('applications')
          .where(field, isEqualTo: uid)
          .snapshots()
          .listen((snapshot) {
        final remote = snapshot.docs
            .map((doc) => ApplicationRecord.fromMap(doc.data(), doc.id))
            .toList(growable: false)
          ..sort((a, b) => b.submittedAt.compareTo(a.submittedAt));

        state = state.copyWith(applications: remote);
      });
    } catch (_) {}
  }

  Future<void> _persistBookmark(String opportunityId, bool saved) async {
    try {
      final uid = _uid ?? FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('bookmarks')
          .doc(opportunityId)
          .set(
        {
          'opportunityId': opportunityId,
          'saved': saved,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (_) {}
  }

  @override
  void dispose() {
    unawaited(_opportunitiesSubscription?.cancel());
    unawaited(_applicationsSubscription?.cancel());
    super.dispose();
  }
}
