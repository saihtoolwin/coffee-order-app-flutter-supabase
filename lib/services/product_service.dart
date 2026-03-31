import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final _supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final data = await _supabase.from('products').select();
    return List<Map<String, dynamic>>.from(data);
  }

  Future<Map<String, Map<String, dynamic>>> fetchCategories() async {
    final data = await _supabase.from('categories').select();
    final categories = List<Map<String, dynamic>>.from(data);
    return {for (var c in categories) c['id'] as String: c};
  }

  IconData getIconFromString(String iconName) {
    switch (iconName) {
      case 'local_cafe':
        return Icons.local_cafe_rounded;
      case 'local_drink':
        return Icons.local_drink_rounded;
      case 'whatshot':
        return Icons.whatshot_rounded;
      case 'spa':
        return Icons.spa_rounded;
      case 'grass':
        return Icons.grass_rounded;
      case 'thermostat':
        return Icons.thermostat_outlined;
      case 'cookie':
        return Icons.cookie_rounded;
      case 'emoji_food_beverage':
        return Icons.emoji_food_beverage_rounded;
      case 'icecream':
        return Icons.icecream_rounded;
      default:
        return Icons.local_cafe_rounded;
    }
  }
}
