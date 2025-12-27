part of 'invest_boss_bloc.dart';

enum InvestBossStatus { initial, loading, success, failure }

class InvestBossState {
  final InvestBossStatus status;
  final Map<String, dynamic>? profile;
  final List<Map<String, dynamic>> portfolio;
  final List<Map<String, dynamic>> leaderboard;
  final String? errorMessage;

  const InvestBossState({
    this.status = InvestBossStatus.initial,
    this.profile,
    this.portfolio = const [],
    this.leaderboard = const [],
    this.errorMessage,
  });

  InvestBossState copyWith({
    InvestBossStatus? status,
    Map<String, dynamic>? profile,
    List<Map<String, dynamic>>? portfolio,
    List<Map<String, dynamic>>? leaderboard,
    String? errorMessage,
  }) {
    return InvestBossState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      portfolio: portfolio ?? this.portfolio,
      leaderboard: leaderboard ?? this.leaderboard,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
