// widgets/states/load_error_view.dart
import 'package:flutter/material.dart';

import '../../../utils/constants/adips_palette.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../buttons/custom_elevated_button.dart';

/// "Couldn't load, try again" state (W.1).
///
/// Used instead of an empty list when a load failed, so an offline
/// device or a sleeping Render server (cold start, Q6) doesn't look
/// like "you have no data". [message] is the readable text from
/// AdipsHttpHelper.
///
/// [compact] is a one-line banner for when some data is still on
/// screen; the default is a centred block for when there is nothing
/// to show.
class LoadErrorView extends StatelessWidget {
  const LoadErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.compact = false,
  });

  final String message;
  final VoidCallback onRetry;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    final textColor = isDark ? AdipsPalette.darkTextPrimary : AdipsPalette.lightTextPrimary;
    final mutedColor = isDark ? AdipsPalette.darkTextMuted : AdipsPalette.lightTextMuted;
    final lossColor = isDark ? AdipsPalette.darkLoss : AdipsPalette.lightLoss;
    final lineColor = isDark ? AdipsPalette.darkLine : AdipsPalette.lightLine;

    if (compact) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AdipsSizes.sm,
          vertical: AdipsSizes.xs,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AdipsSizes.borderRadiusSm),
          border: Border.all(color: lineColor),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off_outlined, size: AdipsSizes.iconSm, color: lossColor),
            const SizedBox(width: AdipsSizes.sm),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: mutedColor, fontSize: AdipsSizes.fontSizesEs),
              ),
            ),
            TextButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AdipsSizes.defaultSpace),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 48, color: mutedColor),
            const SizedBox(height: AdipsSizes.spaceBtwItems),
            Text(
              'Couldn\'t load your data',
              style: TextStyle(
                fontSize: AdipsSizes.fontSizesLg,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: AdipsSizes.xs),
            Text(message, textAlign: TextAlign.center, style: TextStyle(color: mutedColor)),
            const SizedBox(height: AdipsSizes.spaceBtwSections),
            CustomButton(text: 'Retry', width: 160, onPressed: onRetry),
          ],
        ),
      ),
    );
  }
}
