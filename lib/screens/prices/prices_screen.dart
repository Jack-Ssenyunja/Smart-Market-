import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/prices_provider.dart';
import '../../themes/app_theme.dart';
import '../../utils/formatters.dart';
import '../../constants/app_constants.dart';

class PricesScreen extends StatefulWidget {
  const PricesScreen({super.key});
  @override
  State<PricesScreen> createState() => _PricesScreenState();
}

class _PricesScreenState extends State<PricesScreen>
    with AutomaticKeepAliveClientMixin {
  final _searchCtrl = TextEditingController();
  String _selectedMarket = '';
  String _selectedCategory = '';

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  void _load() {
    context.read<PricesProvider>().loadPrices(
          market: _selectedMarket.isEmpty ? null : _selectedMarket,
          category:
              _selectedCategory.isEmpty ? null : _selectedCategory,
          search:
              _searchCtrl.text.isEmpty ? null : _searchCtrl.text,
        );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final pp = context.watch<PricesProvider>();
    final grouped = pp.pricesByMarket;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      appBar: AppBar(title: const Text('Market Prices')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Column(
              children: [
                TextField(
                  controller: _searchCtrl,
                  onChanged: (_) => _load(),
                  decoration: const InputDecoration(
                    hintText: 'Search commodity...',
                    prefixIcon: Icon(Icons.search,
                        size: 18, color: AppTheme.textSecondary),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(
                          label: 'All Markets',
                          selected: _selectedMarket.isEmpty,
                          onTap: () =>
                              setState(() => _selectedMarket = '')),
                      ...AppConstants.markets.map((m) => _FilterChip(
                            label: m.replaceAll(' Market', ''),
                            selected: _selectedMarket == m,
                            onTap: () =>
                                setState(() => _selectedMarket = m),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: pp.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: AppTheme.primary))
                : grouped.isEmpty
                    ? const Center(
                        child: Text('No prices available.',
                            style: TextStyle(
                                color: AppTheme.textSecondary)))
                    : RefreshIndicator(
                        onRefresh: () async => _load(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: grouped.length,
                          itemBuilder: (_, i) {
                            final market =
                                grouped.keys.elementAt(i);
                            final items = grouped[market]!;
                            return _MarketPriceSection(
                                market: market, prices: items);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

class _MarketPriceSection extends StatelessWidget {
  const _MarketPriceSection(
      {required this.market, required this.prices});
  final String market;
  final prices;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8, top: 8),
            child: Row(
              children: [
                const Icon(Icons.storefront,
                    size: 16, color: AppTheme.primary),
                const SizedBox(width: 6),
                Text(market,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 0, 0, 0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: prices.asMap().entries.map<Widget>((e) {
                final idx = e.key as int;
                final p = e.value;
                return Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 12),
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
                            Text(p.product,
                                style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                            Text(p.category,
                                style: const TextStyle(
                                    fontSize: 11,
                                    color: AppTheme.textSecondary)),
                          ],
                        ),
                      ),
                      Text(
                        '${formatUGX(p.price)} / ${p.unit}',
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
          ),
          const SizedBox(height: 16),
        ],
      );
}

class _FilterChip extends StatelessWidget {
  const _FilterChip(
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
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? AppTheme.primary : const Color.fromARGB(255, 0, 0, 0),
              border: Border.all(
                  color: selected
                      ? AppTheme.primary
                      : AppTheme.border),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(label,
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? Colors.white
                        : const Color.fromARGB(255, 255, 255, 255))),
          ),
        ),
      );
}
