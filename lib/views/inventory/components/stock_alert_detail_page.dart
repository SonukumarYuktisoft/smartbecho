import 'package:flutter/material.dart';
import 'package:smartbecho/utils/custom_appbar.dart';

class StockAlertsDetailPage extends StatefulWidget {
  final String category;
  final List<String> items;

  const StockAlertsDetailPage({
    Key? key,
    required this.category,
    required this.items,
  }) : super(key: key);

  @override
  _StockAlertsDetailPageState createState() => _StockAlertsDetailPageState();
}

class _StockAlertsDetailPageState extends State<StockAlertsDetailPage> {
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems);
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems =
            widget.items
                .where(
                  (item) => item.toLowerCase().contains(
                    _searchController.text.toLowerCase(),
                  ),
                )
                .toList();
      }
    });
  }

  Color _getCategoryColor() {
    switch (widget.category.toLowerCase()) {
      case 'critical':
      case 'out of stock':
        return const Color(0xFFEF4444);
      case 'low stock':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFFEF4444);
    }
  }

  IconData _getCategoryIcon() {
    switch (widget.category.toLowerCase()) {
      case 'critical':
        return Icons.error_outline;
      case 'low stock':
        return Icons.warning_amber_outlined;
      case 'out of stock':
        return Icons.cancel_outlined;
      default:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor();
    final icon = _getCategoryIcon();

    return Scaffold(
      backgroundColor: Colors.grey[50],

 appBar: CustomAppBar(title: '${widget.category} Items', ),
      // appBar: AppBar(
      //   title: Text(
      //     '${widget.category} Items',
      //     style: const TextStyle(
      //       color: Color(0xFF1A1A1A),
      //       fontSize: 18,
      //       fontWeight: FontWeight.w600,
      //     ),
      //   ),
      //   backgroundColor: Colors.white,
      //   elevation: 0,
      //   iconTheme: const IconThemeData(color: Color(0xFF1A1A1A)),
      //   bottom: PreferredSize(
      //     preferredSize: const Size.fromHeight(1),
      //     child: Container(height: 1, color: Colors.grey.withValues(alpha:0.1)),
      //   ),
      // ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search ${widget.category.toLowerCase()} items...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon:
                    _searchController.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            _searchController.clear();
                          },
                        )
                        : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha:0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.withValues(alpha:0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: color, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey.withValues(alpha:0.05),
              ),
            ),
          ),

          // Results Count
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: Row(
              children: [
                Icon(icon, color: color, size: 16),
                const SizedBox(width: 8),
                Text(
                  '${_filteredItems.length} ${widget.category.toLowerCase()} items found',
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Items List
          Expanded(
            child:
                _filteredItems.isEmpty
                    ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items found',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try adjusting your search terms',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                    : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredItems.length,
                      itemBuilder: (context, index) {
                        return Container(
                          padding: const EdgeInsets.all(16),
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: color.withValues(alpha:0.1),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha:0.05),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha:0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(icon, color: color, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _filteredItems[index],
                                  style: const TextStyle(
                                    color: Color(0xFF1A1A1A),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
