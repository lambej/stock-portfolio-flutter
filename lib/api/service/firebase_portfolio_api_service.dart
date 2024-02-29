import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/subjects.dart';
import 'package:stock_portfolio/api/service/portfolio_api_service.dart';

/// {@template firebase_storage_portfolio_api}
/// A Flutter implementation of the PortfolioApi that uses firebase storage
/// {@endtemplate}
class FirebasePortfolioApiService extends PortfolioApi {
  /// {@macro local_storage_portfolio_api}
  FirebasePortfolioApiService({
    required FirebaseFirestore plugin,
  }) : _plugin = plugin;

  final FirebaseFirestore _plugin;
  final _accountStreamController =
      BehaviorSubject<List<Account>>.seeded(const []);
  final _accountTypeStreamController =
      BehaviorSubject<List<AccountType>>.seeded(const []);
  final _balanceStreamController =
      BehaviorSubject<List<Balance>>.seeded(const []);
  final _contributionStreamController =
      BehaviorSubject<List<Contribution>>.seeded(const []);
  late String _userId;

  // TODO(lambej): add user model containing userid and the isPremium flag
  // to the portfolio api and use it to determine the max values.
  /// In the meantime, use isPremium = false to determine the max values.
  static bool isPremium = false;
  //User get user => User(id: _userId);

  /// The key used for storing the accounts.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kAccountsCollectionKey = 'Accounts';

  /// The key used for storing the account types.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kAccountTypesCollectionKey = 'Account_Types';

  /// The key used for storing the balances.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kBalancesCollectionKey = 'Balances';

  /// The key used for storing the contributions.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kContributionsCollectionKey = 'Contributions';

  /// Initializes the [FirebaseStoragePortfolioApi].
  ///
  /// This method must be called before calling any other method.
  @override
  Future<void> init(String userId) async {
    _userId = userId;
    await _initAccountType(userId);
    await _initAccount(userId);
    await _initBalance(userId);
    await _initContribution(userId);
  }

  Future<void> _initAccountType(String userId) async {
    final accountTypesJson = await _plugin
        .collection(kAccountTypesCollectionKey)
        .where('userId', isEqualTo: userId)
        .get();

    final accountTypes = accountTypesJson.docs
        .map(
          (e) =>
              AccountType.fromJson(Map<String, dynamic>.from(e.data()), e.id),
        )
        .toList();
    maxAccountTypeReached =
        accountTypes.length >= UserStorageLimits.maxAccountTypes;
    _accountTypeStreamController.add(accountTypes);
  }

  Future<void> _initAccount(String userId) async {
    final accountsJson = await _plugin
        .collection(kAccountsCollectionKey)
        .where('userId', isEqualTo: userId)
        .get();
    final accounts = accountsJson.docs.map((e) {
      final account =
          Account.fromJson(Map<String, dynamic>.from(e.data()), e.id);
      account.accountType = _accountTypeStreamController.value.firstWhere(
        (t) => t.id == account.accountTypeId,
        orElse: () => AccountType(type: '', userId: ''),
      );
      return account;
    }).toList();
    maxAccountReached = accounts.length >= UserStorageLimits.maxAccounts;
    _accountStreamController.add(accounts);
  }

  Future<void> _initBalance(String userId) async {
    final balancesJson = await _plugin
        .collection(kBalancesCollectionKey)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
    final balances = balancesJson.docs
        .map(
          (e) => Balance.fromJson(Map<String, dynamic>.from(e.data()), e.id),
        )
        .toList();
    maxBalanceReached = balances.length >= UserStorageLimits.maxBalances;
    _balanceStreamController.add(balances);
  }

  Future<void> _initContribution(String userId) async {
    final contributionsJson = await _plugin
        .collection(kContributionsCollectionKey)
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .get();
    final contributions = contributionsJson.docs
        .map(
          (e) =>
              Contribution.fromJson(Map<String, dynamic>.from(e.data()), e.id),
        )
        .toList();
    maxContributionReached =
        contributions.length >= UserStorageLimits.maxContributions;
    _contributionStreamController.add(contributions);
  }

  @override
  Future<void> deleteAccount(String id) async {
    final accounts = [..._accountStreamController.value];
    final accountIndex = accounts.indexWhere((t) => t.id == id);
    if (accountIndex == -1) {
      throw AccountNotFoundException();
    } else {
      accounts.removeAt(accountIndex);
      _accountStreamController.add(accounts);

      // Delete all balances and contributions associated with the account.
      final balances = [..._balanceStreamController.value]
        ..removeWhere((balance) => balance.accountId == id);
      _balanceStreamController.add(balances);
      await _plugin
          .collection(kBalancesCollectionKey)
          .where('accountId', isEqualTo: id)
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      final contributions = [..._contributionStreamController.value]
        ..removeWhere((contribution) => contribution.accountId == id);
      _contributionStreamController.add(contributions);
      await _plugin
          .collection(kContributionsCollectionKey)
          .where('accountId', isEqualTo: id)
          .get()
          .then((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.delete();
        }
      });

      // Update the max values.
      maxAccountReached = accounts.length >= UserStorageLimits.maxAccounts;
      maxBalanceReached = balances.length >= UserStorageLimits.maxBalances;
      maxContributionReached =
          contributions.length >= UserStorageLimits.maxContributions;

      return _plugin.collection(kAccountsCollectionKey).doc(id).delete();
    }
  }

  @override
  Future<void> deleteAccountType(String id) {
    final accountTypes = [..._accountTypeStreamController.value];
    final accountTypeIndex = accountTypes.indexWhere((t) => t.id == id);
    if (accountTypeIndex == -1) {
      throw AccountTypeNotFoundException();
    } else {
      accountTypes.removeAt(accountTypeIndex);
      _accountTypeStreamController.add(accountTypes);

      maxAccountTypeReached =
          accountTypes.length >= UserStorageLimits.maxAccountTypes;
      return _plugin.collection(kAccountTypesCollectionKey).doc(id).delete();
    }
  }

  @override
  Future<void> deleteBalance(String id) {
    final balances = [..._balanceStreamController.value];
    final balanceIndex = balances.indexWhere((t) => t.id == id);
    if (balanceIndex == -1) {
      throw BalanceNotFoundException();
    } else {
      balances.removeAt(balanceIndex);
      _balanceStreamController.add(balances);

      maxBalanceReached = balances.length >= UserStorageLimits.maxBalances;
      return _plugin.collection(kBalancesCollectionKey).doc(id).delete();
    }
  }

  @override
  Future<void> deleteContribution(String id) {
    final contributions = [..._contributionStreamController.value];
    final contributionIndex = contributions.indexWhere((t) => t.id == id);
    if (contributionIndex == -1) {
      throw ContributionNotFoundException();
    } else {
      contributions.removeAt(contributionIndex);
      _contributionStreamController.add(contributions);

      maxContributionReached =
          contributions.length >= UserStorageLimits.maxContributions;
      return _plugin.collection(kContributionsCollectionKey).doc(id).delete();
    }
  }

  @override
  Stream<List<AccountType>> getAccountTypes() =>
      _accountTypeStreamController.asBroadcastStream();

  @override
  Stream<List<Account>> getAccounts() =>
      _accountStreamController.asBroadcastStream();

  @override
  Stream<List<Balance>> getBalances(List<Account> accounts) {
    return _balanceStreamController.stream.map(
      (balances) => balances
          .where(
            (balance) =>
                accounts.any((account) => account.id == balance.accountId),
          )
          .toList(),
    )..asBroadcastStream();
  }

  @override
  Stream<List<Contribution>> getContributions(List<Account> accounts) {
    return _contributionStreamController.stream.map(
      (contributions) => contributions
          .where(
            (contribution) =>
                accounts.any((account) => account.id == contribution.accountId),
          )
          .toList(),
    )..asBroadcastStream();
  }

  @override
  Stream<List<Contribution>> getContributionsFromAccount(String id) {
    return _contributionStreamController.stream.map(
      (contributions) => contributions
          .where((contribution) => contribution.accountId == id)
          .toList(),
    )..asBroadcastStream();
  }

  @override
  Future<void> saveAccount(Account account) async {
    final accounts = [..._accountStreamController.value];
    final accountIndex = accounts.indexWhere((t) => t.id == account.id);
    late var isNewAccount = false;
    final newAccount = account.copyWith(userId: _userId);
    newAccount.accountTypeId = newAccount.accountType?.id ?? '';
    if (accountIndex >= 0) {
      accounts[accountIndex] = newAccount;
    } else {
      final accountId = await _plugin
          .collection(kAccountsCollectionKey)
          .add(newAccount.toJson());
      newAccount.id = accountId.id;
      accounts.add(newAccount);
      isNewAccount = true;
    }

    _accountStreamController.add(accounts);

    maxAccountReached = accounts.length >= UserStorageLimits.maxAccounts;
    return isNewAccount
        ? null
        : _plugin
            .collection(kAccountsCollectionKey)
            .doc(newAccount.id)
            .update(newAccount.toJson());
  }

  @override
  Future<void> saveAccountType(AccountType accountType) async {
    final accountTypes = [..._accountTypeStreamController.value];
    final accountTypeIndex =
        accountTypes.indexWhere((t) => t.id == accountType.id);
    late var isNewAccountType = false;
    final newAccountType = accountType.copyWith(userId: _userId);
    if (accountTypeIndex >= 0) {
      accountTypes[accountTypeIndex] = newAccountType;
    } else {
      final accountTypeId = await _plugin
          .collection(kAccountTypesCollectionKey)
          .add(newAccountType.toJson());
      newAccountType.id = accountTypeId.id;
      accountTypes.add(newAccountType);
      isNewAccountType = true;
    }

    _accountTypeStreamController.add(accountTypes);

    maxAccountTypeReached =
        accountTypes.length >= UserStorageLimits.maxAccountTypes;
    return isNewAccountType
        ? null
        : _plugin
            .collection(kAccountTypesCollectionKey)
            .doc(newAccountType.id)
            .update(newAccountType.toJson());
  }

  @override
  Future<void> saveBalance(Balance balance) async {
    final balances = [..._balanceStreamController.value];
    final balanceIndex = balances.indexWhere((t) => t.id == balance.id);
    late var isNewBalance = false;
    final newBalance = balance.copyWith(userId: _userId);
    if (balanceIndex >= 0) {
      balances[balanceIndex] = newBalance;
    } else {
      final balanceId = await _plugin
          .collection(kBalancesCollectionKey)
          .add(newBalance.toJson());
      newBalance.id = balanceId.id;
      balances.add(newBalance);
      isNewBalance = true;
    }

    _balanceStreamController.add(balances);

    maxBalanceReached = balances.length >= UserStorageLimits.maxBalances;
    return isNewBalance
        ? null
        : _plugin
            .collection(kBalancesCollectionKey)
            .doc(newBalance.id)
            .update(newBalance.toJson());
  }

  @override
  Future<void> saveContribution(Contribution contribution) async {
    final contributions = [..._contributionStreamController.value];
    final contributionIndex =
        contributions.indexWhere((t) => t.id == contribution.id);
    late var isNewContribution = false;
    final newContribution = contribution.copyWith(userId: _userId);
    if (contributionIndex >= 0) {
      contributions[contributionIndex] = newContribution;
    } else {
      final contributionId = await _plugin
          .collection(kContributionsCollectionKey)
          .add(newContribution.toJson());
      newContribution.id = contributionId.id;
      contributions.add(newContribution);
      isNewContribution = true;
    }

    _contributionStreamController.add(contributions);

    maxContributionReached =
        contributions.length >= UserStorageLimits.maxContributions;
    return isNewContribution
        ? null
        : _plugin
            .collection(kContributionsCollectionKey)
            .doc(newContribution.id)
            .update(newContribution.toJson());
  }

  /// {@macro firebase_storage_portfolio_api}
}
