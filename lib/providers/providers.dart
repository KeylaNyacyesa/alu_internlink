import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'marketplace_provider.dart';
import '../models/auth_state.dart';

final firebaseReadyProvider = Provider<bool>((ref) => false);
final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) => AuthController(ref));
final marketplaceControllerProvider = StateNotifierProvider<MarketplaceController, MarketplaceState>((ref) => MarketplaceController(ref));
final selectedTabProvider = StateProvider<int>((ref) => 0);
