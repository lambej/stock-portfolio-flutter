import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:stock_portfolio/repository/portfolio_repository.dart';

part 'account_detail_state.dart';

class AccountDetailCubit extends Cubit<AccountDetailState> {
  AccountDetailCubit(
    Account account,
  ) : super(AccountDetailState(account: account));

  void setAccount(Account account) =>
      emit(AccountDetailState(account: account));
}
