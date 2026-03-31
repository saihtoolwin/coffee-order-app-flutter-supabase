import 'package:supabase_flutter/supabase_flutter.dart';

class OrderService {
  final _supabase = Supabase.instance.client;

  Future<Map<String, dynamic>?> submitOrder({
    required Map<String, int> cart,
    required List<Map<String, dynamic>> products,
    String? userId,
    String? customerName,
    String? notes,
  }) async {
    final cartItems = cart.entries.toList();
    if (cartItems.isEmpty) return null;

    final orderItems = cartItems.map((entry) {
      final product = products.firstWhere((p) => p['id'] == entry.key);
      final quantity = entry.value;
      final price = (product['price'] as num).toDouble();
      return {
        'product_id': product['id'],
        'product_name': product['name'],
        'price': price,
        'quantity': quantity,
        'subtotal': price * quantity,
      };
    }).toList();

    final totalAmount = orderItems.fold<double>(
      0,
      (sum, item) => sum + (item['subtotal'] as double),
    );

    final order = await _supabase
        .from('orders')
        .insert({
          'total_amount': totalAmount,
          'user_id': userId,
          'customer_name': customerName,
          'notes': notes,
          'status': 'pending',
        })
        .select()
        .single();

    final orderId = order['id'];

    for (final item in orderItems) {
      await _supabase.from('order_items').insert({
        'order_id': orderId,
        'product_id': item['product_id'],
        'product_name': item['product_name'],
        'price': item['price'],
        'quantity': item['quantity'],
        'subtotal': item['subtotal'],
      });
    }

    return order;
  }
}
