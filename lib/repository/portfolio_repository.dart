import 'dart:async';
import 'package:collection/collection.dart';
import 'package:stock_portfolio/api/model/currency_enum.dart';
import 'package:stock_portfolio/api/service/portfolio_api_service.dart';
import 'package:stock_portfolio/stock/repository/finnhub_stock_repository.dart';

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

  Stream<List<Position>> getConvertedPositions(
    List<Account> accounts,
    FinnhubRepository stockRepository,
    Currency currency,
  ) {
    return _portfolioApi.getPositions(accounts).asyncMap((positions) async {
      final pos = positions.map((position) async {
        if (position.currency.name != currency.name) {
          final convertedCost = await stockRepository.convertCurrency(
            position.cost,
            position.currency.name,
            currency.name,
          );
          final convertedPosition = position.copyWith(
            cost: convertedCost,
          );
          return convertedPosition;
        }
        return position;
      });
      return Future.wait(pos);
    });
  }

  /// Provides a [Stream] of all positions of the given accounts.
  ///
  Stream<List<Position>> getPositions(
    List<Account> accounts,
    FinnhubRepository stockRepository,
    Currency currency,
  ) {
    final positionsStream =
        getConvertedPositions(accounts, stockRepository, currency)
            .asyncMap((positions) async {
      final pos =
          groupBy(positions, (position) => position.ticker.toUpperCase())
              .values
              .toList()
              .map((positions) async {
        final costBasis = await _getCostBasis(
            positions.first, accounts, stockRepository, currency);
        final stockInfo = await stockRepository.fetchStockInformation(
            positions.first.ticker, positions.first.currency);
        final totalShares = positions.fold<double>(
          0,
          (sum, position) => sum + position.qtyOfShares,
        );
        final stockPrice = await stockRepository.convertCurrency(
          stockInfo.currentPrice,
          positions.first.currency.name,
          currency.name,
        );
        return positions.first
            .setStockPrice(stockPrice)
            .setCostBasis(costBasis)
            .setTotalShares(totalShares);
      });
      return Future.wait(pos);
    });
    return positionsStream;
  }

  /// Provides the value of the given accounts
  Future<double> getAccountsValue(List<Account> accounts,
      FinnhubRepository stockRepository, Currency currency) async {
    final positions =
        await getConvertedPositions(accounts, stockRepository, currency).first;
    final stockValues = await Future.wait(
      positions.map((position) async {
        final stockInfo = await stockRepository.fetchStockInformation(
          position.ticker,
          currency,
        );
        final stockPrice = await stockRepository.convertCurrency(
          stockInfo.currentPrice,
          currency.name,
          positions.first.currency.name,
        );
        return stockPrice * position.qtyOfShares;
      }),
    );
    return stockValues.fold<double>(
      0,
      (previousValue, element) => previousValue + element,
    );
  }

  /// Provides a [Stream] of all positions of the given accounts.
  ///
  Stream<List<Position>> getPositionTransactions(
    List<Account> accounts,
  ) {
    return _portfolioApi.getPositions(accounts);
  }

  /// Saves a [position].
  ///
  /// If a [position] with the same id already exists, it will be replaced.
  Future<void> savePosition(Position position) {
    return _portfolioApi.savePosition(position);
  }

  /// Deletes the `position` with the given id.
  ///
  /// If no `position` with the given id exists, a [PositionNotFoundException]
  Future<void> deletePosition(String id) {
    return _portfolioApi.deletePosition(id);
  }

  /// Provide the Cost Basis of the given [position] in the given [accounts].
  ///
  /// The Cost Basis is the average of the cost of all positions.
  Future<double> _getCostBasis(
    Position position,
    List<Account> accounts,
    FinnhubRepository stockRepository,
    Currency currency,
  ) async {
    final positions =
        await getConvertedPositions(accounts, stockRepository, currency).first;
    final totalCost = positions
        .where(
          (element) =>
              element.ticker.toUpperCase() == position.ticker.toUpperCase(),
        )
        .fold<double>(
          0,
          (previousValue, element) =>
              previousValue + element.cost * element.qtyOfShares,
        );
    final totalQty = positions
        .where((element) =>
            element.ticker.toUpperCase() == position.ticker.toUpperCase())
        .fold<double>(
          0,
          (previousValue, element) => previousValue + element.qtyOfShares,
        );
    return totalQty != 0 ? totalCost / totalQty : 0;
  }
}
