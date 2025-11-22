import 'package:flutter/foundation.dart';
import 'package:go4it/models/challenge.dart';
import 'package:go4it/services/challenge_service.dart';
import 'package:go4it/utils/app_status.dart';
import 'package:go4it/providers/auth_provider.dart';

class HistoryProvider extends ChangeNotifier {
  final ChallengeService _challengeService = ChallengeService();
  final AuthProvider _authProvider;

  List<Challenge> _publishedHistory = [];
  List<Challenge> _doneHistory = [];

  AppStatus _status = AppStatus.uninitialized;
  String? _error;

  HistoryProvider(this._authProvider);

  List<Challenge> get publishedHistory => _publishedHistory;
  List<Challenge> get doneHistory => _doneHistory;
  AppStatus get status => _status;

  Future<void> fetchHistory() async {
    if (_authProvider.currentUser == null) return;

    _status = AppStatus.loading;
    notifyListeners();

    try {
      // On lance les deux requêtes en parallèle
      final results = await Future.wait([
        _challengeService.getHistoryPublished(_authProvider.currentUserId),
        _challengeService.getHistoryDone(_authProvider.currentUserId),
      ]);

      _publishedHistory = results[0];
      _doneHistory = results[1];
      _status = AppStatus.loaded;
    } catch (e) {
      _status = AppStatus.error;
      _error = e.toString();
    }
    notifyListeners();
  }
}