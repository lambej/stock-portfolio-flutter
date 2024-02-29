import 'package:stock_portfolio/api/model/models.dart';

export 'package:stock_portfolio/api/model/models.dart';

/// {@template portfolio_api}
/// The interface and models for an API providing access to portfolio data.
/// {@endtemplate}
abstract class PortfolioApi {
  /// {@macro portfolio_api}
  PortfolioApi()
      : maxAccountReached = false,
        maxAccountTypeReached = false,
        maxBalanceReached = false,
        maxContributionReached = false;

  /// The maximum number of accounts allowed.
  bool maxAccountReached;

  /// The maximum number of account types allowed.
  bool maxAccountTypeReached;

  /// The maximum number of balances allowed.
  bool maxBalanceReached;

  /// The maximum number of contributions allowed.
  bool maxContributionReached;

  /// Initializes the [PortfolioApi].
  Future<void> init(String userId);

  /// Provides a [Stream] of all accounts.
  Stream<List<Account>> getAccounts();

  /// Saves a [account].
  ///
  /// If a [account] with the same id already exists, it will be replaced.
  Future<void> saveAccount(Account account);

  /// Deletes the `account` with the given id.
  ///
  /// If no `account` with the given id exists, a [AccountNotFoundException]
  /// error is thrown.
  Future<void> deleteAccount(String id);

  /// Provides a [Stream] of all account types.
  Stream<List<AccountType>> getAccountTypes();

  /// Saves a [accountType].
  ///
  /// If a [accountType] with the same id already exists, it will be replaced.
  Future<void> saveAccountType(AccountType accountType);

  /// Deletes the `accountType` with the given id.
  ///
  /// If no `accountType` with the given id exists, a
  /// [AccountTypeNotFoundException] error is thrown.
  Future<void> deleteAccountType(String id);

  /// Provides a [Stream] of all balances of the given accounts.
  Stream<List<Balance>> getBalances(List<Account> accounts);

  /// Saves a [balance].
  ///
  /// If a [balance] with the same id already exists, it will be replaced.
  Future<void> saveBalance(Balance balance);

  /// Deletes the `balance` with the given id.
  ///
  /// If no `balance` with the given id exists, a
  /// [BalanceNotFoundException] error is thrown.
  Future<void> deleteBalance(String id);

  /// Provides a [Stream] of all contributions of the given account [id].
  Stream<List<Contribution>> getContributionsFromAccount(String id);

  /// Provides a [Stream] of all contributions of the given accounts.
  Stream<List<Contribution>> getContributions(List<Account> accounts);

  /// Saves a [contribution].
  ///
  /// If a [contribution] with the same id already exists, it will be replaced.
  Future<void> saveContribution(Contribution contribution);

  /// Deletes the `contribution` with the given id.
  ///
  /// If no `contribution` with the given id exists, a
  /// [ContributionNotFoundException] error is thrown.
  Future<void> deleteContribution(String id);
}

/// Error thrown when a [Account] with a given id is not found.
class AccountNotFoundException implements Exception {}

/// Error thrown when a [AccountType] with a given id is not found.
class AccountTypeNotFoundException implements Exception {}

/// Error thrown when a [Balance] with a given id is not found.
class BalanceNotFoundException implements Exception {}

/// Error thrown when a [Contribution] with a given id is not found.
class ContributionNotFoundException implements Exception {}
