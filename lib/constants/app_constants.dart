// App-wide constants for Smart Market

class AppConstants {
  static const String appName = 'Smart Market';

  static const List<String> ugandaDistricts = [
    'Kampala', 'Wakiso', 'Mukono', 'Jinja', 'Mbale', 'Gulu', 'Mbarara',
    'Masaka', 'Lira', 'Arua', 'Fort Portal', 'Kasese', 'Kabale', 'Soroti',
    'Tororo', 'Hoima', 'Masindi', 'Iganga', 'Busia', 'Bundibugyo',
  ];

  static const List<String> productCategories = [
    'Grains', 'Legumes', 'Vegetables', 'Fruits', 'Tubers',
    'Cash Crops', 'Oilseeds', 'Dairy', 'Fish', 'Poultry', 'Other',
  ];

  static const List<String> marketProducts = [
    'Maize', 'Beans', 'Tomatoes', 'Onions', 'Matoke', 'Cassava',
    'Groundnuts', 'Irish Potatoes', 'Sweet Potatoes', 'Coffee',
    'Sorghum', 'Simsim', 'Milk', 'Tilapia', 'Tea', 'Cabbage',
    'Sweet Bananas', 'Sunflower Seeds', 'Groundnuts', 'Rice'
  ];

  static const List<String> units = [
    'kg', 'tonne', 'bag (100kg)', 'litre', 'bunch', 'crate', 'bundle', 'piece',
  ];

  static const List<String> markets = [
    'Owino Market', 'Nakasero Market', 'Mbale Market', 'Gulu Market',
    'Mbarara Market', 'Masaka Market', 'Jinja Market', 'Lira Market',
    'Fort Portal Market', 'Arua Market', 'Kalerwe Market',
  ];

  static const List<Map<String, String>> marketsInfo = [
    {'name': 'Owino Market', 'district': 'Kampala', 'desc': 'Largest open-air market in East Africa.'},
    {'name': 'Nakasero Market', 'district': 'Kampala', 'desc': 'Premium fresh produce in the city centre.'},
    {'name': 'Mbale Market', 'district': 'Mbale', 'desc': 'Eastern Uganda hub for grains & cash crops.'},
    {'name': 'Gulu Market', 'district': 'Gulu', 'desc': 'Northern Uganda centre for simsim & groundnuts.'},
    {'name': 'Mbarara Market', 'district': 'Mbarara', 'desc': 'South-west dairy & banana hub.'},
    {'name': 'Masaka Market', 'district': 'Masaka', 'desc': 'Coffee and banana belt trading post.'},
    {'name': 'Jinja Market', 'district': 'Jinja', 'desc': 'Nile Basin fish and sugarcane market.'},
    {'name': 'Lira Market', 'district': 'Lira', 'desc': 'Acholi oilseeds and sorghum exchange.'},
    {'name': 'Fort Portal Market', 'district': 'Kabarole', 'desc': 'Tea & Irish potato highland market.'},
    {'name': 'Arua Market', 'district': 'Arua', 'desc': 'West Nile cross-border commodities market.'},
    {'name': 'Kalerwe Market', 'district': 'Kampala', 'desc': 'Kampala suburban wholesale market.'},
  ];

  // Firestore collection names
  static const String usersCollection = 'users';
  static const String listingsCollection = 'listings';
  static const String marketPricesCollection = 'market_prices';
  static const String priceHistoryCollection = 'price_history';
  static const String advertisementsCollection = 'advertisements';

  // Firebase Storage buckets
  static const String listingImagesBucket = 'listing_images';
  static const String profileImagesBucket = 'profile_images';
  static const String advertisementsBucket = 'advertisements';
}
