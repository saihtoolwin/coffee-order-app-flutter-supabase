import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../services/order_service.dart';
import '../main.dart';

Color _tint(Color color, double opacity) {
  final alpha = (color.a * opacity).clamp(0.0, 1.0);
  return color.withValues(alpha: alpha);
}

enum MenuCategory { all, coffee, tea, snacks }

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.imageIcon,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final double price;
  final MenuCategory category;
  final IconData imageIcon;
  final String imageUrl;
}

class MenuPage extends StatefulWidget {
  final Map<String, dynamic>? currentUser;
  final void Function(String phone)? onLogin;
  final void Function(String phone)? onRegister;
  final VoidCallback? onViewOrders;
  final VoidCallback? onLogout;

  const MenuPage({
    super.key,
    this.currentUser,
    this.onLogin,
    this.onRegister,
    this.onViewOrders,
    this.onLogout,
  });

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  static const Color _accent = Color(0xFF2F6B4F);
  static const Color _accentSoft = Color(0xFFE7F4EC);

  final _productService = ProductService();
  final _orderService = OrderService();

  List<Product> _products = [];
  List<Map<String, dynamic>> _rawProducts = [];
  Map<String, Map<String, dynamic>> _categories = {};
  bool _isLoading = true;
  String? _error;
  MenuCategory _selected = MenuCategory.all;
  final Map<String, int> _cart = <String, int>{};

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      final productsData = await _productService.fetchProducts();
      final categoriesData = await _productService.fetchCategories();
      setState(() {
        _rawProducts = productsData;
        _categories = categoriesData;
        _products = productsData.map((p) => _mapToProduct(p)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Product _mapToProduct(Map<String, dynamic> data) {
    final categoryId = data['category_id'] as String?;
    String categoryName = 'coffee';

    if (categoryId != null && _categories.containsKey(categoryId)) {
      categoryName = _categories[categoryId]!['name'] as String? ?? 'coffee';
    }

    MenuCategory category;
    switch (categoryName.toLowerCase()) {
      case 'tea':
        category = MenuCategory.tea;
        break;
      case 'snacks':
        category = MenuCategory.snacks;
        break;
      default:
        category = MenuCategory.coffee;
    }

    return Product(
      id: data['id'] as String,
      name: data['name'] as String,
      price: (data['price'] as num).toDouble(),
      category: category,
      imageIcon: _productService.getIconFromString(
        data['image_icon'] as String? ?? 'local_cafe',
      ),
      imageUrl: data['image_url'] as String? ?? '',
    );
  }

  int get _totalItems => _cart.values.fold<int>(0, (sum, value) => sum + value);

  List<Product> get _filteredProducts {
    if (_selected == MenuCategory.all) return _products;
    return _products.where((p) => p.category == _selected).toList();
  }

  int _qtyOf(Product product) => _cart[product.id] ?? 0;

  void _incrementCart(Product product) {
    setState(() {
      _cart.update(product.id, (v) => v + 1, ifAbsent: () => 1);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${product.name} added to cart')));
  }

  void _decrementCart(Product product) {
    setState(() {
      final current = _cart[product.id] ?? 0;
      if (current <= 1) {
        _cart.remove(product.id);
      } else {
        _cart[product.id] = current - 1;
      }
    });
  }

  void _clearCart() {
    setState(() {
      _cart.clear();
    });
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _CartSheet(
        cart: _cart,
        products: _products,
        rawProducts: _rawProducts,
        accent: _accent,
        accentSoft: _accentSoft,
        onIncrement: _incrementCart,
        onDecrement: _decrementCart,
        onClearAll: _clearCart,
        onSubmit: () async {
          if (widget.currentUser == null) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please login to submit order'),
                duration: Duration(seconds: 2),
              ),
            );
            widget.onLogin?.call('');
            return;
          }

          try {
            final order = await _orderService.submitOrder(
              cart: _cart,
              products: _rawProducts,
              userId: widget.currentUser!['id'],
            );
            if (!mounted) return;
            Navigator.pop(context);
            _clearCart();
            showOrderSuccessDialog(
              context,
              order?['id'].toString().substring(0, 8) ?? '',
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to submit order: $e')),
            );
          }
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Menu')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(title: const Text('Menu')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load menu',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _error = null;
                  });
                  _fetchData();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width >= 700 ? 2 : 1;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Menu'),
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.home_outlined),
          //   onPressed: () => Navigator.pop(context),
          //   tooltip: 'Home',
          // ),
          if (widget.currentUser != null) ...[
            IconButton(
              tooltip: 'My Orders',
              onPressed: widget.onViewOrders,
              icon: const Icon(Icons.receipt_long_outlined),
            ),
            // IconButton(
            //   onPressed: widget.onLogout,
            //   icon: const Icon(Icons.logout_rounded, color: Colors.red),
            //   tooltip: 'Logout',
            // ),
            PopupMenuButton<String>(
              icon: CircleAvatar(
                backgroundColor: _accentSoft,
                child: Text(
                  (widget.currentUser!['name'] ?? 'U')[0]
                      .toString()
                      .toUpperCase(),
                  style: TextStyle(color: _accent, fontWeight: FontWeight.w900),
                ),
              ),
              onSelected: (value) {
                if (value == 'orders') {
                  widget.onViewOrders?.call();
                } else if (value == 'logout') {
                  widget.onLogout?.call();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'orders',
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, color: _accent),
                      const SizedBox(width: 12),
                      const Text('My Orders'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red),
                      const SizedBox(width: 12),
                      const Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            TextButton(
              onPressed: () => widget.onLogin?.call(''),
              child: const Text(
                'Login',
                style: TextStyle(
                  color: Color(0xFF2F6B4F),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          IconButton(
            tooltip: 'Cart',
            onPressed: _totalItems > 0 ? _showCartSheet : null,
            icon: Badge(
              isLabelVisible: _totalItems > 0,
              label: Text('$_totalItems'),
              child: const Icon(Icons.shopping_cart_outlined),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 12, left: 16, right: 16),
                child: _CategoryTabs(
                  selected: _selected,
                  onSelected: (v) => setState(() => _selected = v),
                ),
              ),
            ),
            SliverToBoxAdapter(child: const SizedBox(height: 12)),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 0.86,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final product = _filteredProducts[index];
                  final qty = _qtyOf(product);
                  return _ProductCard(
                    product: product,
                    accent: _accent,
                    accentSoft: _accentSoft,
                    quantity: qty,
                    onIncrement: () => _incrementCart(product),
                    onDecrement: () => _decrementCart(product),
                  );
                }, childCount: _filteredProducts.length),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _CartFloatingButton(
        count: _totalItems,
        accent: _accent,
        onPressed: _showCartSheet,
      ),
    );
  }
}

class _CategoryTabs extends StatelessWidget {
  const _CategoryTabs({required this.selected, required this.onSelected});

  final MenuCategory selected;
  final ValueChanged<MenuCategory> onSelected;

  @override
  Widget build(BuildContext context) {
    const categories = <(MenuCategory, String)>[
      (MenuCategory.all, 'All'),
      (MenuCategory.coffee, 'Coffee'),
      (MenuCategory.tea, 'Tea'),
      (MenuCategory.snacks, 'Snacks'),
    ];

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 2),
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = categories[index].$1;
          final label = categories[index].$2;
          final isSelected = category == selected;
          final accent = _accentForChoiceChip(context);
          final icon = _iconForCategory(category);

          return ChoiceChip(
            label: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: isSelected ? Colors.white : accent),
                const SizedBox(width: 6),
                Text(label),
              ],
            ),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: accent,
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(999),
              side: BorderSide(
                color: isSelected ? Colors.transparent : _tint(accent, 0.18),
              ),
            ),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.black87,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
            ),
            onSelected: (_) => onSelected(category),
          );
        },
      ),
    );
  }

  Color _accentForChoiceChip(BuildContext context) =>
      Theme.of(context).colorScheme.primary;

  IconData _iconForCategory(MenuCategory category) {
    switch (category) {
      case MenuCategory.all:
        return Icons.all_inclusive_rounded;
      case MenuCategory.coffee:
        return Icons.local_cafe_rounded;
      case MenuCategory.tea:
        return Icons.spa_rounded;
      case MenuCategory.snacks:
        return Icons.cookie_rounded;
    }
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.product,
    required this.accent,
    required this.accentSoft,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Product product;
  final Color accent;
  final Color accentSoft;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  String _formatPrice(double value) {
    // Simple formatting for production-ready output.
    return '\$${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shadowColor: _tint(Colors.black, 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: _tint(accent, 0.14)),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: SizedBox(
                height: 320,
                width: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: accentSoft,
                          child: Center(
                            child: Icon(
                              product.imageIcon,
                              size: 36,
                              color: Colors.black38,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: accentSoft,
                          child: Center(
                            child: Icon(
                              product.imageIcon,
                              size: 36,
                              color: Colors.black38,
                            ),
                          ),
                        );
                      },
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      height: 46,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              _tint(Colors.black, 0.10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: Colors.black87,
                height: 1.1,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _formatPrice(product.price),
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.black54,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                _CartQuantityControl(
                  accent: accent,
                  quantity: quantity,
                  onIncrement: onIncrement,
                  onDecrement: onDecrement,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CartQuantityControl extends StatelessWidget {
  const _CartQuantityControl({
    required this.accent,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Color accent;
  final int quantity;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    if (quantity <= 0) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onIncrement,
          child: Container(
            height: 34,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: _tint(accent, 0.10),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _tint(accent, 0.32)),
              boxShadow: [
                BoxShadow(
                  color: _tint(Colors.black, 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '+ Add',
                  style: TextStyle(color: accent, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        color: _tint(accent, 0.08),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _tint(accent, 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _stepButton(
            icon: Icons.remove_rounded,
            color: accent,
            onTap: onDecrement,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '$quantity',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          _stepButton(
            icon: Icons.add_rounded,
            color: accent,
            onTap: onIncrement,
          ),
        ],
      ),
    );
  }

  Widget _stepButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

class _CartFloatingButton extends StatelessWidget {
  const _CartFloatingButton({
    required this.count,
    required this.accent,
    required this.onPressed,
  });

  final int count;
  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      heroTag: 'cartFab',
      onPressed: onPressed,
      backgroundColor: accent,
      foregroundColor: Colors.white,
      label: const Text('Cart'),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.shopping_cart_rounded),
          if (count > 0)
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: _tint(Colors.black, 0.15),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w900,
                    fontSize: 11,
                  ),
                ),
              ),
            ),
        ],
      ),
      elevation: 0,
    );
  }
}

class _CartSheet extends StatefulWidget {
  const _CartSheet({
    required this.cart,
    required this.products,
    required this.rawProducts,
    required this.accent,
    required this.accentSoft,
    required this.onIncrement,
    required this.onDecrement,
    required this.onClearAll,
    required this.onSubmit,
    required this.onCancel,
  });

  final Map<String, int> cart;
  final List<Product> products;
  final List<Map<String, dynamic>> rawProducts;
  final Color accent;
  final Color accentSoft;
  final void Function(Product) onIncrement;
  final void Function(Product) onDecrement;
  final VoidCallback onClearAll;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  @override
  State<_CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<_CartSheet> {
  late Map<String, int> _localCart;

  @override
  void initState() {
    super.initState();
    _localCart = Map<String, int>.from(widget.cart);
  }

  List<Product> get _cartItems {
    return _localCart.entries
        .where((e) => e.value > 0)
        .map((e) => widget.products.firstWhere((p) => p.id == e.key))
        .toList();
  }

  double get _total {
    return _cartItems.fold<double>(
      0,
      (sum, p) => sum + (p.price * (_localCart[p.id] ?? 0)),
    );
  }

  void _increment(Product product) {
    setState(() {
      _localCart.update(product.id, (v) => v + 1, ifAbsent: () => 1);
    });
    widget.onIncrement(product);
  }

  void _decrement(Product product) {
    setState(() {
      final current = _localCart[product.id] ?? 0;
      if (current <= 1) {
        _localCart.remove(product.id);
      } else {
        _localCart[product.id] = current - 1;
      }
    });
    widget.onDecrement(product);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your Order',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: Colors.black87,
                  ),
                ),
                Row(
                  children: [
                    if (_localCart.isNotEmpty)
                      IconButton(
                        onPressed: () {
                          widget.onClearAll();
                          setState(() => _localCart.clear());
                        },
                        icon: const Icon(Icons.delete_outline_rounded),
                        tooltip: 'Clear all',
                      ),
                    IconButton(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: _cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: Colors.black26,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.black45),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    itemCount: _cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final product = _cartItems[index];
                      final qty = _localCart[product.id] ?? 0;
                      return _CartItem(
                        product: product,
                        quantity: qty,
                        accent: widget.accent,
                        accentSoft: widget.accentSoft,
                        onIncrement: () => _increment(product),
                        onDecrement: () => _decrement(product),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      '\$${_total.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: widget.accent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _cartItems.isEmpty ? null : widget.onSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widget.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Submit Order',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: widget.onCancel,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        color: Colors.black54,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CartItem extends StatelessWidget {
  const _CartItem({
    required this.product,
    required this.quantity,
    required this.accent,
    required this.accentSoft,
    required this.onIncrement,
    required this.onDecrement,
  });

  final Product product;
  final int quantity;
  final Color accent;
  final Color accentSoft;
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  @override
  Widget build(BuildContext context) {
    final subtotal = product.price * quantity;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _tint(accent, 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _tint(accent, 0.12)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 60,
              height: 60,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: accentSoft,
                  child: Icon(product.imageIcon, color: accent, size: 28),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)} each',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Text(
                '\$${subtotal.toStringAsFixed(2)}',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: accent,
                ),
              ),
              const SizedBox(width: 8),
              _CartQuantityControl(
                accent: accent,
                quantity: quantity,
                onIncrement: onIncrement,
                onDecrement: onDecrement,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
