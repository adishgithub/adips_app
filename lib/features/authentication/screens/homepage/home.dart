import 'package:adips/common/widgets/navigation/bottom_action_bar.dart';
import 'package:adips/common/widgets/states/load_error_view.dart';
import 'package:adips/features/personalization/screens/accounts/accounts_screen.dart';
import 'package:adips/features/authentication/controllers/accounts/account_controller.dart';
import 'package:adips/features/authentication/controllers/home/home_controller.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/account_balance.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/add_chooser_sheet.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/account_cards.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/date_range_filter.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/greeting_header.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/sort_filter.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/transaction_list.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/transaction_search_bar.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/transaction_summary.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/adips_palette.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeController controller = HomeController.instance;
  final AccountController accountController = AccountController.instance;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? AdipsPalette.darkBackground : AdipsPalette.lightBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: controller.loadAll,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AdipsSizes.defaultSpace),
            child: Obx(() {
              if (controller.isLoading.value && controller.transactions.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // W.1 / Q6: the load failed (offline, or Render still
              // waking up). With nothing to show, a Retry screen beats
              // a "0.00 / No transactions" page that reads as real.
              final loadError = controller.loadError.value;
              if (loadError != null &&
                  controller.transactions.isEmpty &&
                  accountController.accounts.isEmpty) {
                return LoadErrorView(message: loadError, onRetry: controller.loadAll);
              }

              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: AdipsSizes.spaceBtwSections),
                    GreetingHeader(
                      name: controller.fullName.value,
                      email: controller.email.value,
                    ),
                    SizedBox(height: AdipsSizes.spaceBtwSections),
                    // Partial failure (e.g. accounts loaded, list did
                    // not): keep what we have, but say so.
                    if (loadError != null) ...[
                      LoadErrorView(
                        message: loadError,
                        onRetry: controller.loadAll,
                        compact: true,
                      ),
                      SizedBox(height: AdipsSizes.spaceBtwItems),
                    ],
                    // Total comes from /accounts/summary (real balances),
                    // NOT transactions/summary.balance, which is only the
                    // net flow of the filtered rows.
                    AccountBalance(totals: accountController.summary.value.totals),
                    SizedBox(height: AdipsSizes.spaceBtwItems),
                    // Tap a card to filter the list + summary below to
                    // that account; tap it again or "All" to clear.
                    AccountCards(
                      accounts: accountController.accounts.toList(),
                      selectedId: controller.selectedAccountId.value,
                      onTap: (account) => controller.selectAccount(account.id),
                      onClear: () => controller.selectAccount(null),
                      // Only offer "Add account" when accounts really
                      // loaded and there are none.
                      onAddAccount: (!accountController.isLoading.value &&
                              accountController.loadError.value == null)
                          ? () => Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const AccountsScreen()),
                              )
                          : null,
                    ),
                    // Every gap between the blocks below (balance, account
                    // cards, filters, summary, search) is spaceBtwItems, so
                    // the spacing reads evenly.
                    SizedBox(height: AdipsSizes.spaceBtwItems),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: DateRangeFilter(
                            onChanged: (selection) {
                              controller.setDateRange(selection.range);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: SortFilter(
                            onChanged: (sort) => controller.setSortOption(sort),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AdipsSizes.spaceBtwItems),
                    TransactionSummary(
                      totalIncome: controller.summary.value.totalCredit,
                      totalExpenses: controller.summary.value.totalDebit,
                      totalTransactions: controller.summary.value.count,
                      currency: controller.summaryCurrency,
                    ),
                    SizedBox(height: AdipsSizes.spaceBtwItems),
                    TransactionSearchBar(
                      controller: _searchController,
                      onChanged: controller.setSearchQuery,
                    ),
                    SizedBox(height: AdipsSizes.spaceBtwItems),
                    if (controller.isFiltering.value)
                      const Padding(
                        padding: EdgeInsets.only(bottom: AdipsSizes.sm),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    TransactionList(items: controller.visibleItems),
                    SizedBox(height: AdipsSizes.spaceBtwSections),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        // Asks Transaction vs Transfer first (see add_chooser_sheet).
        onAddTap: () => showAddChooserSheet(context),
        onSettingsTap: () => Get.toNamed(
          '/settings',
          arguments: {
            'fullName': controller.fullName.value,
            'email': controller.email.value,
          },
        ),
      ),
    );
  }
}
