// utils/constants/adips_icons.dart
import 'package:flutter/material.dart';

/// The full, fixed set of icons a user can pick for a transaction
/// type or category. Backend only ever stores the integer `icon_id`
/// (see adips_backend/internal/constants/icons.go, MinIconID..MaxIconID
/// = 1..80) — this list is the single source of truth for what each
/// id actually looks like. Never reorder existing entries; only ever
/// append, otherwise every previously-saved icon_id on the server
/// would suddenly point at a different icon.
class AdipsIcons {
  AdipsIcons._();

  static const List<IconData> _icons = [
    Icons.attach_money_rounded, // 1
    Icons.money_off_rounded, // 2
    Icons.swap_horiz_rounded, // 3
    Icons.account_balance_wallet_outlined, // 4
    Icons.savings_outlined, // 5
    Icons.credit_card_outlined, // 6
    Icons.account_balance_outlined, // 7
    Icons.currency_exchange_rounded, // 8
    Icons.payments_outlined, // 9
    Icons.restaurant_outlined, // 10
    Icons.local_grocery_store_outlined, // 11
    Icons.local_gas_station_outlined, // 12
    Icons.shopping_bag_outlined, // 13
    Icons.receipt_long_outlined, // 14
    Icons.movie_filter_outlined, // 15
    Icons.local_hospital_outlined, // 16
    Icons.house_outlined, // 17
    Icons.work_outline_rounded, // 18
    Icons.business_center_outlined, // 19
    Icons.trending_up_rounded, // 20
    Icons.card_giftcard_outlined, // 21
    Icons.local_taxi_outlined, // 22
    Icons.directions_car_outlined, // 23
    Icons.directions_bus_outlined, // 24
    Icons.train_outlined, // 25
    Icons.flight_outlined, // 26
    Icons.two_wheeler_outlined, // 27
    Icons.local_parking_outlined, // 28
    Icons.pedal_bike_outlined, // 29
    Icons.local_cafe_outlined, // 30
    Icons.fastfood_outlined, // 31
    Icons.icecream_outlined, // 32
    Icons.local_bar_outlined, // 33
    Icons.cake_outlined, // 34
    Icons.bolt_outlined, // 35
    Icons.water_drop_outlined, // 36
    Icons.wifi_outlined, // 37
    Icons.phone_iphone_outlined, // 38
    Icons.tv_outlined, // 39
    Icons.local_laundry_service_outlined, // 40
    Icons.cleaning_services_outlined, // 41
    Icons.checkroom_outlined, // 42
    Icons.diamond_outlined, // 43
    Icons.watch_outlined, // 44
    Icons.spa_outlined, // 45
    Icons.face_retouching_natural_outlined, // 46
    Icons.fitness_center_outlined, // 47
    Icons.sports_soccer_outlined, // 48
    Icons.sports_esports_outlined, // 49
    Icons.music_note_outlined, // 50
    Icons.theaters_outlined, // 51
    Icons.book_outlined, // 52
    Icons.school_outlined, // 53
    Icons.child_care_outlined, // 54
    Icons.pets_outlined, // 55
    Icons.park_outlined, // 56
    Icons.beach_access_outlined, // 57
    Icons.hotel_outlined, // 58
    Icons.luggage_outlined, // 59
    Icons.map_outlined, // 60
    Icons.medical_services_outlined, // 61
    Icons.medication_outlined, // 62
    Icons.healing_outlined, // 63
    Icons.favorite_border_rounded, // 64
    Icons.shield_outlined, // 65
    Icons.security_outlined, // 66
    Icons.gavel_outlined, // 67
    Icons.handyman_outlined, // 68
    Icons.build_outlined, // 69
    Icons.construction_outlined, // 70
    Icons.apartment_outlined, // 71
    Icons.chair_outlined, // 72
    Icons.kitchen_outlined, // 73
    Icons.local_shipping_outlined, // 74
    Icons.storefront_outlined, // 75
    Icons.volunteer_activism_outlined, // 76
    Icons.celebration_outlined, // 77
    Icons.redeem_outlined, // 78
    Icons.category_outlined, // 79
    Icons.more_horiz_rounded, // 80
  ];

  /// icon_id is 1-based on the backend; this converts to the 0-based
  /// list index and falls back to a generic icon for any id outside
  /// the known range instead of throwing.
  static IconData byId(int id) {
    final index = id - 1;
    if (index < 0 || index >= _icons.length) return Icons.category_outlined;
    return _icons[index];
  }

  /// All (id, icon) pairs, in order — what the icon picker grid renders.
  static List<MapEntry<int, IconData>> get all =>
      List.generate(_icons.length, (i) => MapEntry(i + 1, _icons[i]));
}
