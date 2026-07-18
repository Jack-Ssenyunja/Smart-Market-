import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../themes/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../widgets/listing_card.dart';
import 'listing_detail_screen.dart';
import 'new_listing_screen.dart';

class ListingsScreen extends StatefulWidget {
  const ListingsScreen({super.key});
  @override
  State<ListingsScreen> createState() => _ListingsScreenState();
}

class _ListingsScreenState extends State<ListingsScreen>
    with AutomaticKeepAliveClientMixin {
  final _searchCtrl = TextEditingController();
  String _selectedCategory = '';
  String _selectedDistrict = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    final auth = context.read<AuthProvider>();
    final provider = context.read<ListingsProvider>();
    if (auth.user?.isFarmer ?? false) {
      provider.loadMyListings(auth.user!.uid);
    } else {
      provider.loadListings(
        category: _selectedCategory.isEmpty ? null : _selectedCategory,
        district: _selectedDistrict.isEmpty ? null : _selectedDistrict,
        search: _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
      );
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final auth = context.watch<AuthProvider>();
    final lp = context.watch<ListingsProvider>();
    final isFarmer = auth.user?.isFarmer ?? false;
    final items = isFarmer ? lp.myListings : lp.listings;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(
        title: Text(isFarmer ? 'My Listings' : 'Browse Listings'),
        actions: isFarmer
            ? [
                IconButton(
                  icon: const Icon(Icons.add, color: Color.fromARGB(255, 255, 255, 255)),
                  onPressed: () => Navigator.of(context)
                      .push(MaterialPageRoute(
                          builder: (_) => const NewListingScreen()))
                      .then((_) => _load()),
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          // Search + filters (buyer only)
          if (!isFarmer)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                children: [
                  TextField(
                    controller: _searchCtrl,
                    onChanged: (_) => _load(),
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search,
                          size: 18, color: AppTheme.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChipWidget(
                          label: 'All',
                          selected: _selectedCategory.isEmpty,
                          onTap: () =>
                              setState(() => _selectedCategory = ''),
                        ),
                        ...AppConstants.productCategories
                            .map((c) => _FilterChipWidget(
                                  label: c,
                                  selected: _selectedCategory == c,
                                  onTap: () => setState(
                                      () => _selectedCategory = c),
                                )),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: lp.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppTheme.primary))
                : items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inventory_2_outlined,
                                size: 56,
                                color: AppTheme.textSecondary),
                            const SizedBox(height: 12),
                            Text(
                                isFarmer
                                    ? 'You haven\'t posted any listings yet.'
                                    : 'No listings found.',
                                style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () async => _load(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: items.length,
                          itemBuilder: (_, i) {
                            final l = items[i];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: isFarmer
                                  ? _FarmerListingCard(
                                      listing: l,
                                      onTap: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (_) =>
                                                  ListingDetailScreen(
                                                      listingId: l.id))),
                                      onDelete: () async {
                                        await context
                                            .read<ListingsProvider>()
                                            .deleteListing(l.id);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(const SnackBar(
                                                content: Text(
                                                    'Listing deleted.')));
                                      },
                                    )
                                  : ListingCard(
                                      listing: l,
                                      onTap: () => Navigator.of(context)
                                          .push(MaterialPageRoute(
                                              builder: (_) =>
                                                  ListingDetailScreen(
                                                      listingId: l.id))),
                                    ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _FilterChipWidget extends StatelessWidget {
  const _FilterChipWidget(
      {required this.label,
      required this.selected,
      required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(right: 6),
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary : const Color.fromARGB(255, 0, 0, 0),
              border: Border.all(
                  color: selected ? AppTheme.primary : AppTheme.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? Colors.white
                        : const Color.fromARGB(255, 255, 255, 255))),
          ),
        ),
      );
}

class _FarmerListingCard extends StatelessWidget {
  const _FarmerListingCard(
      {required this.listing,
      required this.onTap,
      required this.onDelete});
  final listing;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ListingCard(listing: listing, onTap: onTap),
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Delete Listing'),
                  content: const Text(
                      'Are you sure you want to delete this listing?'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          onDelete();
                        },
                        child: const Text('Delete',
                            style:
                                TextStyle(color: AppTheme.destructive))),
                  ],
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.destructive.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline,
                  size: 16, color: AppTheme.destructive),
            ),
          ),
        ),
      ],
    );
  }
}
