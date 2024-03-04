import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:stock_portfolio/api/service/firebase_portfolio_api_service.dart';

/// User storage limits.
///
class UserStorageLimits {
  // Mobile limits.
  static const _mobileMaxAccountTypes = 3;
  static const _mobileMaxAccounts = 3;
  static const _mobileMaxPositions = 36;
  static const _mobileMaxContributions = 36;

  // Web limits.
  // Free
  static const _webMaxAccountTypes = 10;
  static const _webMaxAccounts = 10;
  static const _webMaxPositions = 120;
  static const _webMaxContributions = 120;

  // Premium
  static const _webPremiumMaxAccountTypes = 100;
  static const _webPremiumMaxAccounts = 100;
  static const _webPremiumMaxPositions = 1200;
  static const _webPremiumMaxContributions = 1200;

  /// Returns the maximum number of account types for the current user.
  /// Defaults to [_mobileMaxAccountTypes] if the platform is mobile.
  /// Defaults to [_webMaxAccountTypes] if the platform is web.
  /// Defaults to [_webPremiumMaxAccountTypes] if the platform is web and the uer is premium.s
  static int get maxAccountTypes {
    if (kIsWeb) {
      if (FirebasePortfolioApiService.isPremium) {
        return _webPremiumMaxAccountTypes;
      }
      return _webMaxAccountTypes;
    }
    return _mobileMaxAccountTypes;
  }

  /// Returns the maximum number of accounts for the current user.
  /// Defaults to [_mobileMaxAccounts] if the platform is mobile.
  /// Defaults to [_webMaxAccounts] if the platform is web.
  /// Defaults to [_webPremiumMaxAccounts] if the platform is web and the user is premium.
  static int get maxAccounts {
    if (kIsWeb) {
      if (FirebasePortfolioApiService.isPremium) {
        return _webPremiumMaxAccounts;
      }
      return _webMaxAccounts;
    }
    return _mobileMaxAccounts;
  }

  /// Returns the maximum number of positions for the current user.
  /// Defaults to [_mobileMaxPositions] if the platform is mobile.
  /// Defaults to [_webMaxPositions] if the platform is web.
  /// Defaults to [_webPremiumMaxPositions] if the platform is web and the user is premium.
  static int get maxPositions {
    if (kIsWeb) {
      if (FirebasePortfolioApiService.isPremium) {
        return _mobileMaxPositions;
      }
      return _webMaxPositions;
    }
    return _webPremiumMaxPositions;
  }

  /// Returns the maximum number of contributions for the current user.
  /// Defaults to [_mobileMaxContributions] if the platform is mobile.
  /// Defaults to [_webMaxContributions] if the platform is web.
  /// Defaults to [_webPremiumMaxContributions] if the platform is web and the user is premium.
  static int get maxContributions {
    if (kIsWeb) {
      if (FirebasePortfolioApiService.isPremium) {
        return _webPremiumMaxContributions;
      }
      return _webMaxContributions;
    }
    return _mobileMaxContributions;
  }
}
