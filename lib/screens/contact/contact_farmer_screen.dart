import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/listings_provider.dart';
import '../../themes/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactFarmerScreen extends StatefulWidget {
  const ContactFarmerScreen({super.key, required this.listingId});
  final String listingId;
  @override
  State<ContactFarmerScreen> createState() => _ContactFarmerScreenState();
}

class _ContactFarmerScreenState extends State<ContactFarmerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ListingsProvider>().loadListingById(widget.listingId);
    });
  }

  Future<void> _launch(Uri uri) async {
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<ListingsProvider>();
    final listing = lp.selectedListing;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Contact Seller')),
      body: lp.isLoading || listing == null
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primary))
          : SafeArea(
              child: SingleChildScrollView( // <-- 1. Add SingleChildScrollView here
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // Changed to stretch for consistent button sizing
                    children: [
                      // Farmer info card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.border),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(Icons.person,
                                  color: AppTheme.primary, size: 28),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(listing.farmerName,
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 2),
                                  Text(listing.farmerDistrict,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary)),
                                  const SizedBox(height: 2),
                                  Text(listing.contactNumber,
                                      style: const TextStyle(
                                          fontSize: 13,
                                          color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.inventory_2_outlined,
                                size: 16, color: AppTheme.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${listing.productName} — ${listing.quantity} ${listing.unit}',
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primary),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24), // Reduced slightly to balance layout on small devices
                      const Text('Contact via',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 16),

                      _ContactButton(
                        icon: Icons.call_outlined,
                        label: 'Call',
                        subtitle: listing.contactNumber,
                        color: AppTheme.primary,
                        onTap: () => _launch(
                            Uri.parse('tel:${listing.contactNumber}')),
                      ),
                      const SizedBox(height: 12),
                      _ContactButton(
                        icon: Icons.sms_outlined,
                        label: 'SMS',
                        subtitle: listing.contactNumber,
                        color: const Color(0xFF0284C7),
                        onTap: () => _launch(
                            Uri.parse('sms:${listing.contactNumber}')),
                      ),
                      const SizedBox(height: 12),
                      _ContactButton(
                        icon: Icons.chat_outlined,
                        label: 'WhatsApp',
                        subtitle: 'Open WhatsApp chat',
                        color: const Color(0xFF25D366),
                        onTap: () {
                          final phone = listing.contactNumber
                              .replaceAll(RegExp(r'[^\d+]'), '');
                          final msg = Uri.encodeComponent(
                              "Hello, I'm interested in your ${listing.productName} listing on Smart Market.");
                          _launch(Uri.parse(
                              'https://wa.me/$phone?text=$msg'));
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: AppTheme.textSecondary, size: 18),
            ],
          ),
        ),
      );
}