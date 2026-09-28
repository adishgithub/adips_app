// controllers/accounts/account_controller.dart
import 'package:adips/data/services/account_service.dart';
import 'package:adips/utils/models/account_model.dart';
import 'package:get/get.dart';

/// Shared account state for the whole app: the account list (with
/// backend-computed balances) and the dashboard summary.
///
/// Balances are never calculated here — they come from the backend
/// (D1), so after ANY change that can affect a balance (create / edit /
/// delete a transaction, a transfer, ...) call [refreshQuietly] and
/// the numbers stay correct. HomeController already does this after
/// every transaction mutation.
///
/// [accounts] holds active (non-archived) accounts only, so Home and
/// every picker never see archived ones. The Accounts management
/// screen's "Show archived" toggle reads [archivedAccounts], filled
/// on demand by [loadArchived].
class AccountController extends GetxController {
  static AccountController get instance => Get.find();

  final AccountService _service = AccountService();

  final RxList<AccountModel> accounts = <AccountModel>[].obs;
  final Rx<AccountSummaryModel> summary = AccountSummaryModel.empty.obs;
  final RxBool isLoading = false.obs;

  /// Archived accounts (A12). Empty until [loadArchived] is called.
  final RxList<AccountModel> archivedAccounts = <AccountModel>[].obs;

  /// Active accounts, in the backend's sort_order.
  List<AccountModel> get activeAccounts =>
      accounts.where((a) => !a.isArchived).toList();

  /// The user's default account (A5: exactly one). Falls back to the
  /// first active account, and to null only when nothing is loaded yet.
  AccountModel? get defaultAccount {
    final active = activeAccounts;
    if (active.isEmpty) return null;
    return active.firstWhere((a) => a.isDefault, orElse: () => active.first);
  }

  AccountModel? byId(int id) {
    for (final a in accounts) {
      if (a.id == id) return a;
    }
    return null;
  }

  // No load() in onInit on purpose: HomeController.loadAll() loads
  // accounts together with the transactions, so loading here too would
  // fetch everything twice at startup.

  /// Loads accounts + summary with a loading flag (first load,
  /// pull-to-refresh).
  Future<void> load() async {
    isLoading.value = true;
    try {
      await _fetch();
    } catch (e) {
      _showError('Could not load accounts', e);
    } finally {
      isLoading.value = false;
    }
  }

  /// Same as [load] but without touching [isLoading], so the UI doesn't
  /// flash a spinner after a create/update/delete.
  Future<void> refreshQuietly() async {
    try {
      await _fetch();
    } catch (e) {
      _showError('Could not refresh accounts', e);
    }
  }

  /// Fetches the archived accounts for the "Show archived" list.
  Future<void> loadArchived() async {
    try {
      final all = await _service.list(includeArchived: true);
      archivedAccounts.assignAll(all.where((a) => a.isArchived));
    } catch (e) {
      _showError('Could not load archived accounts', e);
    }
  }

  /// Archives an account, then refreshes balances/lists. Does NOT
  /// catch: the server's 409 message (default account, last active
  /// account, non-zero balance) is thrown as ApiException so the
  /// screen can show it, or offer "transfer balance out".
  Future<void> archive(int id, {bool refreshArchived = false}) async {
    await _service.archive(id);
    await Future.wait([
      refreshQuietly(),
      if (refreshArchived) loadArchived(),
    ]);
  }

  /// Unarchives an account (always allowed), then refreshes.
  Future<void> unarchive(int id, {bool refreshArchived = false}) async {
    await _service.unarchive(id);
    await Future.wait([
      refreshQuietly(),
      if (refreshArchived) loadArchived(),
    ]);
  }

  /// Moves the active account at [oldIndex] to [newIndex] (the raw
  /// indices ReorderableListView reports) and saves the new order.
  ///
  /// The list is updated first so the drag doesn't snap back while the
  /// request is in flight. If the save fails, the server's order is
  /// re-fetched (so the UI never shows an order that wasn't saved) and
  /// the error is rethrown for the screen to show.
  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;

    final list = accounts.toList();
    final moved = list.removeAt(oldIndex);
    list.insert(newIndex, moved);
    final reordered = [
      for (int i = 0; i < list.length; i++) list[i].copyWith(sortOrder: i),
    ];
    accounts.assignAll(reordered);

    try {
      await _service.reorder([
        for (final a in reordered) {'id': a.id, 'sort_order': a.sortOrder},
      ]);
      // Keep the dashboard summary's account order in step too.
      await refreshQuietly();
    } catch (e) {
      await refreshQuietly();
      rethrow;
    }
  }

  /// Read-only preview of a merge-delete. Does NOT catch: the server's
  /// message is thrown so the sheet can show it inline.
  Future<AccountDeletePreview> deletePreview(int id, int moveTo) =>
      _service.deletePreview(id, moveTo: moveTo);

  /// Deletes an account (optionally merging its transactions into
  /// [moveTransactionsTo]), then refreshes balances/lists. Does NOT
  /// catch: the 409/400 message is thrown as ApiException for the
  /// screen to show.
  ///
  /// A merge changes transactions on the target, so callers must also
  /// refresh Home (see AccountsScreen).
  Future<void> delete(
    int id, {
    int? moveTransactionsTo,
    bool refreshArchived = false,
  }) async {
    await _service.delete(id, moveTransactionsTo: moveTransactionsTo);
    await Future.wait([
      refreshQuietly(),
      if (refreshArchived) loadArchived(),
    ]);
  }

  Future<void> _fetch() async {
    final results = await Future.wait([_service.list(), _service.summary()]);
    accounts.assignAll(results[0] as List<AccountModel>);
    summary.value = results[1] as AccountSummaryModel;
  }

  void _showError(String title, Object e) {
    Get.snackbar(
      title,
      e.toString().replaceFirst('Exception: ', ''),
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
