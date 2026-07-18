import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../themes/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../providers/prices_provider.dart';
import '../../utils/formatters.dart';
import '../../models/models.dart';

class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  final _expandedMarkets = <String>{};
  final _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PricesProvider>().loadPrices();
    });
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _toggleMarket(String market) {
    setState(() {
      if (!_expandedMarkets.add(market)) {
        _expandedMarkets.remove(market);
      }
    });
  }

  void _handleSearch(String value) {
    _searchDebounce?.cancel();
    final query = value.trim();

    if (query.isEmpty) {
      context.read<PricesProvider>().loadPrices();
      return;
    }

    _searchDebounce = Timer(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      context.read<PricesProvider>().loadPrices(search: query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final pricesProvider = context.watch<PricesProvider>();
    final groupedPrices = pricesProvider.pricesByMarket;
    final isLoading = pricesProvider.isLoading;
    final searchQuery = _searchController.text.trim();
    final hasSearch = searchQuery.isNotEmpty;
    final comparisonPrices = hasSearch ? [...pricesProvider.prices] : <MarketPrice>[];

    if (comparisonPrices.isNotEmpty) {
      comparisonPrices.sort((a, b) => a.price.compareTo(b.price));
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(title: const Text('Markets')),
      body: RefreshIndicator(
        onRefresh: () async => context.read<PricesProvider>().loadPrices(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.primary),
                ),
              ),
            TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _handleSearch,
              onSubmitted: (value) {
                _searchDebounce?.cancel();
                final query = value.trim();
                context.read<PricesProvider>().loadPrices(search: query.isEmpty ? null : query);
              },
              decoration: InputDecoration(
                hintText: 'Search product to compare prices',
                prefixIcon: const Icon(Icons.search, size: 18, color: AppTheme.textSecondary),
                suffixIcon: searchQuery.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _handleSearch('');
                        },
                        icon: const Icon(Icons.clear, size: 18, color: AppTheme.textSecondary),
                      ),
                filled: true,
                fillColor: const Color.fromARGB(255, 10, 10, 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppTheme.primary),
                ),
              ),
            ),
            const SizedBox(height: 14),
            if (hasSearch)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withAlpha(18),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.primary.withAlpha(80)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price comparison',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Showing prices for "$searchQuery" across marketplaces.',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            if (hasSearch)
              if (comparisonPrices.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 10, 10, 10),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: const Text(
                    'No matching product prices found.',
                    style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                  ),
                )
              else
                ...comparisonPrices.map((price) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 10, 10, 10),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                price.marketName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                price.district.isEmpty ? 'District unavailable' : price.district,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${formatUGX(price.price)} / ${price.unit}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            if (!hasSearch)
              ...AppConstants.marketsInfo.map((m) {
                final name = m['name']!;
                final prices = groupedPrices[name] ?? [];
                final expanded = _expandedMarkets.contains(name);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _MarketCard(
                      name: name,
                      district: m['district']!,
                      description: m['desc']!,
                      expanded: expanded,
                      onTap: () => _toggleMarket(name),
                    ),
                    if (expanded) _MarketPriceDropdown(prices: prices),
                  ],
                );
              }),
          ],
        ),
      ),
    );
  }
}

class _MarketCard extends StatelessWidget {
  const _MarketCard({
    required this.name,
    required this.district,
    required this.description,
    required this.expanded,
    required this.onTap,
  });

  final String name;
  final String district;
  final String description;
  final bool expanded;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 0, 0, 0),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromARGB(255, 44, 104, 49)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.storefront,
                color: AppTheme.primary, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 12, color: AppTheme.textSecondary),
                    const SizedBox(width: 2),
                    Text(district,
                        style: const TextStyle(
                            fontSize: 12, color: AppTheme.textSecondary)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(description,
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            icon: Icon(
              expanded ? Icons.expand_less : Icons.chevron_right,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketPriceDropdown extends StatelessWidget {
  const _MarketPriceDropdown({required this.prices});
  final List<MarketPrice> prices;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 10, 10, 10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: prices.isEmpty
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text('No price data available for this market yet.',
                  style: TextStyle(
                      fontSize: 13, color: AppTheme.textSecondary)),
            )
          : Column(
              children: prices.asMap().entries.map((entry) {
                final idx = entry.key;
                final price = entry.value;
                return Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    border: idx < prices.length - 1
                        ? const Border(
                            bottom: BorderSide(color: AppTheme.border))
                        : null,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(price.product,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(height: 4),
                            Text(price.category,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      Text(
                        '${formatUGX(price.price)} / ${price.unit}',
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
    );
  }
}
