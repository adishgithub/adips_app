// utils/models/home_list_item.dart
//
// One row of the Home list. The backend returns a transfer as TWO
// transactions (a debit leg and a credit leg), so when no account
// filter is active Home collapses each pair into a single
// [TransferRow]; everything else stays a plain [TransactionRow].
import 'app_transaction.dart';
import 'transfer_model.dart';

sealed class HomeListItem {
  const HomeListItem();

  /// Used by the Home date-range filter and sorting.
  DateTime get date;
  double get amount;
}

/// A normal transaction, or a single transfer leg (shown with +/-
/// when Home is filtered to one account so its statement adds up).
class TransactionRow extends HomeListItem {
  const TransactionRow(this.transaction);

  final AppTransaction transaction;

  @override
  DateTime get date => transaction.transactionDate;

  @override
  double get amount => transaction.amount;
}

/// Both legs of one transfer, shown as a single "A → B" row.
class TransferRow extends HomeListItem {
  const TransferRow({required this.debit, required this.credit});

  /// Leg on the source account (money leaves).
  final AppTransaction debit;

  /// Leg on the destination account (money arrives).
  final AppTransaction credit;

  String get transferGroupId => debit.transferGroupId ?? '';

  // Both legs share amount/date/currency (the backend edits them
  // together, X6), so read them off the debit leg.
  @override
  DateTime get date => debit.transactionDate;

  @override
  double get amount => debit.amount;

  String get currency => debit.currency;

  /// Built from the two legs already in memory, so opening the edit
  /// sheet needs no extra request.
  TransferModel toModel() => TransferModel(
        transferGroupId: transferGroupId,
        debit: debit,
        credit: credit,
      );
}
