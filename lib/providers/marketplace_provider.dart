import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/opportunity.dart';
import '../models/application_record.dart';
import '../models/seeds.dart';
import '../models/enums.dart';

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
        applications: seedApplications,
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
  MarketplaceController(this.ref) : super(MarketplaceState.initial()) {
    unawaited(_hydrateFromFirebase());
  }

  final Ref ref;

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

  Future<void> submitApplication(Opportunity opportunity, String note) async {
    final next = [
      ApplicationRecord(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        opportunityId: opportunity.id,
        title: opportunity.title,
        startupName: opportunity.startupName,
        status: ApplicationStatus.pending,
        submittedAt: DateTime.now(),
        note: note,
      ),
      ...state.applications,
    ];

    state = state.copyWith(applications: next);
    await _persistApplication(opportunity, note);
  }

  Future<void> _hydrateFromFirebase() async {
    try {
      final snapshot = await FirebaseFirestore.instance.collection('opportunities').get();
      if (snapshot.docs.isEmpty) {
        return;
      }

      final remote = snapshot.docs
          .map((doc) => Opportunity.fromMap(doc.data(), doc.id))
          .toList(growable: false);
      state = state.copyWith(opportunities: [...remote, ...seedOpportunities]);
    } catch (_) {}
  }

  Future<void> _persistBookmark(String opportunityId, bool saved) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'demo-user';
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

  Future<void> _persistApplication(Opportunity opportunity, String note) async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid ?? 'demo-user';
      await FirebaseFirestore.instance.collection('applications').add({
        'userId': uid,
        'opportunityId': opportunity.id,
        'title': opportunity.title,
        'startupName': opportunity.startupName,
        'status': ApplicationStatus.pending.label,
        'note': note,
        'submittedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }
}
