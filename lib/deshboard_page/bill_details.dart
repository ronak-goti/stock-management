import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/bill.dart';
import 'dart:html' as html;

class BillDetailsScreen extends StatefulWidget {
  const BillDetailsScreen({super.key});

  @override
  State<BillDetailsScreen> createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  List<Bill> bills = [];
  List<Bill> filteredBills = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadBills();
    _searchController.addListener(_filterBills);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBills() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('bills');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;
      final loaded = decoded.map((e) => Bill.fromJson(e)).toList();
      setState(() {
        bills = loaded;
        filteredBills = loaded;
      });
    }
  }

  void _filterBills() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredBills = List.from(bills);
      } else {
        filteredBills = bills
            .where((b) =>
        b.billNumber.toLowerCase().contains(query) ||
            b.name.toLowerCase().contains(query) ||
            b.date.toLowerCase().contains(query))
            .toList();
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
            pw.Text("Bill Report - Date: $dateStr",
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
            headers: ['Bill No.', 'Customer', 'Amount', 'Date'],
            headerDecoration: pw.BoxDecoration(color: PdfColors.blueAccent),
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 13),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 12),
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            data: filteredBills
                .map((b) =>
            [b.billNumber, b.name, '₹${b.amount}', b.date])
                .toList(),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'bill_report.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else if (Platform.isAndroid || Platform.isIOS) {
      await Printing.sharePdf(bytes: bytes, filename: 'bill_report.pdf');
    } else {
      final file = File('bill_report.pdf');
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
        title: const Text("Bill Details"),
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
                      hintText: "Search by Bill No., Customer, or Date",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // 📊 Summary Card
                  _buildSummaryCard(textScale),

                  const SizedBox(height: 10),

                  // 📋 Responsive Content
                  Expanded(
                    child: filteredBills.isEmpty
                        ? const Center(
                      child: Text(
                        "No bills found",
                        style:
                        TextStyle(fontSize: 18, color: Colors.grey),
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
    double total = filteredBills.fold(0, (sum, b) => sum + b.amount);

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.receipt_long, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Bill Summary",
                style: TextStyle(
                    fontSize: 18 * textScale, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "Total: ₹${total.toStringAsFixed(2)}",
              style: TextStyle(
                  fontSize: 16 * textScale, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// 💻 Table view for desktop/tablet
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
              DataColumn(label: Text('Bill No.')),
              DataColumn(label: Text('Customer')),
              DataColumn(label: Text('Amount')),
              DataColumn(label: Text('Date')),
            ],
            rows: filteredBills
                .map(
                  (b) => DataRow(cells: [
                DataCell(Text(b.billNumber)),
                DataCell(Text(b.name)),
                DataCell(Text('₹${b.amount.toStringAsFixed(2)}')),
                DataCell(Text(b.date)),
              ]),
            )
                .toList(),
          ),
        ),
      ),
    );
  }

  /// 📱 Card list view for mobile
  Widget _buildListView() {
    return ListView.builder(
      itemCount: filteredBills.length,
      itemBuilder: (context, i) {
        final b = filteredBills[i];
        return Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent.shade100,
              child: Icon(Icons.border_inner_sharp)
            ),
            title: Text(b.name,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('💰 ₹${b.amount.toStringAsFixed(2)}'),
                Text('🗓️ ${b.date}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
