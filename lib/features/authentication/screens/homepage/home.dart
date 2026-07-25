import 'package:adips/features/authentication/screens/homepage/widgets/account_balance.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/date_range_filter.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/greeting_header.dart';
import 'package:adips/features/authentication/screens/homepage/widgets/sort_filter.dart';
import 'package:flutter/material.dart';

import '../../../../utils/constants/adips_palette.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static String name = "Adish";
  static String email = "adish@gmail.com";

  static double accountBalance = 125650.00;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    return Scaffold(
      backgroundColor: isDark
          ? AdipsPalette.darkBackground
          : AdipsPalette.lightBackground,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AdipsSizes.defaultSpace,
          ),
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
                  DateRangeFilter(
                    onChanged: (selection) {
                      debugPrint('Range: ${selection.label} -> ${selection.range.start} to ${selection.range.end}');
                      // trigger your data fetch here
                    },
                  ),
                  SortFilter(
                    onChanged: (sort) {
                      debugPrint('Sort: ${sort.label}');
                      // re-sort your list here
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}