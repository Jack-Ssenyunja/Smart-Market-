import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../providers/prices_provider.dart';
import '../../themes/app_theme.dart';
import '../listings/listing_detail_screen.dart';
import '../listings/new_listing_screen.dart';
import '../advertise/advertise_screen.dart';
import '../auth/login_screen.dart';
import '../../widgets/listing_card.dart';
import '../../widgets/price_chip.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  void _loadData() {
    context.read<ListingsProvider>().loadListings();
    context.read<PricesProvider>().loadPrices();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final listings = context.watch<ListingsProvider>();
    final prices = context.watch<PricesProvider>();

    final featured = listings.listings.take(4).toList();
    final preferredProducts = auth.user?.preferredProducts ?? const <String>[];
    final highlights = prices.prices
        .where((price) => preferredProducts.isEmpty || preferredProducts.any((product) => price.product.toLowerCase() == product.toLowerCase()))
        .toList();
    final displayHighlights = highlights.isEmpty ? prices.prices.take(5).toList() : highlights.take(5).toList();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: RefreshIndicator(
        onRefresh: () async => _loadData(),
        child: CustomScrollView(
          slivers: [
            // App Bar
            SliverAppBar(
              expandedHeight: 80,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.primary,
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  color: AppTheme.primary,
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Hello, ${auth.user?.fullName.split(' ').first ?? 'Farmer'}! 👋',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600),
                            ),
                            const Text(
                              'Welcome to Smart Market Uganda',
                              style: TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          await context.read<AuthProvider>().signOut();
                          if (mounted) {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (_) => false,
                            );
                          }
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Icon(Icons.logout,
                              color: Colors.white, size: 18),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Search bar
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => context
                        .read<ListingsProvider>()
                        .loadListings(search: v.isEmpty ? null : v),
                    decoration: InputDecoration(
                      hintText: 'Search listings',
                      prefixIcon: const Icon(Icons.search,
                          size: 18, color: AppTheme.textSecondary),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () {
                                _searchCtrl.clear();
                                context
                                    .read<ListingsProvider>()
                                    .loadListings();
                              },
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Quick actions
                  if (auth.user?.isFarmer ?? false) ...[
                    Row(
                      children: [
                        _QuickAction(
                          icon: Icons.add_circle_outline,
                          label: 'Post Listing',
                          color: AppTheme.primary,
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const NewListingScreen())),
                        ),
                        const SizedBox(width: 12),
                        _QuickAction(
                          icon: Icons.campaign_outlined,
                          label: 'Advertise',
                          color: AppTheme.accent,
                          onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const AdvertiseScreen())),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Market highlights
                  if (displayHighlights.isNotEmpty) ...[
                    const Text('Market Highlights',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.black, // 👈 Sets the background color of the horizontal scroll area to black
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 8), // Optional: Adds a little breathing room inside the black box
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: displayHighlights
                              .map((p) => PriceChip(price: p))
                              .toList(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Featured listings
                  const Text('Recent Listings',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 10),
                  if (listings.isLoading)
                    const Center(
                        child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(
                          color: AppTheme.primary),
                    ))
                  else if (featured.isEmpty)
                    const _EmptyState(
                      icon: Icons.inventory_2_outlined,
                      message: 'No listings yet. Be the first to post!',
                    )
                  else
                    ...featured.map((l) => Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: ListingCard(
                            listing: l,
                            onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) =>
                                        ListingDetailScreen(listingId: l.id))),
                          ),
                        )),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              border: Border.all(color: color.withOpacity(0.3)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(label,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color)),
              ],
            ),
          ),
        ),
      );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(icon, size: 48, color: AppTheme.textSecondary.withOpacity(0.5)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 14, color: AppTheme.textSecondary)),
          ],
        ),
      );
}
