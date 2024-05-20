import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stock_portfolio/api/service/firebase_portfolio_api_service.dart';
import 'package:stock_portfolio/api/service/user_shared_pref_service.dart';
import 'package:stock_portfolio/app/app.dart';
import 'package:stock_portfolio/authentication/authentication.dart';
import 'package:stock_portfolio/bootstrap.dart';
import 'package:stock_portfolio/firebase_options.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';
import 'package:stock_portfolio/stock/repository/finnhub_stock_repository.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final authenticationRepository = AuthenticationRepository();
  await authenticationRepository.user.first;
  final stockRepository = FinnhubRepository(
    httpClient: http.Client(),
  );
  final portfolioApi = FirebasePortfolioApiService(
    plugin: FirebaseFirestore.instance,
  );
  final userSharedPrefService = UserSharedPrefService(
    plugin: await SharedPreferences.getInstance(),
  );
  final portfolioRepository = PortfolioRepository(portfolioApi: portfolioApi);
  await bootstrap(
    () => App(
      stockRepository: stockRepository,
      authenticationRepository: authenticationRepository,
      portfolioRepository: portfolioRepository,
      userSharedPrefService: userSharedPrefService,
    ),
  );
}
