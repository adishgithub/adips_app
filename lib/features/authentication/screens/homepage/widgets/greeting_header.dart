import 'package:flutter/cupertino.dart';

import '../../../../../utils/constants/adips_palette.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/common_helpers.dart';
import '../../../../../utils/helpers/helper_functions.dart';

class GreetingHeader extends StatelessWidget {

  static final greetings = GreetingHelper.getGreeting();

  const GreetingHeader({
    super.key,
    required this.name,
    required this.email,
  });

  final String name;
  final String email;

  @override
  Widget build(BuildContext context) {
    final bool isDark = AdipsHelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(greetings,style: TextStyle(
            color: isDark ? AdipsPalette.darkPrimaryBrandText : AdipsPalette.lightPrimaryBrandText,
            fontSize: AdipsSizes.fontSizesSm,
            fontWeight: FontWeight.bold
        )),
        SizedBox(height: AdipsSizes.spaceBtwFontsEs),
        Text("Welcome, $name",style: TextStyle(
            fontSize: AdipsSizes.fontSizesXxl,
            fontWeight: FontWeight.bold
        )),
        SizedBox(height: AdipsSizes.spaceBtwFontsEs),
        Text(email,style: TextStyle(
            fontSize: AdipsSizes.fontSizesSm
        )),
      ],
    );
  }
}