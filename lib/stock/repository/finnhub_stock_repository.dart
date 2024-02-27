import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:stock_portfolio/stock/model/stock_model.dart';

class FinnhubRepository {
  FinnhubRepository({required this.httpClient});

  static const baseUrl = 'https://finnhub.io';
  static const apiKey = 'c16nbfn48v6ppg7evl8g';
  final http.Client httpClient;

  Future<StockModel> fetchStockInformation(String stockSymbol) async {
    final searchString = _trimAndUppercaseString(stockSymbol);
    final apiRequestUrl =
        '$baseUrl/api/v1/quote?symbol=$searchString&token=$apiKey';
    final apiResponse = await httpClient.get(Uri.parse(apiRequestUrl));
    if (apiResponse.statusCode != 200) {
      throw Exception(
          'Error in StockApiClient.fetchStockInformation() $apiResponse');
    }
    final apiResponseJson = jsonDecode(apiResponse.body);
    return StockModel.generateModel(searchString, apiResponseJson);
  }

  String _trimAndUppercaseString(String inputString) {
    return inputString.trim().toUpperCase();
  }

  init(String id) {}
}
