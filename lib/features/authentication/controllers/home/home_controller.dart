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
        TransactionApi.list(sortBy: 'transaction_date', order: 'desc'),
        TransactionApi.summary(),
      ]);
      transactions.assignAll(results[0] as List<AppTransaction>);
      summary.value = results[1] as TransactionSummary;
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
        TransactionApi.list(sortBy: 'transaction_date', order: 'desc'),
        TransactionApi.summary(),
      ]);
      transactions.assignAll(results[0] as List<AppTransaction>);
      summary.value = results[1] as TransactionSummary;
    } catch (e) {
      Get.snackbar(
        'Could not refresh',
        e.toString().replaceFirst('Exception: ', ''),
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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
    required double amount,
    required String type,
    required String category,
    required String description,
    required String status,
    required String paymentMethod,
    String note = '',
    String currency = 'INR',
  }) async {
    isMutating.value = true;
    try {
      await TransactionApi.create(
        amount: amount,
        type: type,
        category: category,
        description: description,
        status: status,
        paymentMethod: paymentMethod,
        note: note,
        currency: currency,
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
    double? amount,
    String? type,
    String? category,
    String? description,
    String? status,
    String? paymentMethod,
    String? note,
    String? currency,
  }) async {
    isMutating.value = true;
    try {
      await TransactionApi.update(
        id,
        amount: amount,
        type: type,
        category: category,
        description: description,
        status: status,
        paymentMethod: paymentMethod,
        note: note,
        currency: currency,
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
