import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stock_portfolio/api/model/currency_enum.dart';
import 'package:stock_portfolio/stock/model/stock_model.dart';

class FinnhubRepository {
  FinnhubRepository({required this.httpClient});

  static const usBaseUrl = 'https://finnhub.io';
  static const usApiKey = 'c16nbfn48v6ppg7evl8g';
  static const cadBaseUrl = 'https://www.alphavantage.co';
  static const cadApiKey = 'BQC4Z47UPG4Z9O4S';
  final http.Client httpClient;

  Future<StockModel> fetchStockInformation(
      String stockSymbol, Currency currency) async {
    final searchString = _trimAndUppercaseString(stockSymbol);
    if (currency == Currency.cad) {
      return _fetchStockInformationCad(searchString);
    } else {
      return _fetchStockInformationUs(searchString);
    }
  }

  Future<StockModel> _fetchStockInformationCad(String searchString) async {
    final apiRequestUrl =
        '$cadBaseUrl/query?function=GLOBAL_QUOTE&symbol=$searchString&apikey=$cadApiKey';
    final apiResponse = await httpClient.get(Uri.parse(apiRequestUrl));
    if (apiResponse.statusCode != 200) {
      return StockModel(
        tickerSymbol: searchString,
        currentPrice: 0,
        highPriceDay: 0,
        lowPriceDay: 0,
        openPriceDay: 0,
        previousClosePrice: 0,
        bullBearCondition: BullBearCondition.neutral,
        requestUnixTimestampSeconds: 0,
        requestDateTime: DateTime.now(),
      );
    }
    final apiResponseJson = jsonDecode(apiResponse.body);
    return StockModel.generateCADModel(searchString, apiResponseJson);
  }

  Future<StockModel> _fetchStockInformationUs(String searchString) async {
    final apiRequestUrl =
        '$usBaseUrl/api/v1/quote?symbol=$searchString&token=$usApiKey';
    final apiResponse = await httpClient.get(Uri.parse(apiRequestUrl));
    if (apiResponse.statusCode != 200) {
      throw Exception(
          'Error in StockApiClient.fetchStockInformation() $apiResponse');
    }
    final apiResponseJson = jsonDecode(apiResponse.body);
    return StockModel.generateUSModel(searchString, apiResponseJson);
  }

  String _trimAndUppercaseString(String inputString) {
    return inputString.trim().toUpperCase();
  }

  Future<double> convertCurrency(
      double cost, String currencyFrom, String currency) async {
    final apiRequestUrl =
        'https://api.freecurrencyapi.com/v1/latest?apikey=fca_live_VeB0t53VtWGQZtoZolWqHia9MUFKPmEod2KnOxdu&currencies=CAD';
    final apiResponse = await httpClient.get(Uri.parse(apiRequestUrl));
    if (apiResponse.statusCode != 200) {
      throw Exception('Error in StockApiClient.convertCurrency() $apiResponse');
    }

    final apiResponseJson =
        jsonDecode(apiResponse.body) as Map<String, dynamic>;
    final currencyRate =
        apiResponseJson['data'][currency.toUpperCase()] as double;
    if (currencyFrom.toLowerCase() != currency.toLowerCase()) {
      if (currencyFrom.toLowerCase() == 'cad') {
        return cost / currencyRate;
      } else {
        return cost * currencyRate;
      }
    }
    return cost;
  }
}
