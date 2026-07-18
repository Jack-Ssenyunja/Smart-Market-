/// Curated wholesale/retail benchmark prices for major Ugandan markets.
/// Prices are indicative UGX values per unit and vary by market and district.
class MarketBenchmark {
  const MarketBenchmark({
    required this.product,
    required this.category,
    required this.market,
    required this.district,
    required this.price,
    required this.unit,
  });

  final String product;
  final String category;
  final String market;
  final String district;
  final double price;
  final String unit;
}

class UgandaMarketBenchmarks {
  UgandaMarketBenchmarks._();

  static const List<MarketBenchmark> all = [
    // Kampala — Owino Market
    MarketBenchmark(product: 'Maize', category: 'Grains', market: 'Owino Market', district: 'Kampala', price: 1300, unit: 'kg'),
    MarketBenchmark(product: 'Beans', category: 'Legumes', market: 'Owino Market', district: 'Kampala', price: 4200, unit: 'kg'),
    MarketBenchmark(product: 'Tomatoes', category: 'Vegetables', market: 'Owino Market', district: 'Kampala', price: 2800, unit: 'kg'),
    MarketBenchmark(product: 'Onions', category: 'Vegetables', market: 'Owino Market', district: 'Kampala', price: 3500, unit: 'kg'),
    MarketBenchmark(product: 'Matoke', category: 'Fruits', market: 'Owino Market', district: 'Kampala', price: 1200, unit: 'bunch'),
    MarketBenchmark(product: 'Cassava', category: 'Tubers', market: 'Owino Market', district: 'Kampala', price: 900, unit: 'kg'),
    MarketBenchmark(product: 'Groundnuts', category: 'Oilseeds', market: 'Owino Market', district: 'Kampala', price: 6500, unit: 'kg'),

    // Kampala — Nakasero Market (premium city centre)
    MarketBenchmark(product: 'Maize', category: 'Grains', market: 'Nakasero Market', district: 'Kampala', price: 1450, unit: 'kg'),
    MarketBenchmark(product: 'Beans', category: 'Legumes', market: 'Nakasero Market', district: 'Kampala', price: 4500, unit: 'kg'),
    MarketBenchmark(product: 'Irish Potatoes', category: 'Vegetables', market: 'Nakasero Market', district: 'Kampala', price: 2400, unit: 'kg'),
    MarketBenchmark(product: 'Sweet Potatoes', category: 'Tubers', market: 'Nakasero Market', district: 'Kampala', price: 1600, unit: 'kg'),
    MarketBenchmark(product: 'Cabbage', category: 'Vegetables', market: 'Nakasero Market', district: 'Kampala', price: 1900, unit: 'kg'),

    // Kampala — Kalerwe Market (wholesale)
    MarketBenchmark(product: 'Maize', category: 'Grains', market: 'Kalerwe Market', district: 'Kampala', price: 1180, unit: 'kg'),
    MarketBenchmark(product: 'Beans', category: 'Legumes', market: 'Kalerwe Market', district: 'Kampala', price: 3900, unit: 'kg'),
    MarketBenchmark(product: 'Cassava', category: 'Tubers', market: 'Kalerwe Market', district: 'Kampala', price: 850, unit: 'kg'),
    MarketBenchmark(product: 'Tomatoes', category: 'Vegetables', market: 'Kalerwe Market', district: 'Kampala', price: 2600, unit: 'kg'),
    MarketBenchmark(product: 'Onions', category: 'Vegetables', market: 'Kalerwe Market', district: 'Kampala', price: 3200, unit: 'kg'),

    // Mbale — Eastern grains & cash crops hub
    MarketBenchmark(product: 'Maize', category: 'Grains', market: 'Mbale Market', district: 'Mbale', price: 950, unit: 'kg'),
    MarketBenchmark(product: 'Coffee', category: 'Cash Crops', market: 'Mbale Market', district: 'Mbale', price: 6200, unit: 'kg'),
    MarketBenchmark(product: 'Beans', category: 'Legumes', market: 'Mbale Market', district: 'Mbale', price: 3200, unit: 'kg'),
    MarketBenchmark(product: 'Simsim', category: 'Oilseeds', market: 'Mbale Market', district: 'Mbale', price: 5800, unit: 'kg'),
    MarketBenchmark(product: 'Tomatoes', category: 'Vegetables', market: 'Mbale Market', district: 'Mbale', price: 2000, unit: 'kg'),

    // Gulu — Northern oilseeds & sorghum
    MarketBenchmark(product: 'Maize', category: 'Grains', market: 'Gulu Market', district: 'Gulu', price: 880, unit: 'kg'),
    MarketBenchmark(product: 'Sorghum', category: 'Grains', market: 'Gulu Market', district: 'Gulu', price: 1100, unit: 'kg'),
    MarketBenchmark(product: 'Groundnuts', category: 'Oilseeds', market: 'Gulu Market', district: 'Gulu', price: 5200, unit: 'kg'),
    MarketBenchmark(product: 'Simsim', category: 'Oilseeds', market: 'Gulu Market', district: 'Gulu', price: 5400, unit: 'kg'),
    MarketBenchmark(product: 'Beans', category: 'Legumes', market: 'Gulu Market', district: 'Gulu', price: 3000, unit: 'kg'),

    // Mbarara — South-west dairy & banana belt
    MarketBenchmark(product: 'Matoke', category: 'Fruits', market: 'Mbarara Market', district: 'Mbarara', price: 700, unit: 'bunch'),
    MarketBenchmark(product: 'Milk', category: 'Dairy', market: 'Mbarara Market', district: 'Mbarara', price: 1800, unit: 'litre'),
    MarketBenchmark(product: 'Beans', category: 'Legumes', market: 'Mbarara Market', district: 'Mbarara', price: 3500, unit: 'kg'),
    MarketBenchmark(product: 'Maize', category: 'Grains', market: 'Mbarara Market', district: 'Mbarara', price: 920, unit: 'kg'),
    MarketBenchmark(product: 'Irish Potatoes', category: 'Vegetables', market: 'Mbarara Market', district: 'Mbarara', price: 1900, unit: 'kg'),

    // Masaka — Coffee & banana belt
    MarketBenchmark(product: 'Coffee', category: 'Cash Crops', market: 'Masaka Market', district: 'Masaka', price: 5800, unit: 'kg'),
    MarketBenchmark(product: 'Matoke', category: 'Fruits', market: 'Masaka Market', district: 'Masaka', price: 650, unit: 'bunch'),
    MarketBenchmark(product: 'Maize', category: 'Grains', market: 'Masaka Market', district: 'Masaka', price: 850, unit: 'kg'),
    MarketBenchmark(product: 'Beans', category: 'Legumes', market: 'Masaka Market', district: 'Masaka', price: 3100, unit: 'kg'),
    MarketBenchmark(product: 'Sweet Bananas', category: 'Fruits', market: 'Masaka Market', district: 'Masaka', price: 800, unit: 'bunch'),

    // Jinja — Nile Basin fish & produce
    MarketBenchmark(product: 'Tilapia', category: 'Fish', market: 'Jinja Market', district: 'Jinja', price: 8500, unit: 'kg'),
    MarketBenchmark(product: 'Maize', category: 'Grains', market: 'Jinja Market', district: 'Jinja', price: 980, unit: 'kg'),
    MarketBenchmark(product: 'Tomatoes', category: 'Vegetables', market: 'Jinja Market', district: 'Jinja', price: 2200, unit: 'kg'),
    MarketBenchmark(product: 'Beans', category: 'Legumes', market: 'Jinja Market', district: 'Jinja', price: 3300, unit: 'kg'),
    MarketBenchmark(product: 'Cassava', category: 'Tubers', market: 'Jinja Market', district: 'Jinja', price: 820, unit: 'kg'),

    // Lira — Acholi oilseeds & sorghum
    MarketBenchmark(product: 'Maize', category: 'Grains', market: 'Lira Market', district: 'Lira', price: 860, unit: 'kg'),
    MarketBenchmark(product: 'Sorghum', category: 'Grains', market: 'Lira Market', district: 'Lira', price: 1050, unit: 'kg'),
    MarketBenchmark(product: 'Sunflower Seeds', category: 'Oilseeds', market: 'Lira Market', district: 'Lira', price: 4500, unit: 'kg'),
    MarketBenchmark(product: 'Beans', category: 'Legumes', market: 'Lira Market', district: 'Lira', price: 2900, unit: 'kg'),
    MarketBenchmark(product: 'Groundnuts', category: 'Oilseeds', market: 'Lira Market', district: 'Lira', price: 4800, unit: 'kg'),

    // Fort Portal — Tea & highland produce
    MarketBenchmark(product: 'Irish Potatoes', category: 'Vegetables', market: 'Fort Portal Market', district: 'Kabarole', price: 2100, unit: 'kg'),
    MarketBenchmark(product: 'Tea', category: 'Cash Crops', market: 'Fort Portal Market', district: 'Kabarole', price: 4500, unit: 'kg'),
    MarketBenchmark(product: 'Maize', category: 'Grains', market: 'Fort Portal Market', district: 'Kabarole', price: 1000, unit: 'kg'),
    MarketBenchmark(product: 'Beans', category: 'Legumes', market: 'Fort Portal Market', district: 'Kabarole', price: 3400, unit: 'kg'),
    MarketBenchmark(product: 'Tomatoes', category: 'Vegetables', market: 'Fort Portal Market', district: 'Kabarole', price: 2400, unit: 'kg'),

    // Arua — West Nile cross-border
    MarketBenchmark(product: 'Maize', category: 'Grains', market: 'Arua Market', district: 'Arua', price: 820, unit: 'kg'),
    MarketBenchmark(product: 'Cassava', category: 'Tubers', market: 'Arua Market', district: 'Arua', price: 750, unit: 'kg'),
    MarketBenchmark(product: 'Beans', category: 'Legumes', market: 'Arua Market', district: 'Arua', price: 2800, unit: 'kg'),
    MarketBenchmark(product: 'Groundnuts', category: 'Oilseeds', market: 'Arua Market', district: 'Arua', price: 4600, unit: 'kg'),
    MarketBenchmark(product: 'Simsim', category: 'Oilseeds', market: 'Arua Market', district: 'Arua', price: 5100, unit: 'kg'),
  ];
}
