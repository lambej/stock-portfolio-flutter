import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_portfolio/api/model/currency_enum.dart';

class UserSharedPrefService {
  /// {@macro local_storage_portfolio_api}
  UserSharedPrefService({
    required SharedPreferences plugin,
  }) : _plugin = plugin;

  final SharedPreferences _plugin;

  /// The key used for storing the user currency preference locally.
  ///
  /// This is only exposed for testing and shouldn't be used by consumers of
  /// this library.
  @visibleForTesting
  static const kCurrencyPref = '__currency_key__';

  String? _getValue(String key) => _plugin.getString(key);
  Future<void> _setValue(String key, String value) =>
      _plugin.setString(key, value);

  /// Get the user currency preference.
  Currency getCurrencyPref() {
    return Currency
        .usd; //CurrencyX.from(_getValue(kCurrencyPref) ?? Currency.usd.toString());
  }

  /// Set the user currency preference.
  Future<void> setCurrencyPref(Currency currency) async {
    await _setValue(kCurrencyPref, currency.name);
  }
}
