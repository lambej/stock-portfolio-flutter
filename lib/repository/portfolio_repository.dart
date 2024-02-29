import 'dart:async';

import 'package:collection/collection.dart';
import 'package:stock_portfolio/api/service/portfolio_api_service.dart';

export 'package:stock_portfolio/api/model/models.dart';

/// {@template portfolio_repository}
/// A repository that handles portfolio related requests.
/// {@endtemplate}
class PortfolioRepository {
  /// {@macro portfolio_repository}
  const PortfolioRepository({
    required PortfolioApi portfolioApi,
  }) : _portfolioApi = portfolioApi;

  final PortfolioApi _portfolioApi;

  /// Returns `true` if the maximum number of accounts has been reached.
  bool get maxAccountReached => _portfolioApi.maxAccountReached;

  /// Returns `true` if the maximum number of account types has been reached.
  bool get maxAccountTypeReached => _portfolioApi.maxAccountTypeReached;

  /// Returns `true` if the maximum number of balances has been reached.
  bool get maxBalanceReached => _portfolioApi.maxBalanceReached;

  /// Returns `true` if the maximum number of contributions has been reached.
  bool get maxContributionReached => _portfolioApi.maxContributionReached;

  /// Initializes the repository.
  Future<void> init(String userId) async {
    await _portfolioApi.init(userId);
  }

  /// Provides a [Stream] of all accounts.
  Stream<List<Account>> getAccounts() => _portfolioApi.getAccounts();

  /// Provides a [Stream] of all accounts of the given [accountType].
  Future<List<Account>> getAccountsByType(AccountType accountType) {
    return _portfolioApi.getAccounts().firstWhere(
          (accountStream) => accountStream.any(
            (account) => account.accountType?.type == accountType.type,
          ),
          orElse: () => <Account>[],
        );
  }

  /// Saves a [account].
  ///
  /// If a [account] with the same id already exists, it will be replaced.
  Future<void> saveAccount(Account account) {
    return _portfolioApi.saveAccount(account);
  }

  /// Deletes the `account` with the given id.
  ///
  /// If no `account` with the given id exists, a [AccountNotFoundException]
  /// error is thrown.
  Future<void> deleteAccount(String id) => _portfolioApi.deleteAccount(id);

  /// Provides a [Stream] of all account types.
  Stream<List<AccountType>> getAccountTypes() =>
      _portfolioApi.getAccountTypes();

  /// Saves a [accountType].
  ///
  /// If a [accountType] with the same id already exists, it will be replaced.
  Future<void> saveAccountType(AccountType accountType) =>
      _portfolioApi.saveAccountType(accountType);

  /// Deletes the `account type` with the given id.
  ///
  /// If no `account type` with the given id exists, a
  /// [AccountTypeNotFoundException] error is thrown.
  Future<void> deleteAccountType(String id) =>
      _portfolioApi.deleteAccountType(id);

  /// Provides a [Stream] of all balances of the given account [id].
  Stream<List<Balance>> getBalances(String id) => _portfolioApi.getBalances(
        List<Account>.empty(growable: true)
          ..add(
            Account(id: id, name: '', userId: ''),
          ),
      );

  /// Provide the balances of the given [date] for the provided [accounts].
  Stream<List<Balance>> getBalanceFrom(List<Account> accounts, DateTime date) =>
      // get sum balances from the given date to return a double
      _portfolioApi.getBalances(accounts).map(
            (balances) => balances
                .where(
                  // compare date with month and year
                  (balance) =>
                      balance.date.month == date.month &&
                      balance.date.year == date.year,
                )
                .toList(),
          );

  /// Provide the balance of the given [date] for the provided [accounts].
  Future<double> getBalanceOfMonth(
    List<Account> accounts,
    DateTime date,
  ) async {
    final balance = await getBalanceFrom(accounts, date).first;
    return balance.fold<double>(
      0,
      (previousValue, element) => previousValue + element.amount,
    );
  }

  /// Provide the year balance of the given [date] for the provided [accounts].
  Future<double> getYearBalance(List<Account> accounts, DateTime date) async {
    if (date.year == DateTime.now().year) {
      final balance = await getBalanceOfMonth(accounts, DateTime.now());
      return balance;
    } else {
      final balance =
          await getBalanceOfMonth(accounts, DateTime(date.year, 12));
      return balance;
    }
  }

  /// Provide the return of the given [date].
  Future<double> getYearReturn(List<Account> accounts, DateTime date) async {
    // last day of the previous year
    final lastDayOfLastYear = DateTime(date.year - 1, 12, 31);

    // last day of the given year
    final lastDayOfTheYear = DateTime(date.year, 12, 31);
    late double balanceEndLastYear;
    late double balanceEndingDate;
    late double yearTotalContributions;
    late double yearTotalWeightedContributions;
    final results = await Future.wait([
      getBalanceOfMonth(accounts, lastDayOfLastYear),
      getBalanceOfMonth(accounts, lastDayOfTheYear),
    ]);

    balanceEndLastYear = results[0];

    if (balanceEndLastYear == 0) {
      final balanceFirstAvailableMonthOfTheYear =
          await getBalanceOfFirstAvailableMonthOfTheYear(
        accounts,
        DateTime(lastDayOfLastYear.year + 1),
      );
      balanceEndLastYear = balanceFirstAvailableMonthOfTheYear.fold<double>(
          0, (previousValue, element) => previousValue + element.amount);
    }
    balanceEndingDate = results[1];

    final resultsContributions = await Future.wait([
      getSumOfContributions(accounts, lastDayOfLastYear, lastDayOfTheYear)
          .first,
      getSumOfWeightedContributions(
        accounts,
        lastDayOfLastYear,
        lastDayOfTheYear,
      ).first,
    ]);

    yearTotalContributions = resultsContributions[0];
    yearTotalWeightedContributions = resultsContributions[1];

    final yearlyReturn = (balanceEndLastYear != 0 && balanceEndingDate != 0)
        ? (balanceEndingDate - balanceEndLastYear - yearTotalContributions) *
            100 /
            (balanceEndLastYear + yearTotalWeightedContributions)
        : 0.0;

    return yearlyReturn;
  }

  /// Provide the balances of the given [date].
  Future<List<Balance>> getBalanceOfFirstAvailableMonthOfTheYear(
    List<Account> accounts,
    DateTime date,
  ) async {
    var month = 1;
    final currentYear = date.year;
    while (month <= 12) {
      final balance = await Future.wait(
        [getBalanceFrom(accounts, DateTime(currentYear, month)).first],
      );
      if (balance[0].isNotEmpty) {
        return balance[0];
      }
      month++;
    }

    return <Balance>[];
  }

  /// Provide the last available balance.
  ///
  /// If no balance is available, 0 is returned.
  Future<double> getLastBalance(List<Account> accounts) async {
    final balances = await _portfolioApi.getBalances(accounts).first;
    if (balances.isEmpty) {
      return 0;
    }
    balances.sort((a, b) => a.date.compareTo(b.date));
    return getBalanceOfMonth(accounts, balances.last.date);
  }

  /// Saves a [balance].
  ///
  /// If a [balance] with the same id already exists, it will be replaced.
  Future<void> saveBalance(Balance balance) =>
      _portfolioApi.saveBalance(balance);

  /// Deletes the `balance` with the given id.
  ///
  /// If no `balance` with the given id exists, a
  /// [BalanceNotFoundException] error is thrown.
  Future<void> deleteBalance(String id) => _portfolioApi.deleteBalance(id);

  /// Provides a [Stream] of all contributions of the given account [id].
  Stream<List<Contribution>> getContributions(String id) =>
      _portfolioApi.getContributionsFromAccount(id);

  /// Provides a [Stream] of the sum of all contributions within the given
  /// [startDate] and [endDate].
  /// Compare date with month and year
  Stream<double> getSumOfContributions(
    List<Account> accounts,
    DateTime startDate,
    DateTime endDate,
  ) =>
      _portfolioApi.getContributions(accounts).map(
            (contributions) => contributions
                .where((contribution) {
                  final contributionDate =
                      DateTime(contribution.date.year, contribution.date.month);
                  final start = DateTime(startDate.year, startDate.month);
                  final end = DateTime(endDate.year, endDate.month);
                  return (contributionDate.isAfter(start)) &&
                      (contributionDate.isBefore(end) ||
                          contributionDate.isAtSameMomentAs(end));
                })
                .toList()
                .fold<double>(
                  0,
                  (previousValue, element) => previousValue + element.amount,
                ),
          );

  /// Provides a [Stream] of the sum of all weighted contributions within the
  /// [startDate] and [endDate].
  /// Compare date with month and year
  Stream<double> getSumOfWeightedContributions(
    List<Account> accounts,
    DateTime startDate,
    DateTime endDate,
  ) {
    // number of days between start and end date
    final numDays = endDate.difference(startDate).inDays + 1;

    return _portfolioApi.getContributions(accounts).map(
          (contributions) => contributions
              .where((contribution) {
                final contributionDate =
                    DateTime(contribution.date.year, contribution.date.month);
                final start = DateTime(startDate.year, startDate.month);
                final end = DateTime(endDate.year, endDate.month);
                return (contributionDate.isAfter(start)) &&
                    (contributionDate.isBefore(end) ||
                        contributionDate.isAtSameMomentAs(end));
              })
              .toList()
              .fold<double>(
                  0,
                  (previousValue, element) =>
                      previousValue + element.weightedAmount(numDays)),
        );
  }

  /// Saves a [contribution].
  ///
  /// If a [contribution] with the same id already exists, it will be replaced.
  Future<void> saveContribution(Contribution contribution) =>
      _portfolioApi.saveContribution(contribution);

  /// Deletes the `contribution` with the given id.
  ///
  /// If no `contribution` with the given id exists, a
  /// [ContributionNotFoundException] error is thrown.
  Future<void> deleteContribution(String id) =>
      _portfolioApi.deleteContribution(id);

  /// Provides a [Future] of all yearly returns.
  Future<Map<double, double>> getAllYearlyReturns(
    List<Account> accounts,
  ) async {
    final yearlyReturns = <double, double>{};
    final balances = await _portfolioApi.getBalances(accounts).first;
    if (balances.isNotEmpty) {
      final firstBalance = balances.last;
      final firstBalanceDate = firstBalance.date;
      var year = firstBalanceDate.year;

      while (year <= DateTime.now().year) {
        // if the year is the current year, we don't want to show the return
        final yearReturn = await getYearReturn(accounts, DateTime.now());
        if (!(year == DateTime.now().year && yearReturn == 0.0)) {
          final returns = await getYearReturn(accounts, DateTime(year));
          yearlyReturns[year.toDouble()] =
              double.parse(returns.toStringAsFixed(2));
        }
        year++;
      }
    }
    return yearlyReturns;
  }

  /// Provides a [Future] of all yearly balances.
  Future<Map<double, double>> getAllYearlyBalances(
    List<Account> accounts,
  ) async {
    final yearlyBalances = <double, double>{};
    final balances = await _portfolioApi.getBalances(accounts).first;
    if (balances.isNotEmpty) {
      final firstBalance = balances.last;
      final firstBalanceDate = firstBalance.date;
      var year = firstBalanceDate.year;

      while (year <= DateTime.now().year) {
        final yearBalance = await getYearBalance(accounts, DateTime(year));
        if (yearBalance != 0) {
          yearlyBalances[year.toDouble()] =
              double.parse(yearBalance.toStringAsFixed(2));
        }
        year++;
      }
    }
    return yearlyBalances;
  }

  /// Provides a [Future] of the account distribution.
  Future<Map<Account, double>> getAccountDistribution(
    List<Account> accounts,
  ) async {
    final accountDistribution = <Account, double>{};
    final balances = await _portfolioApi.getBalances(accounts).first;
    if (balances.isNotEmpty) {
      final totalBalance = await getLastBalance(accounts);
      final firstBalance = balances.first;
      final balancesPerAccount =
          await getBalanceFrom(accounts, firstBalance.date).first;
      // group balances by account
      groupBy<Balance, String>(
        balancesPerAccount,
        (balance) => balance.accountId,
      ).forEach((key, value) {
        final account = accounts.firstWhere((account) => account.id == key);
        final balance = value.fold<double>(
          0,
          (previousValue, element) => previousValue + element.amount,
        );
        accountDistribution[account] = balance / totalBalance * 100;
      });
    }

    return accountDistribution;
  }

  /// Provides a [Future] of all yearly cashflow.
  Future<Map<double, double>> getAllYearlyCashflows(
    List<Account> accounts,
  ) async {
    final yearlyContributions = <double, double>{};
    final contributions = await _portfolioApi.getContributions(accounts).first;
    if (contributions.isNotEmpty) {
      final firstContribution = contributions.last;
      final firstContributionDate = firstContribution.date;
      var year = firstContributionDate.year;

      while (year <= DateTime.now().year) {
        final yearContribution = await getSumOfContributions(
          accounts,
          DateTime(year - 1, 12, 31),
          DateTime(year, 12, 31),
        ).first;
        yearlyContributions[year.toDouble()] =
            double.parse(yearContribution.toStringAsFixed(2));
        year++;
      }
    }
    return yearlyContributions;
  }
}
