// utils/models/transfer_model.dart
//
// Mirrors adips_backend's dto.TransferResponse: one transfer = two
// linked transaction rows (legs) that share a transfer_group_id.
import 'app_transaction.dart';

class TransferModel {
  const TransferModel({
    required this.transferGroupId,
    required this.debit,
    required this.credit,
  });

  /// UUID shared by both legs. Used as the id for /transfers/:id.
  final String transferGroupId;

  /// Leg on the source account (money leaves).
  final AppTransaction debit;

  /// Leg on the destination account (money arrives).
  final AppTransaction credit;

  // Both legs always carry the same amount, date, note and currency
  // (the backend changes them together, X6), so read them off the
  // debit leg.
  double get amount => debit.amount;
  DateTime get transactionDate => debit.transactionDate;
  String get note => debit.note;
  String get currency => debit.currency;

  int get fromAccountId => debit.accountId;
  int get toAccountId => credit.accountId;
  String get fromAccountName => debit.accountName;
  String get toAccountName => credit.accountName;

  factory TransferModel.fromJson(Map<String, dynamic> json) {
    return TransferModel(
      transferGroupId: (json['transfer_group_id'] ?? '').toString(),
      debit: AppTransaction.fromJson(json['debit'] as Map<String, dynamic>),
      credit: AppTransaction.fromJson(json['credit'] as Map<String, dynamic>),
    );
  }
}
