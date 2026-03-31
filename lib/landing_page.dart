import 'dart:ui';

import 'package:flutter/material.dart';

import 'menu_page.dart';

Color _tint(Color color, double opacity) {
  final alpha = (color.a * opacity).clamp(0.0, 1.0);
  return color.withValues(alpha: alpha);
}

class LandingPage extends StatelessWidget {
  final Map<String, dynamic>? currentUser;
  final void Function(String phone) onLogin;
  final void Function(String phone) onRegister;
  final VoidCallback onViewOrders;
  final VoidCallback onLogout;

  const LandingPage({
    super.key,
    this.currentUser,
    required this.onLogin,
    required this.onRegister,
    required this.onViewOrders,
    required this.onLogout,
  });

  static const Color _accent = Color(0xFF2F6B4F);
  static const Color _accentSoft = Color(0xFFE7F4EC);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(left: 19),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _accentSoft,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.local_cafe_rounded, color: _accent, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                'Brew',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (currentUser != null) ...[
            TextButton.icon(
              onPressed: onViewOrders,
              icon: Icon(Icons.receipt_long, color: _accent, size: 20),
              label: Text(
                'My Orders',
                style: TextStyle(color: _accent, fontWeight: FontWeight.w700),
              ),
            ),
            // IconButton(
            //   onPressed: onLogout,
            //   icon: Icon(Icons.logout_rounded, color: Colors.red, size: 22),
            //   tooltip: 'Logout',
            // ),
            PopupMenuButton<String>(
              offset: const Offset(0, 40),
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: _accentSoft,
                  child: Text(
                    (currentUser!['name'] ?? 'U')[0].toString().toUpperCase(),
                    style: TextStyle(
                      color: _accent,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
              onSelected: (value) {
                if (value == 'orders') {
                  onViewOrders();
                } else if (value == 'logout') {
                  onLogout();
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'orders',
                  child: Row(
                    children: [
                      Icon(Icons.receipt_long, color: _accent, size: 20),
                      const SizedBox(width: 12),
                      // const Text('My Orders'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      const Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            TextButton(
              onPressed: () => onLogin(''),
              child: Text(
                'Login',
                style: TextStyle(color: _accent, fontWeight: FontWeight.w700),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ElevatedButton(
                onPressed: () => onRegister(''),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                child: const Text('Register'),
              ),
            ),
          ],
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= 800;
            final horizontalPadding = isWide ? 28.0 : 18.0;

            final featureCrossAxisCount = constraints.maxWidth >= 1000 ? 3 : 1;
            final drinksCrossAxisCount = constraints.maxWidth >= 900
                ? 3
                : (constraints.maxWidth >= 600 ? 2 : 1);

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: isWide ? 22 : 14,
                    ),
                    child: _HeroSection(
                      accent: _accent,
                      backgroundSoft: _accentSoft,
                      currentUser: currentUser,
                      onLogin: onLogin,
                      onRegister: onRegister,
                      onViewOrders: onViewOrders,
                      onLogout: onLogout,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 22)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: _SectionTitle(
                      title: 'Built for quick coffee runs',
                      subtitle: 'Fast, fresh, and effortless every time.',
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: featureCrossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 2.4,
                    ),
                    delegate: SliverChildListDelegate([
                      FeatureCard(
                        icon: Icons.flash_on_rounded,
                        title: 'Fast Ordering',
                        description:
                            'Place an order in seconds with a smooth, guided flow.',
                        accent: _accent,
                      ),
                      FeatureCard(
                        icon: Icons.local_florist_rounded,
                        title: 'Fresh Coffee',
                        description:
                            'Brewed to order for better taste and that just-made aroma.',
                        accent: _accent,
                      ),
                      FeatureCard(
                        icon: Icons.payment_rounded,
                        title: 'Easy Payment',
                        description:
                            'Pay securely in seconds. No hassle, no waiting.',
                        accent: _accent,
                      ),
                    ]),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 20)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: _SectionTitle(
                      title: 'Popular drinks',
                      subtitle: 'A few crowd favorites to start your order.',
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 12)),

                SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: drinksCrossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 3,
                    ),
                    delegate: SliverChildListDelegate([
                      DrinkCard(
                        name: 'Cappuccino',
                        icon: Icons.spa_rounded,
                        accent: _accent,
                        accentSoft: _accentSoft,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Selected: Cappuccino'),
                            ),
                          );
                        },
                      ),
                      DrinkCard(
                        name: 'Latte',
                        icon: Icons.local_cafe_rounded,
                        accent: _accent,
                        accentSoft: _accentSoft,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Selected: Latte')),
                          );
                        },
                      ),
                      DrinkCard(
                        name: 'Espresso',
                        icon: Icons.whatshot_rounded,
                        accent: _accent,
                        accentSoft: _accentSoft,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Selected: Espresso')),
                          );
                        },
                      ),
                    ]),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 18)),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                    ),
                    child: _BottomCta(
                      accent: _accent,
                      label: 'Browse Menu',
                      currentUser: currentUser,
                      onLogin: onLogin,
                      onRegister: onRegister,
                      onViewOrders: onViewOrders,
                      onLogout: onLogout,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 8)),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.accent,
    required this.backgroundSoft,
    required this.currentUser,
    required this.onLogin,
    required this.onRegister,
    required this.onViewOrders,
    required this.onLogout,
  });

  final Color accent;
  final Color backgroundSoft;
  final Map<String, dynamic>? currentUser;
  final void Function(String phone) onLogin;
  final void Function(String phone) onRegister;
  final VoidCallback onViewOrders;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final primary = accent;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 420;
        final horizontalPadding = isCompact ? 16.0 : 20.0;
        final verticalPadding = isCompact ? 18.0 : 22.0;
        final headlineSize = isCompact ? 30.0 : 38.0;

        return ClipRRect(
          borderRadius: BorderRadius.circular(26),
          child: Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        _tint(primary, 0.12),
                        _tint(primary, 0.05),
                        Colors.white,
                      ],
                    ),
                  ),
                ),
              ),

              // Blobs (primary glow)
              Positioned(
                top: -55,
                left: -40,
                child: _BlurBlob(color: _tint(primary, 0.18), size: 160),
              ),
              Positioned(
                bottom: -70,
                right: -70,
                child: _BlurBlob(color: _tint(primary, 0.14), size: 220),
              ),

              // Depth overlay
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, _tint(primary, 0.03)],
                    ),
                  ),
                ),
              ),

              // Icon decoration
              Positioned(
                top: 8,
                right: 10,
                child: Opacity(
                  opacity: 0.18,
                  child: Icon(
                    Icons.local_cafe_rounded,
                    size: isCompact ? 74 : 90,
                    color: primary,
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Fresh Coffee, Just a Tap Away',
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontSize: headlineSize,
                        fontWeight: FontWeight.w900,
                        height: 1.02,
                        letterSpacing: -0.4,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Order your favorite coffee quickly and easily',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.black54,
                        fontSize: isCompact ? 15.5 : 16,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 18),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MenuPage(
                                currentUser: currentUser,
                                onLogin: (p) => onLogin(p),
                                onRegister: (p) => onRegister(p),
                                onViewOrders: onViewOrders,
                                onLogout: onLogout,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                          elevation: 6,
                          shadowColor: _tint(primary, 0.25),
                        ),
                        child: const Text(
                          'Start Ordering',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                    Container(
                      height: 8,
                      width: 92,
                      decoration: BoxDecoration(
                        color: _tint(primary, 0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _BlurBlob extends StatelessWidget {
  const _BlurBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: SizedBox(
        width: size,
        height: size,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: DecoratedBox(
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}

class _BeansIllustration extends StatelessWidget {
  const _BeansIllustration({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    // Simple "coffee beans" made of rounded ovals (no assets needed).
    return SizedBox(
      width: 110,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 24,
            top: 8,
            child: _Bean(color: color, rotation: -0.35, w: 18, h: 10),
          ),
          Positioned(
            left: 48,
            top: 4,
            child: _Bean(color: color, rotation: 0.25, w: 20, h: 11),
          ),
          Positioned(
            left: 12,
            top: 22,
            child: _Bean(color: color, rotation: 0.15, w: 16, h: 9),
          ),
          Positioned(
            left: 46,
            top: 24,
            child: _Bean(color: color, rotation: -0.10, w: 18, h: 10),
          ),
          Positioned(
            left: 70,
            top: 20,
            child: _Bean(color: color, rotation: 0.38, w: 17, h: 10),
          ),
        ],
      ),
    );
  }
}

class _Bean extends StatelessWidget {
  const _Bean({
    required this.color,
    required this.rotation,
    required this.w,
    required this.h,
  });

  final Color color;
  final double rotation;
  final double w;
  final double h;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: rotation,
      child: Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          subtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.black54),
        ),
      ],
    );
  }
}

class _BottomCta extends StatelessWidget {
  const _BottomCta({
    required this.accent,
    required this.label,
    required this.currentUser,
    required this.onLogin,
    required this.onRegister,
    required this.onViewOrders,
    required this.onLogout,
  });

  final Color accent;
  final String label;
  final Map<String, dynamic>? currentUser;
  final void Function(String phone) onLogin;
  final void Function(String phone) onRegister;
  final VoidCallback onViewOrders;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _tint(accent, 0.06),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: _tint(Colors.black, 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Ready when you are.',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => MenuPage(
                    currentUser: currentUser,
                    onLogin: (p) => onLogin(p),
                    onRegister: (p) => onRegister(p),
                    onViewOrders: onViewOrders,
                    onLogout: onLogout,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureCard extends StatelessWidget {
  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.accent,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _tint(Colors.black, 0.06),
            blurRadius: 16,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: _tint(accent, 0.12), width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ICON (LEFT)
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: _tint(accent, 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accent, size: 22),
          ),

          const SizedBox(width: 12),

          // TEXT (RIGHT)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                    height: 1.3,
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

class DrinkCard extends StatelessWidget {
  const DrinkCard({
    super.key,
    required this.name,
    required this.icon,
    required this.accent,
    required this.accentSoft,
    required this.onTap,
  });

  final String name;
  final IconData icon;
  final Color accent;
  final Color accentSoft;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: _tint(Colors.black, 0.06),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
          border: Border.all(color: _tint(accent, 0.10), width: 1),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: accentSoft,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: accent, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to preview',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: Colors.black54),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}
