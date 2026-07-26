import 'package:adips/common/widgets/navigation/bottom_action_bar.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/account_balance.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/date_range_filter.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/greeting_header.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/sort_filter.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/transaction_list.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/transaction_search_bar.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/transaction_summary.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants/adips_palette.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/models/transaction_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const String name = "Adish";
  static const String email = "adish@gmail.com";
  static const double accountBalance = 125650.00;

  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  SortOption _sortOption = SortOption.newestFirst;

  final List<TransactionItem> _transactions = [
    TransactionItem(
      id: '1',
      title: 'Groceries',
      date: DateTime(2026, 7, 17),
      amount: 850,
      type: TransactionType.expense,
      category: TransactionCategory.groceries,
    ),
    TransactionItem(
      id: '2',
      title: 'Salary',
      date: DateTime(2026, 7, 15),
      amount: 30000,
      type: TransactionType.income,
      category: TransactionCategory.salary,
    ),
    TransactionItem(
      id: '3',
      title: 'Uber Ride',
      date: DateTime(2026, 7, 13),
      amount: 240,
      type: TransactionType.expense,
      category: TransactionCategory.transport,
    ),
    TransactionItem(
      id: '4',
      title: 'Movie Ticket',
      date: DateTime(2026, 7, 12),
      amount: 450,
      type: TransactionType.expense,
      category: TransactionCategory.entertainment,
    ),
    TransactionItem(
      id: '5',
      title: 'Electricity Bill',
      date: DateTime(2026, 7, 10),
      amount: 1250,
      type: TransactionType.expense,
      category: TransactionCategory.utilities,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  double get _totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0.0, (sum, t) => sum + t.amount);

  double get _totalExpenses => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0.0, (sum, t) => sum + t.amount);

  List<TransactionItem> get _visibleTransactions {
    final filtered = _transactions.where((t) => t.matchesQuery(_query)).toList();

    filtered.sort((a, b) {
      switch (_sortOption) {
        case SortOption.newestFirst:
          return b.date.compareTo(a.date);
        case SortOption.oldestFirst:
          return a.date.compareTo(b.date);
        case SortOption.amountHighToLow:
          return b.amount.compareTo(a.amount);
        case SortOption.amountLowToHigh:
          return a.amount.compareTo(b.amount);
      }
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);

    return Scaffold(
      backgroundColor: isDark ? AdipsPalette.darkBackground : AdipsPalette.lightBackground,
      body: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AdipsSizes.defaultSpace),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: AdipsSizes.spaceBtwSections),
                GreetingHeader(name: name, email: email),
                SizedBox(height: AdipsSizes.spaceBtwSections),
                AccountBalance(accountBalance: accountBalance),
                SizedBox(height: AdipsSizes.spaceBtwSections),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: DateRangeFilter(
                        onChanged: (selection) {
                          debugPrint(
                            'Range: ${selection.label} -> ${selection.range.start} to ${selection.range.end}',
                          );
                          // TODO: trigger your data fetch here
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: SortFilter(
                        onChanged: (sort) {
                          setState(() => _sortOption = sort);
                        },
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AdipsSizes.spaceBtwSections),
                TransactionSummary(
                  totalIncome: _totalIncome,
                  totalExpenses: _totalExpenses,
                  totalTransactions: _transactions.length,
                ),
                SizedBox(height: AdipsSizes.spaceBtwItems),
                TransactionSearchBar(
                  controller: _searchController,
                  onChanged: (value) => setState(() => _query = value),
                ),
                SizedBox(height: AdipsSizes.spaceBtwItems),
                TransactionList(transactions: _visibleTransactions),
                SizedBox(height: AdipsSizes.spaceBtwSections),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        onAddTap: () {
          debugPrint('Add tapped');
        },
        onSettingsTap: () {
          debugPrint('Settings tapped');
        },
      ),
    );
  }
}