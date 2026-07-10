import 'package:bismillah_app/core/contracts/contracts.dart';
import 'package:bismillah_app/features/profile/domain/entities/achievement.dart';
import 'package:bismillah_app/features/profile/domain/entities/streak_state.dart';
import 'package:bismillah_app/features/profile/domain/entities/user_profile.dart';

/// Profil lokal veri sözleşmesi (10_DATA_MODEL §7).
///
/// Server-owned premium alanları bu sözleşmeden GEÇMEZ (ayrık DTO
/// kuralı, §24) — entitlement `PremiumEntitlementRepository`'dedir.
abstract interface class UserProfileRepository {
  ResultFuture<UserProfile?> getProfile();

  Stream<UserProfile?> watchProfile();

  ResultFuture<void> saveProfile(UserProfile profile);

  ResultFuture<List<Achievement>> getAchievements();

  /// Insert-only; aynı ID ikinci kez eklenirse erken `earnedAt` korunur.
  ResultFuture<void> recordAchievement(Achievement achievement);

  ResultFuture<StreakState> getStreak();

  /// Türetilmiş cache güncellemesi — kaynak daima log'lardır (§21).
  ResultFuture<void> saveStreakCache(StreakState streak);
}
