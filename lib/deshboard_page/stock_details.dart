import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/product.dart';
import 'dart:html' as html;

class StockDetailsScreen extends StatefulWidget {
  const StockDetailsScreen({super.key});

  @override
  State<StockDetailsScreen> createState() => _StockDetailsScreenState();
}

class _StockDetailsScreenState extends State<StockDetailsScreen> {
  List<Product> products = [];
  List<Product> filteredProducts = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('products');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;
      final loaded = decoded.map((e) => Product.fromJson(e)).toList();
      setState(() {
        products = loaded;
        filteredProducts = loaded;
      });
    }
  }

  void _filterProducts() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredProducts = List.from(products);
      } else {
        filteredProducts = products.where((p) {
          return p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query) ||
              p.barcode.toLowerCase().contains(query) ||
              p.sku.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  Future<void> _generatePdf() async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateStr = "${now.day}-${now.month}-${now.year}";

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text("My Shop - Surat, Gujarat",
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue)),
            pw.SizedBox(height: 5),
            pw.Text("Stock Report - Date: $dateStr",
                style: pw.TextStyle(fontSize: 13, color: PdfColors.grey700)),
            pw.Divider(color: PdfColors.blue, thickness: 2),
          ],
        ),
        footer: (context) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text("Page ${context.pageNumber} / ${context.pagesCount}",
              style: pw.TextStyle(color: PdfColors.grey)),
        ),
        build: (context) => [
          pw.Table.fromTextArray(
            headers: [
              'Name',
              'SKU',
              'Barcode',
              'Cost (₹)',
              'Selling (₹)',
              'Qty',
              'Category'
            ],
            headerDecoration: pw.BoxDecoration(color: PdfColors.blueAccent),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 13,
            ),
            cellStyle: const pw.TextStyle(fontSize: 12),
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            data: filteredProducts.map((p) {
              return [
                p.name,
                p.sku,
                p.barcode,
                p.costPrice.toStringAsFixed(2),
                p.sellingPrice.toStringAsFixed(2),
                p.quantity.toString(),
                p.category,
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'stock_details.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else if (Platform.isAndroid || Platform.isIOS) {
      await Printing.sharePdf(bytes: bytes, filename: 'stock_details.pdf');
    } else {
      final file = File('stock_details.pdf');
      await file.writeAsBytes(bytes);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF saved locally')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final textScale = MediaQuery.of(context).textScaleFactor;
    final isDesktop = width > 900;
    final isTablet = width > 600 && width <= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Stock Details"),
        backgroundColor: Colors.blueAccent,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            tooltip: "Download PDF",
            onPressed: _generatePdf,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // 🔍 Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search by name, SKU, category, or barcode",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 📊 Summary Card
                  _buildSummaryCard(textScale),

                  const SizedBox(height: 10),

                  // 📱 Responsive Table/List
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? const Center(
                      child: Text(
                        "No products found",
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey),
                      ),
                    )
                        : isTablet || isDesktop
                        ? _buildTableView()
                        : _buildListView(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// 📦 Summary Card
  Widget _buildSummaryCard(double textScale) {
    double totalValue = 0;
    for (var p in filteredProducts) {
      totalValue += p.quantity * p.costPrice;
    }

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.inventory, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Stock Summary",
                style: TextStyle(
                    fontSize: 18 * textScale, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "Items: ${filteredProducts.length}\nValue: ₹${totalValue.toStringAsFixed(2)}",
              textAlign: TextAlign.right,
              style: TextStyle(
                  fontSize: 14 * textScale, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// 🖥️ Table View (Desktop/Tablet)
  Widget _buildTableView() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 600),
          child: DataTable(
            border: TableBorder.all(color: Colors.grey.shade300),
            headingRowColor:
            WidgetStateProperty.all(Colors.blueAccent.withOpacity(0.2)),
            columnSpacing: 16,
            horizontalMargin: 8,
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('SKU')),
              DataColumn(label: Text('Barcode')),
              DataColumn(label: Text('Cost')),
              DataColumn(label: Text('Selling')),
              DataColumn(label: Text('Qty')),
              DataColumn(label: Text('Category')),
            ],
            rows: filteredProducts
                .map(
                  (p) => DataRow(cells: [
                DataCell(Text(p.name)),
                DataCell(Text(p.sku)),
                DataCell(Text(p.barcode)),
                DataCell(Text("₹${p.costPrice.toStringAsFixed(2)}")),
                DataCell(Text("₹${p.sellingPrice.toStringAsFixed(2)}")),
                DataCell(Text(p.quantity.toString())),
                DataCell(Text(p.category)),
              ]),
            )
                .toList(),
          ),
        ),
      ),
    );
  }

  /// 📱 Card List View (Mobile)
  Widget _buildListView() {
    return ListView.builder(
      itemCount: filteredProducts.length,
      itemBuilder: (context, i) {
        final p = filteredProducts[i];
        return Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent.shade100,
              child: Text(
                p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(p.name,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💰 Cost: ₹${p.costPrice.toStringAsFixed(2)}'),
                Text('🏷 Selling: ₹${p.sellingPrice.toStringAsFixed(2)}'),
                Text('📦 Qty: ${p.quantity}'),
                Text('📂 ${p.category}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
