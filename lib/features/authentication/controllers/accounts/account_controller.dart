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
/// Holds active (non-archived) accounts only. Screens that need
/// archived ones (Accounts management, step 3.1) call
/// AccountService.list(includeArchived: true) themselves.
class AccountController extends GetxController {
  static AccountController get instance => Get.find();

  final AccountService _service = AccountService();

  final RxList<AccountModel> accounts = <AccountModel>[].obs;
  final Rx<AccountSummaryModel> summary = AccountSummaryModel.empty.obs;
  final RxBool isLoading = false.obs;

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
