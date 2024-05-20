enum Currency { usd, cad }

extension CurrencyX on Currency {
  static const _currencyMap = {
    Currency.usd: 'USD',
    Currency.cad: 'CAD',
  };

  static Currency from(String currency) {
    return _currencyMap.entries
        .firstWhere((entry) => entry.value == currency)
        .key;
  }

  String get value => _currencyMap[this]!;
}
