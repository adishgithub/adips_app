import 'package:adips/common/widgets/navigation/bottom_action_bar.dart';
import 'package:adips/features/authentication/controllers/home/home_controller.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/account_balance.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/date_range_filter.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/greeting_header.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/sort_filter.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/transaction_form_sheet.dart';
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
                    AccountBalance(accountBalance: controller.summary.value.balance),
                    SizedBox(height: AdipsSizes.spaceBtwSections),
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
                    SizedBox(height: AdipsSizes.spaceBtwSections),
                    TransactionSummary(
                      totalIncome: controller.summary.value.totalCredit,
                      totalExpenses: controller.summary.value.totalDebit,
                      totalTransactions: controller.summary.value.count,
                    ),
                    SizedBox(height: AdipsSizes.spaceBtwItems),
                    TransactionSearchBar(
                      controller: _searchController,
                      onChanged: controller.setSearchQuery,
                    ),
                    SizedBox(height: AdipsSizes.spaceBtwItems),
                    TransactionList(transactions: controller.visibleTransactions),
                    SizedBox(height: AdipsSizes.spaceBtwSections),
                  ],
                ),
              );
            }),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        onAddTap: () => showTransactionFormSheet(context),
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
