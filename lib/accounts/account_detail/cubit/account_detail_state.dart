part of 'account_detail_cubit.dart';

final class AccountDetailState extends Equatable {
  const AccountDetailState({
    required this.account,
  });

  final Account account;

  @override
  List<Object?> get props => [account];
}
