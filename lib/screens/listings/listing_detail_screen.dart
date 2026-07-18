import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../themes/app_theme.dart';
import '../../utils/formatters.dart';
import '../contact/contact_farmer_screen.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.listingId});
  final String listingId;
  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  int _imageIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingsProvider>().loadListingById(widget.listingId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<ListingsProvider>();
    final listing = lp.selectedListing;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(title: Text(listing?.productName ?? 'Loading...')),
      body: lp.isLoading || listing == null
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image gallery
                  if (listing.imageUrls.isNotEmpty) ...[
                    SizedBox(
                      height: 240,
                      child: Stack(
                        children: [
                          PageView.builder(
                            itemCount: listing.imageUrls.length,
                            onPageChanged: (i) =>
                                setState(() => _imageIndex = i),
                            itemBuilder: (_, i) => Image.network(
                              listing.imageUrls[i],
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, __, ___) => Container(
                                color: const Color.fromARGB(255, 0, 0, 0),
                                child: const Icon(Icons.image_outlined,
                                    size: 48,
                                    color: AppTheme.textSecondary),
                              ),
                            ),
                          ),
                          if (listing.imageUrls.length > 1)
                            Positioned(
                              bottom: 12,
                              left: 0,
                              right: 0,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: List.generate(
                                  listing.imageUrls.length,
                                  (i) => Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 3),
                                    width: _imageIndex == i ? 16 : 6,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: _imageIndex == i
                                          ? AppTheme.primary
                                          : Colors.white60,
                                      borderRadius:
                                          BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ] else
                    Container(
                      height: 200,
                      color: const Color.fromARGB(255, 0, 0, 0),
                      child: const Center(
                          child: Icon(Icons.image_outlined,
                              size: 56, color: Color.fromARGB(255, 207, 207, 207))),
                    ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(listing.productName,
                                  style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.w700)),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  formatUGX(listing.price),
                                  style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      color: AppTheme.primary),
                                ),
                                Text('per ${listing.unit}',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textSecondary)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            _InfoChip(
                                icon: Icons.category_outlined,
                                label: listing.category),
                            _InfoChip(
                                icon: Icons.inventory_outlined,
                                label:
                                    '${listing.quantity} ${listing.unit}'),
                            _InfoChip(
                                icon: Icons.storefront_outlined,
                                label: listing.market),
                            _InfoChip(
                                icon: Icons.location_on_outlined,
                                label: listing.district),
                          ],
                        ),

                        if (listing.description.isNotEmpty) ...[
                          const SizedBox(height: 20),
                          const Text('Description',
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(listing.description,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textSecondary,
                                  height: 1.5)),
                        ],

                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 12),

                        // Farmer info
                        const Text('Seller',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color:
                                    AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.person,
                                  color: AppTheme.primary, size: 22),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(listing.farmerName,
                                      style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600)),
                                  Text(listing.farmerDistrict,
                                      style: const TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),
                        Text(
                            'Posted ${relativeTime(listing.createdAt)}',
                            style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: listing != null
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.call_outlined, size: 18),
                  label: const Text('Contact Seller'),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) =>
                            ContactFarmerScreen(listingId: listing.id)),
                  ),
                ),
              ),
            )
          : null,
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppTheme.muted,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: AppTheme.textSecondary),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      );
}
