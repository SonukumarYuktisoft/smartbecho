import 'package:flutter/material.dart';
import 'package:smartbecho/utils/charts/chart_converter.dart';
import 'package:smartbecho/utils/charts/chart_widgets.dart';

class TeatChart extends StatefulWidget {
  const TeatChart({Key? key}) : super(key: key);

  @override
  State<TeatChart> createState() => _TeatChartState();
}

class _TeatChartState extends State<TeatChart> {
  // Sample API responses - Replace with actual API calls
  late Map<String, dynamic> format1Response;
  late Map<String, dynamic> format2Response;
  late Map<String, dynamic> format3Response;
  late Map<String, dynamic> format4Response;
  late Map<String, dynamic> format5Response;
  late Map<String, dynamic> format6Response;
  late Map<String, dynamic> format7Response;
  late Map<String, dynamic> format8Response;

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  void _initializeSampleData() {
    // Format 1: Monthly revenue (Bar Chart)
    format1Response = {
      "status": "Success",
      "message": "Monthly revenue fetched successfully",
      "payload": {
        "2026-01": 100000.0,
        "2026-02": 166000.0,
        "2026-03": 145000.0,
       
      },
      "statusCode": 200,
    };

    // Format 2: Brand sales (Pie Chart)
    format2Response = {
      "status": "Success",
      "message": "Brand sales data fetched successfully",
      "payload": [
        {
          "totalQuantity": 9,
          "month": "February",
          "percentage": "42.86",
          "brand": "BAJAJ",
        },
        {
          "totalQuantity": 3,
          "month": "February",
          "percentage": "14.29",
          "brand": "SKY LED",
        },
        {
          "totalQuantity": 5,
          "month": "February",
          "percentage": "23.81",
          "brand": "VIVO",
        },
        {
          "totalQuantity": 4,
          "month": "February",
          "percentage": "19.04",
          "brand": "Samsung",
        },   {
          "totalQuantity": 4,
          "month": "February",
          "percentage": "19.04",
          "brand": "Samsung",
        },   {
          "totalQuantity": 4,
          "month": "February",
          "percentage": "19.04",
          "brand": "Samsung",
        },   {
          "totalQuantity": 4,
          "month": "February",
          "percentage": "19.04",
          "brand": "Samsung",
        },   {
          "totalQuantity": 4,
          "month": "February",
          "percentage": "19.04",
          "brand": "Samsung",
        },   {
          "totalQuantity": 4,
          "month": "February",
          "percentage": "19.04",
          "brand": "Samsung",
        },   {
          "totalQuantity": 4,
          "month": "February",
          "percentage": "19.04",
          "brand": "Samsung",
        },   {
          "totalQuantity": 4,
          "month": "February",
          "percentage": "19.04",
          "brand": "Samsung",
        },
           {
          "totalQuantity": 4,
          "month": "February",
          "percentage": "19.04",
          "brand": "Samsung",
        },
      ],
      "statusCode": 200,
    };

    // Format 3: Top selling models (Column Chart)
    format3Response = {
      "status": "Success",
      "message": "Top selling models fetched successfully",
      "payload": [
        {
          "totalAmount": 91000.00,
          "quantity": 9,
          "model": "25 litter",
          "brand": "bajaj",
        },
        {
          "totalAmount": 45000.00,
          "quantity": 3,
          "model": "f30 fe",
          "brand": "sky led",
        },
        {
          "totalAmount": 30000.00,
          "quantity": 2,
          "model": "y91",
          "brand": "vivo",
        },
        {
          "totalAmount": 60000.00,
          "quantity": 4,
          "model": "S21",
          "brand": "samsung",
        },
        {
          "totalAmount": 60000.00,
          "quantity": 4,
          "model": "S21",
          "brand": "samsung",
        },{
          "totalAmount": 60000.00,
          "quantity": 4,
          "model": "S21",
          "brand": "samsung",
        },{
          "totalAmount": 6000.00,
          "quantity": 4,
          "model": "S21",
          "brand": "samsung",
        },{
          "totalAmount": 6000.00,
          "quantity": 4,
          "model": "S21",
          "brand": "samsung",
        },{
          "totalAmount": 6000.00,
          "quantity": 4,
          "model": "S21",
          "brand": "samsung",
        },{
          "totalAmount": 6000.00,
          "quantity": 4,
          "model": "S21",
          "brand": "samsung",
        },
      ],
      "statusCode": 200,
    };

    // Format 4: Payment distribution (Doughnut Chart)
    format4Response = {
      "status": "Success",
      "message": "Payment distribution fetched successfully",
      "payload": [
        {
          "paymentMethod": "UPI",
          "paymentType": "FULL",
          "count": 5,
          "totalAmount": 50000.00,
        },
        {
          "paymentMethod": "CASH",
          "paymentType": "FULL",
          "count": 2,
          "totalAmount": 40000.00,
        },
        {
          "paymentMethod": "Card",
          "paymentType": "FULL",
          "count": 3,
          "totalAmount": 60000.00,
        },
        {
          "paymentMethod": "Bank Transfer",
          "paymentType": "FULL",
          "count": 4,
          "totalAmount": 80000.00,
        },
      ],
      "statusCode": 200,
    };

    // Format 5: Multi-line monthly data (MultiLine Chart)
    format5Response = {
      "status": "Success",
      "message": "Fetched successfully",
      "payload": [
        {
          "month": 1,
          "totalBillsPaid": 150000,
          "totalSalesAmount": 80000,
          "totalCommissions": 5000,
        },
        {
          "month": 2,
          "totalBillsPaid": 260655.00,
          "totalSalesAmount": 166000.00,
          "totalCommissions": 10000.00,
        },
        {
          "month": 3,
          "totalBillsPaid": 200000,
          "totalSalesAmount": 120000,
          "totalCommissions": 8000,
        },
        {
          "month": 4,
          "totalBillsPaid": 180000.00,
          "totalSalesAmount": 95000.00,
          "totalCommissions": 7000.00,
        },
        {
          "month": 5,
          "totalBillsPaid": 220000,
          "totalSalesAmount": 145000,
          "totalCommissions": 11000,
        },
      ],
      "statusCode": 200,
    };

    // Format 6: Simple monthly bar (Line Chart)
    format6Response = {
      "status": "Success",
      "message": "Monthly data",
      "payload": [
        {"label": "January", "value": 125000.00},
        {"label": "February", "value": 260655.00},
        {"label": "March", "value": 180000.00},
        {"label": "April", "value": 215000.00},
      ],
      "statusCode": 200,
    };

    // Format 7: Locations (Pie Chart)
    format7Response = {
      "status": "Success",
      "message": "Customer location-wise data fetched successfully",
      "payload": {
        "Delhi": 15,
        "Gaya": 8,
        "Bihar": 12,
        "Bihar Sharif": 10,
        "Biharsharif": 5,
        "Patna": 20,
      },
      "statusCode": 200,
    };

    // Format 8: Store-wise sales (Bar Chart)
    format8Response = {
      "status": "Success",
      "message": "Store-wise sales fetched successfully",
      "payload": [
        {"label": "KRISHNA ELECTRONICS", "value": 215000.00},
        {"label": "LOCAL STORE", "value": 120000.00},
        {"label": "CITY MALL", "value": 185000.00},
        {"label": "HIGHWAY STORE", "value": 95000.00},
        {"label": "METRO STORE", "value": 155000.00},
      ],
      "statusCode": 200,
    };
   
  }

  @override
  Widget build(BuildContext context) {
     final salesData = [
      {"label": "Day 1", "value": 50000},
      {"label": "Day 2", "value": 75000},
      {"label": "Day 3", "value": 65000},
      {"label": "Day 4", "value": 95000},
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Charts Demo'),
        elevation: 0,
        backgroundColor: const Color(0xFF4C5EEB),
      ),
      backgroundColor: const Color(0xFFF9FAFB),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Section 1: Bar Chart
              _buildSectionHeader(
                '1. Bar Chart',
                'Horizontal bars for categories',
              ),
              const SizedBox(height: 12),
              AutoChart(
                apiResponse: format8Response,
                title: 'Store-wise Sales',
                chartType: ChartType.bar,
                subtitle: 'Total Sales by Location',
              ),
              const SizedBox(height: 32),

              // Section 2: Column Chart
              _buildSectionHeader(
                '2. Column Chart',
                'Vertical bars for quantities',
              ),
              const SizedBox(height: 12),
              AutoChart(
                apiResponse: format3Response,
                title: 'Top Selling Models',
                chartType: ChartType.column,
                subtitle: 'Sales Amount by Model',
              ),
              const SizedBox(height: 32),

              // Section 3: Line Chart
              _buildSectionHeader('3. Line Chart', 'Trends over time'),
              const SizedBox(height: 12),
              AutoChart(
                apiResponse: format6Response,
                title: 'Monthly Revenue Trend',
                chartType: ChartType.line,
                subtitle: 'Revenue Pattern',
              ),
              const SizedBox(height: 32),
              // AutoChart(
              //   apiResponse: salesData,
              //   title: 'Smooth Trend',
              //   chartType: ChartType.spline,
              // ),
              // Section 4: Pie Chart
              _buildSectionHeader('4. Pie Chart', 'Distribution of data'),
              const SizedBox(height: 12),
              AutoChart(
                apiResponse: format2Response,
                title: 'Brand Sales Distribution',
                chartType: ChartType.pie,
                subtitle: 'Market Share by Brand',
              ),
              const SizedBox(height: 32),

              // Section 5: Doughnut Chart
              _buildSectionHeader(
                '5. Doughnut Chart',
                'Distribution with center info',
              ),
              const SizedBox(height: 12),
              AutoChart(
                apiResponse: format4Response,
                title: 'Payment Methods',
                chartType: ChartType.doughnut,
                subtitle: 'Payment Distribution',
              ),
              const SizedBox(height: 32),

              // Section 6: Multi-Line Chart
              _buildSectionHeader(
                '6. Multi-Line Chart',
                'Multiple metrics simultaneously',
              ),
              const SizedBox(height: 12),
              AutoChart(
                apiResponse: format5Response,
                title: 'Monthly Financial Summary',
                chartType: ChartType.multiLine,
                subtitle: 'Bills, Sales, and Commissions',
              ),
              const SizedBox(height: 32),

              // Bonus: Location Distribution (Pie from map data)
              _buildSectionHeader(
                'Bonus: Location Analysis',
                'Customer distribution',
              ),
              const SizedBox(height: 12),
              AutoChart(
                apiResponse: format7Response,
                title: 'Customers by Location',
                chartType: ChartType.pie,
                subtitle: 'Regional Distribution',
              ),
              const SizedBox(height: 32),

              // Yearly Revenue Example
              _buildSectionHeader('Yearly Support', 'All 12 months display'),
              const SizedBox(height: 12),
              AutoChart(
                apiResponse: format1Response,
                title: 'Yearly Revenue',
                chartType: ChartType.column,
                subtitle: '2026 Full Year',
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}

// Example with direct API call
class ApiChartExample extends StatefulWidget {
  const ApiChartExample({Key? key}) : super(key: key);

  @override
  State<ApiChartExample> createState() => _ApiChartExampleState();
}

class _ApiChartExampleState extends State<ApiChartExample> {
  Future<Map<String, dynamic>> fetchChartData() async {
    // Replace with actual API call
    // final response = await http.get(Uri.parse('your_api_endpoint'));
    // return jsonDecode(response.body);

    // Mock response
    return {
      "status": "Success",
      "payload": [
        {
          "month": 1,
          "totalBillsPaid": 100000,
          "totalSalesAmount": 50000,
          "totalCommissions": 2000,
        },
        {
          "month": 2,
          "totalBillsPaid": 200000,
          "totalSalesAmount": 150000,
          "totalCommissions": 5000,
        },
        {
          "month": 3,
          "totalBillsPaid": 180000,
          "totalSalesAmount": 120000,
          "totalCommissions": 4000,
        },
      ],
      "statusCode": 200,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: fetchChartData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData) {
          return const Center(child: Text('No data'));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Chart from API'),
            backgroundColor: const Color(0xFF4C5EEB),
          ),
          backgroundColor: const Color(0xFFF9FAFB),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: AutoChart(
              apiResponse: snapshot.data!,
              title: 'Financial Summary',
              chartType: ChartType.multiLine,
              subtitle: 'Real-time Data',
            ),
          ),
        );
      },
    );
  }
}

// Quick reference for all formats
class ChartFormatReference {
  static Map<int, String> formatDescriptions = {
    1: 'Format 1: Bar - Horizontal bars (Store-wise sales)',
    2: 'Format 2: Column - Vertical bars (Top selling models)',
    3: 'Format 3: Line - Trends over time (Monthly revenue)',
    4: 'Format 4: Pie - Distribution (Brand market share)',
    5: 'Format 5: Doughnut - Distribution with center (Payment methods)',
    6: 'Format 6: MultiLine - Multiple metrics (Financial summary)',
  };

  // Usage example
  static void printUsageExample() {
    print('''
    // For any API response, just use AutoChart:
    
    // 1. Bar Chart - Horizontal bars
    AutoChart(
      apiResponse: response,
      title: 'Store Sales',
      chartType: ChartType.bar,
      subtitle: 'By Location',
    )
    
    // 2. Column Chart - Vertical bars
    AutoChart(
      apiResponse: response,
      title: 'Top Models',
      chartType: ChartType.column,
      subtitle: 'By Quantity',
    )
    
    // 3. Line Chart - Trends
    AutoChart(
      apiResponse: response,
      title: 'Revenue Trend',
      chartType: ChartType.line,
      subtitle: 'Monthly Pattern',
    )
    
    // 4. Pie Chart - Distribution
    AutoChart(
      apiResponse: response,
      title: 'Brand Share',
      chartType: ChartType.pie,
      subtitle: 'Market Distribution',
    )
    
    // 5. Doughnut Chart - With center total
    AutoChart(
      apiResponse: response,
      title: 'Payments',
      chartType: ChartType.doughnut,
      subtitle: 'Payment Methods',
    )
    
    // 6. Multi-Line Chart - Multiple metrics
    AutoChart(
      apiResponse: response,
      title: 'Financial Summary',
      chartType: ChartType.multiLine,
      subtitle: 'Bills, Sales, Commissions',
    )
    
    // Features:
    1. Auto-detects response format
    2. Formats Y-axis (1k, 1L, 1Cr)
    3. Shows all 12 months for yearly data
    4. Limits pie/doughnut to 7 items
    5. Supports subtitles
    6. Beautiful app-colored UI
    7. Professional tooltips
    8. Empty state handling
    ''');
  }

  // Get all chart types
  static List<ChartType> getAllChartTypes() => [
    ChartType.bar,
    ChartType.column,
    ChartType.line,
    ChartType.pie,
    ChartType.doughnut,
    ChartType.multiLine,
  ];
}
