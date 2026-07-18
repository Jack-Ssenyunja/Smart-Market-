import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
// Automatically resolves the import path based on your folder structure
import '../prices/prices_screen.dart'; 
import '../../providers/prices_provider.dart';

class TrendsScreen extends StatefulWidget {
  const TrendsScreen({Key? key}) : super(key: key);

  @override
  State<TrendsScreen> createState() => _TrendsScreenState();
}

class _TrendsScreenState extends State<TrendsScreen> 
    with AutomaticKeepAliveClientMixin {
  
  @override
  bool get wantKeepAlive => true; // Caches tab state to prevent constant re-fetching

  @override
  void initState() {
    super.initState();
    // Safely trigger data fetching after the widget builds
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = Provider.of<PricesProvider>(context, listen: false);
      
      // 1. Load products list if empty
      if (provider.products.isEmpty) {
        await provider.loadProducts();
      }
      
      // 2. Load the history of the selected/first product
      if (provider.products.isNotEmpty) {
        final productToLoad = provider.selectedProduct.isNotEmpty 
            ? provider.selectedProduct 
            : provider.products.first;
        await provider.loadHistory(productToLoad);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final pp = Provider.of<PricesProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF000000), // Pure black background
      body: _buildBody(pp),
    );
  }

  Widget _buildBody(PricesProvider pp) {
    if (pp.isLoading && pp.history.isEmpty && pp.products.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
        ),
      );
    }

    if (pp.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "No products available to show trends.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => pp.loadProducts(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: const Text("Retry Loading Products"),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => pp.loadHistory(pp.selectedProduct),
      color: Colors.green,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Selector Dropdown
              const Text(
                "Select Product",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: pp.selectedProduct.isNotEmpty ? pp.selectedProduct : null,
                    dropdownColor: const Color(0xFF121212),
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                    icon: const Icon(Icons.keyboard_arrow_down, color: Colors.green),
                    isExpanded: true,
                    items: pp.products.map((String product) {
                      return DropdownMenuItem<String>(
                        value: product,
                        child: Text(product),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        pp.loadHistory(newValue);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                "Price Trend",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              
              // Chart Container
              Container(
                height: 250,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF121212), // Dark surface container
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: _buildChart(pp),
              ),
              
              const SizedBox(height: 24),
              const Text(
                "Recent Price Updates (UGX)",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // History List Container
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white10),
                ),
                child: _buildHistoryList(pp),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(PricesProvider pp) {
    if (pp.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.green),
      );
    }

    if (pp.history.length < 2) {
      return const Center(
        child: Text(
          "Need at least 2 historical updates to draw chart.",
          style: TextStyle(color: Colors.grey, fontSize: 14),
          textAlign: TextAlign.center,
        ),
      );
    }

    // Map history to spots
    List<FlSpot> spots = [];
    for (int i = 0; i < pp.history.length; i++) {
      spots.add(FlSpot(i.toDouble(), pp.history[i].price.toDouble()));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: Colors.white10,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(show: false), // Clean Minimal chart style
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: (spots.length - 1).toDouble(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.greenAccent,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.greenAccent.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(PricesProvider pp) {
    if (pp.isLoading && pp.history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(child: CircularProgressIndicator(color: Colors.green)),
      );
    }

    if (pp.history.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(32.0),
        child: Center(
          child: Text(
            "No historical records found for this product.",
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final recentHistory = pp.history.reversed.take(10).toList();

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: recentHistory.length,
      separatorBuilder: (context, index) => const Divider(color: Colors.white10, height: 1),
      itemBuilder: (context, index) {
        final item = recentHistory[index];
        
        // Dynamic, robust localization-free formatting
        final date = item.recordedAt;
        final formattedDate = "${date.day}/${date.month}/${date.year}";

        return ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            item.price.toStringAsFixed(2),
            style: const TextStyle(
              color: Colors.white, 
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Text(
            formattedDate, 
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          trailing: const Icon(
            Icons.trending_flat, 
            color: Colors.white30, 
            size: 14,
          ),
        );
      },
    );
  }
}