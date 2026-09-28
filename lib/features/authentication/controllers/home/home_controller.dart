import 'package:adips/data/services/transfer_service.dart';
import 'package:adips/features/authentication/controllers/accounts/account_controller.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/sort_filter.dart';
import 'package:adips/utils/http/http_client.dart';
import 'package:adips/utils/local_storage/storage_utility.dart';
import 'package:adips/utils/models/app_transaction.dart';
import 'package:adips/utils/services/transaction_api.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Owns every piece of state the home screen shows: the logged-in
/// user's name/email, the account balance + summary, and the list of
/// transactions (plus search/sort/date-range applied to it locally).
///
/// All backend calls go through [TransactionApi]; this controller's
/// job is state + orchestration, not HTTP details.
class HomeController extends GetxController {
  static HomeController get instance => Get.find();

  final RxString fullName = ''.obs;
  final RxString email = ''.obs;

  final Rx<TransactionSummary> summary = TransactionSummary.empty.obs;
  final RxList<AppTransaction> transactions = <AppTransaction>[].obs;

  final RxBool isLoading = false.obs;
  final RxBool isMutating = false.obs; // create/update/delete in flight

  /// Account the Home list + income/expense strip are filtered to;
  /// null = all accounts. The balance card and account cards always
  /// show every account (they come from /accounts, not from this).
  final Rx<int?> selectedAccountId = Rx<int?>(null);

  /// True while a filter change is fetching, so the list can show a
  /// thin progress bar instead of blanking the screen.
  final RxBool isFiltering = false.obs;
  int _filterSeq = 0; // ignore out-of-order responses from rapid taps

  final RxString searchQuery = ''.obs;
  final Rx<SortOption> sortOption = SortOption.newestFirst.obs;
  final Rx<DateTimeRange?> selectedRange = Rx<DateTimeRange?>(null);

  @override
  void onInit() {
    super.onInit();
    _loadUserFromArguments();
    loadAll();
  }

  /// The name/email are normally handed off by LoginController /
  /// resolveStartDestination via Get.arguments when the app routes to
  /// '/home'. If they're missing for any reason (e.g. a hot restart
  /// mid-session, or navigating here some other way), fall back to
  /// asking the backend who the current token belongs to instead of
  /// showing a blank greeting.
  Future<void> _loadUserFromArguments() async {
    final args = Get.arguments as Map<String, dynamic>?;
    final argName = (args?['fullName'] ?? '').toString();
    final argEmail = (args?['email'] ?? '').toString();

    if (argName.isNotEmpty || argEmail.isNotEmpty) {
      fullName.value = argName;
      email.value = argEmail;
      return;
    }

    final token = AdipsLocalStorage.token;
    if (token == null) return;

    try {
      final response = await AdipsHttpHelper.get(
        '/api/v1/users/validate',
        cookie: 'Authorization=$token',
      );
      final user = AdipsHttpHelper.data(response);
      fullName.value = (user['name'] ?? '').toString();
      email.value = (user['email'] ?? '').toString();
    } catch (_) {
      // Leave name/email blank; the greeting header just shows less.
    }
  }

  /// Fetches the transaction list + summary together. Used on first
  /// load and pull-to-refresh.
  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        TransactionApi.list(
          sortBy: 'transaction_date',
          order: 'desc',
          accountId: selectedAccountId.value,
        ),
        TransactionApi.summary(accountId: selectedAccountId.value),
        // Balances live on the backend; reload them with the list so
        // the two are never out of sync. Handles its own errors.
        AccountController.instance.load(),
      ]);
      transactions.assignAll(results[0] as List<AppTransaction>);
      summary.value = results[1] as TransactionSummary;
      await _dropStaleSelection();
    } catch (e) {
      Get.snackbar(
        'Could not load data',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Re-fetches quietly (no full-screen spinner) — used after a
  /// create/update/delete so the balance, summary, and list all stay
  /// consistent with the database without a jarring loading flash.
  Future<void> _refreshQuietly() async {
    try {
      final results = await Future.wait([
        TransactionApi.list(
          sortBy: 'transaction_date',
          order: 'desc',
          accountId: selectedAccountId.value,
        ),
        TransactionApi.summary(accountId: selectedAccountId.value),
        // Any create/update/delete changes account balances too.
        AccountController.instance.refreshQuietly(),
      ]);
      transactions.assignAll(results[0] as List<AppTransaction>);
      summary.value = results[1] as TransactionSummary;
      await _dropStaleSelection();
    } catch (e) {
      Get.snackbar(
        'Could not refresh',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Currency the income/expense strip is shown in: the selected
  /// account's, or the default account's when showing all accounts.
  String get summaryCurrency {
    final accounts = AccountController.instance;
    final selectedId = selectedAccountId.value;
    final selected = selectedId == null ? null : accounts.byId(selectedId);
    return (selected ?? accounts.defaultAccount)?.currency ?? 'INR';
  }

  /// Filters Home by account. Tapping the already-selected account,
  /// or passing null ("All"), clears the filter. Only the list and
  /// the income/expense summary are re-fetched: balances don't
  /// depend on the filter.
  Future<void> selectAccount(int? id) async {
    final previous = selectedAccountId.value;
    final next = id == previous ? null : id;
    if (next == previous) return; // "All" tapped while already on All

    selectedAccountId.value = next; // highlight immediately
    final seq = ++_filterSeq;
    isFiltering.value = true;
    try {
      final results = await Future.wait([
        TransactionApi.list(
          sortBy: 'transaction_date',
          order: 'desc',
          accountId: next,
        ),
        TransactionApi.summary(accountId: next),
      ]);
      if (seq != _filterSeq) return; // a newer tap superseded this one
      transactions.assignAll(results[0] as List<AppTransaction>);
      summary.value = results[1] as TransactionSummary;
    } catch (e) {
      if (seq != _filterSeq) return;
      selectedAccountId.value = previous; // keep highlight = data shown
      Get.snackbar(
        'Could not filter',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (seq == _filterSeq) isFiltering.value = false;
    }
  }

  /// If the filtered account no longer exists among active accounts
  /// (archived or deleted elsewhere), go back to "All" instead of
  /// showing an empty list for an account the user can't see.
  Future<void> _dropStaleSelection() async {
    final id = selectedAccountId.value;
    if (id == null || AccountController.instance.byId(id) != null) return;
    selectedAccountId.value = null;
    final results = await Future.wait([
      TransactionApi.list(sortBy: 'transaction_date', order: 'desc'),
      TransactionApi.summary(),
    ]);
    transactions.assignAll(results[0] as List<AppTransaction>);
    summary.value = results[1] as TransactionSummary;
  }

  // ---- Local search / sort / date-range over the fetched list -----

  void setSearchQuery(String value) => searchQuery.value = value;

  void setSortOption(SortOption value) => sortOption.value = value;

  void setDateRange(DateTimeRange? range) => selectedRange.value = range;

  List<AppTransaction> get visibleTransactions {
    var filtered = transactions.where((t) => t.matchesQuery(searchQuery.value));

    final range = selectedRange.value;
    if (range != null) {
      final start = DateTime(range.start.year, range.start.month, range.start.day);
      final end = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59);
      filtered = filtered.where(
            (t) => !t.transactionDate.isBefore(start) && !t.transactionDate.isAfter(end),
      );
    }

    final list = filtered.toList();
    list.sort((a, b) {
      switch (sortOption.value) {
        case SortOption.newestFirst:
          return b.transactionDate.compareTo(a.transactionDate);
        case SortOption.oldestFirst:
          return a.transactionDate.compareTo(b.transactionDate);
        case SortOption.amountHighToLow:
          return b.amount.compareTo(a.amount);
        case SortOption.amountLowToHigh:
          return a.amount.compareTo(b.amount);
      }
    });
    return list;
  }

  // ---- Mutations ----------------------------------------------------

  Future<bool> createTransaction({
    required int accountId,
    required double amount,
    required String type,
    required String category,
    required int categoryIconId,
    required int categoryColorId,
    required String description,
    required String status,
    required String paymentMethod,
    String note = '',
    String currency = 'INR',
    DateTime? transactionDate,
  }) async {
    isMutating.value = true;
    try {
      await TransactionApi.create(
        accountId: accountId,
        amount: amount,
        type: type,
        category: category,
        categoryIconId: categoryIconId,
        categoryColorId: categoryColorId,
        description: description,
        status: status,
        paymentMethod: paymentMethod,
        note: note,
        currency: currency,
        transactionDate: transactionDate,
      );
      await _refreshQuietly();
      Get.snackbar('Added', 'Transaction created', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar(
        'Could not add transaction',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<bool> updateTransaction(
      int id, {
        int? accountId,
        double? amount,
        String? type,
        String? category,
        int? categoryIconId,
        int? categoryColorId,
        String? description,
        String? status,
        String? paymentMethod,
        String? note,
        String? currency,
        DateTime? transactionDate,
      }) async {
    isMutating.value = true;
    try {
      await TransactionApi.update(
        id,
        accountId: accountId,
        amount: amount,
        type: type,
        category: category,
        categoryIconId: categoryIconId,
        categoryColorId: categoryColorId,
        description: description,
        status: status,
        paymentMethod: paymentMethod,
        note: note,
        currency: currency,
        transactionDate: transactionDate,
      );
      await _refreshQuietly();
      Get.snackbar('Saved', 'Transaction updated', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar(
        'Could not save changes',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  // ---- Transfer mutations ---------------------------------------------
  // A transfer is two linked rows, so unlike a normal transaction it
  // changes two account balances at once: always refresh both the
  // list and the accounts afterwards (_refreshQuietly does both).

  final TransferService _transferService = TransferService();

  Future<bool> createTransfer({
    required int fromAccountId,
    required int toAccountId,
    required double amount,
    DateTime? transactionDate,
    String note = '',
  }) async {
    isMutating.value = true;
    try {
      await _transferService.create(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        transactionDate: transactionDate,
        note: note,
      );
      await _refreshQuietly();
      Get.snackbar('Transferred', 'Money moved between accounts',
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar(
        'Could not transfer',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<bool> updateTransfer(
    String groupId, {
    int? fromAccountId,
    int? toAccountId,
    double? amount,
    DateTime? transactionDate,
    String? note,
  }) async {
    isMutating.value = true;
    try {
      await _transferService.update(
        groupId,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        transactionDate: transactionDate,
        note: note,
      );
      await _refreshQuietly();
      Get.snackbar('Saved', 'Transfer updated', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar(
        'Could not save changes',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<bool> deleteTransfer(String groupId) async {
    isMutating.value = true;
    try {
      await _transferService.delete(groupId);
      await _refreshQuietly();
      Get.snackbar('Deleted', 'Transfer removed', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar(
        'Could not delete transfer',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isMutating.value = false;
    }
  }

  Future<bool> deleteTransaction(int id) async {
    isMutating.value = true;
    try {
      await TransactionApi.delete(id);
      await _refreshQuietly();
      Get.snackbar('Deleted', 'Transaction removed', snackPosition: SnackPosition.BOTTOM);
      return true;
    } catch (e) {
      Get.snackbar(
        'Could not delete transaction',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isMutating.value = false;
    }
  }
}