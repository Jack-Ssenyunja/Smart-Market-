import '../data/uganda_market_benchmarks.dart';
import '../models/models.dart';

/// Provides location- and market-specific benchmark prices for Uganda.
/// Used as the primary data source for the Prices and Trends screens.
class MarketDataService {
  static const _historyWeeks = 12;

  List<MarketPrice> getCurrentPrices({
    String? market,
    String? district,
    String? category,
    String? search,
  }) {
    final now = DateTime.now();
    var results = UgandaMarketBenchmarks.all.where((b) {
      if (market != null && market.isNotEmpty && b.market != market) {
        return false;
      }
      if (district != null && district.isNotEmpty && b.district != district) {
        return false;
      }
      if (category != null && category.isNotEmpty && b.category != category) {
        return false;
      }
      return true;
    }).map((b) {
      return MarketPrice(
        id: _recordId(b),
        product: b.product,
        marketName: b.market,
        district: b.district,
        price: b.price,
        unit: b.unit,
        category: b.category,
        lastUpdated: now,
      );
    }).toList();

    if (search != null && search.isNotEmpty) {
      final q = search.toLowerCase();
      results = results
          .where((p) => p.product.toLowerCase().contains(q))
          .toList();
    }

    results.sort((a, b) {
      final marketCmp = a.marketName.compareTo(b.marketName);
      if (marketCmp != 0) return marketCmp;
      return a.product.compareTo(b.product);
    });

    return results;
  }

  List<String> getProducts({String? market, String? district}) {
    final products = getCurrentPrices(market: market, district: district)
        .map((p) => p.product)
        .toSet()
        .toList()
      ..sort();
    return products;
  }

  List<PriceHistory> getPriceHistory(
    String product, {
    String? market,
    String? district,
  }) {
    final benchmarks = UgandaMarketBenchmarks.all.where((b) {
      if (b.product != product) return false;
      if (market != null && market.isNotEmpty && b.market != market) {
        return false;
      }
      if (district != null && district.isNotEmpty && b.district != district) {
        return false;
      }
      return true;
    }).toList();

    if (benchmarks.isEmpty) return [];

    // When no market is selected but multiple markets carry the product,
    // show the first matching market's history.
    final benchmark = benchmarks.first;
    final now = DateTime.now();
    final history = <PriceHistory>[];

    for (var week = _historyWeeks; week >= 0; week--) {
      final recordedAt = now.subtract(Duration(days: week * 7));
      final seasonal = _seasonalFactor(benchmark.product, recordedAt);
      final marketNoise = _deterministicNoise(
        '${benchmark.product}|${benchmark.market}|$week',
      );
      final price = (benchmark.price * seasonal * marketNoise)
          .roundToDouble()
          .clamp(benchmark.price * 0.75, benchmark.price * 1.35);

      history.add(PriceHistory(
        id: '${_recordId(benchmark)}_$week',
        product: benchmark.product,
        marketName: benchmark.market,
        district: benchmark.district,
        price: price,
        unit: benchmark.unit,
        recordedAt: recordedAt,
      ));
    }

    return history;
  }

  /// Markets available for a given district (empty district = all markets).
  List<String> getMarketsForDistrict(String district) {
    if (district.isEmpty) {
      return UgandaMarketBenchmarks.all
          .map((b) => b.market)
          .toSet()
          .toList()
        ..sort();
    }
    return UgandaMarketBenchmarks.all
        .where((b) => b.district == district)
        .map((b) => b.market)
        .toSet()
        .toList()
      ..sort();
  }

  /// Districts that have benchmark data.
  List<String> getDistrictsWithData() {
    return UgandaMarketBenchmarks.all
        .map((b) => b.district)
        .toSet()
        .toList()
      ..sort();
  }

  String _recordId(MarketBenchmark b) =>
      '${b.market}_${b.product}'.replaceAll(' ', '_').toLowerCase();

  /// Simulates harvest-season dips and off-season peaks.
  double _seasonalFactor(String product, DateTime date) {
    const grainProducts = {'Maize', 'Sorghum', 'Rice', 'Sunflower Seeds'};
    const harvestMonths = {7, 8, 9, 10, 11, 12}; // Jul–Dec harvest in Uganda

    if (grainProducts.contains(product)) {
      return harvestMonths.contains(date.month) ? 0.88 : 1.08;
    }
    if (product == 'Tomatoes' || product == 'Onions') {
      // Dry season (Dec–Feb) pushes vegetable prices up
      return {12, 1, 2}.contains(date.month) ? 1.12 : 0.95;
    }
    return 1.0;
  }

  /// Deterministic ±8% variation so trends look realistic but stay stable.
  double _deterministicNoise(String key) {
    var hash = 0;
    for (final codeUnit in key.codeUnits) {
      hash = (hash * 31 + codeUnit) & 0x7FFFFFFF;
    }
    final normalized = (hash % 1000) / 1000.0; // 0.0 – 1.0
    return 0.92 + normalized * 0.16;
  }
}
