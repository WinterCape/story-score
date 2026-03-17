import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:story_score/data/database/app_database.dart';
import 'package:story_score/data/database/daos/purchase_dao.dart';
import 'package:story_score/data/database/daos/round_dao.dart';
import 'package:story_score/data/database/daos/session_dao.dart';
import 'package:story_score/domain/scoring/round_processor.dart';
import 'package:story_score/domain/scoring/scoring_engine.dart';

/// Provides the [AppDatabase] singleton.
/// Must be overridden at startup in [ProviderScope].
final appDatabaseProvider = Provider<AppDatabase>((ref) {
  throw UnimplementedError(
    'appDatabaseProvider must be overridden at startup.',
  );
});

/// Provides the [SessionDao].
final sessionDaoProvider = Provider<SessionDao>((ref) {
  return ref.watch(appDatabaseProvider).sessionDao;
});

/// Provides the [RoundDao].
final roundDaoProvider = Provider<RoundDao>((ref) {
  return ref.watch(appDatabaseProvider).roundDao;
});

/// Provides the [PurchaseDao].
final purchaseDaoProvider = Provider<PurchaseDao>((ref) {
  return ref.watch(appDatabaseProvider).purchaseDao;
});

/// Provides the pure scoring engine.
final scoringEngineProvider = Provider<ScoringEngine>((ref) {
  return const ScoringEngine();
});

/// Provides the round processor that connects scoring to persistence.
final roundProcessorProvider = Provider<RoundProcessor>((ref) {
  return RoundProcessor(
    engine: ref.watch(scoringEngineProvider),
    roundDao: ref.watch(roundDaoProvider),
    sessionDao: ref.watch(sessionDaoProvider),
  );
});
