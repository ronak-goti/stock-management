import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/customer.dart';
import 'dart:html' as html;

class CustomerDetailsScreen extends StatefulWidget {
  const CustomerDetailsScreen({super.key});

  @override
  State<CustomerDetailsScreen> createState() => _CustomerDetailsScreenState();
}

class _CustomerDetailsScreenState extends State<CustomerDetailsScreen> {
  List<Customer> customers = [];
  List<Customer> filteredCustomers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCustomers();
    _searchController.addListener(_filterCustomers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCustomers() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('customers');
    if (jsonString != null) {
      final decoded = jsonDecode(jsonString) as List;
      final loaded = decoded.map((e) => Customer.fromJson(e)).toList();
      setState(() {
        customers = loaded;
        filteredCustomers = loaded;
      });
    }
  }

  void _filterCustomers() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredCustomers = List.from(customers);
      } else {
        filteredCustomers = customers
            .where((c) =>
        c.name.toLowerCase().contains(query) ||
            c.phone.toLowerCase().contains(query) ||
            c.email.toLowerCase().contains(query))
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
            pw.Text("Customer Report - Date: $dateStr",
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
            headers: ['Name', 'Phone', 'Email'],
            headerDecoration: pw.BoxDecoration(color: PdfColors.blueAccent),
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 13,
            ),
            cellAlignment: pw.Alignment.centerLeft,
            cellStyle: const pw.TextStyle(fontSize: 12),
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            data:
            filteredCustomers.map((c) => [c.name, c.phone, c.email]).toList(),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();

    if (kIsWeb) {
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'customer_details.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);
    } else if (Platform.isAndroid || Platform.isIOS) {
      await Printing.sharePdf(bytes: bytes, filename: 'customer_details.pdf');
    } else {
      final file = File('customer_details.pdf');
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
        title: const Text("Customer Details"),
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
                  // Search Bar
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: "Search by name, phone, or email",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Summary Card
                  _buildSummaryCard(textScale),

                  const SizedBox(height: 10),

                  // Responsive Content
                  Expanded(
                    child: filteredCustomers.isEmpty
                        ? const Center(
                      child: Text(
                        "No customers found",
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

  /// Summary Card like BillDetails
  Widget _buildSummaryCard(double textScale) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.people, color: Colors.blueAccent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Customer Summary",
                style: TextStyle(
                    fontSize: 18 * textScale, fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              "Total: ${filteredCustomers.length}",
              style: TextStyle(
                  fontSize: 16 * textScale, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  /// Table view for large screens
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
              DataColumn(label: Text('Phone')),
              DataColumn(label: Text('Email')),
            ],
            rows: filteredCustomers
                .map(
                  (c) => DataRow(cells: [
                DataCell(Text(c.name)),
                DataCell(Text(c.phone)),
                DataCell(Text(c.email)),
              ]),
            )
                .toList(),
          ),
        ),
      ),
    );
  }

  /// Card list view for mobile
  Widget _buildListView() {
    return ListView.builder(
      itemCount: filteredCustomers.length,
      itemBuilder: (context, i) {
        final c = filteredCustomers[i];
        return Card(
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.blueAccent.shade100,
              child: Text(
                c.name.isNotEmpty ? c.name[0].toUpperCase() : '?',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(c.name,
                style:
                const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('📞 ${c.phone}'),
                Text('✉️ ${c.email}'),
              ],
            ),
          ),
        );
      },
    );
  }
}
