import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';

class InvoiceScreen extends StatefulWidget {
  const InvoiceScreen({Key? key}) : super(key: key);

  @override
  State<InvoiceScreen> createState() => _InvoiceScreenState();
}

class InvoiceItem {
  String description;
  double quantity;
  double unitPrice;
  double discount;

  InvoiceItem({
    required this.description,
    required this.quantity,
    required this.unitPrice,
    required this.discount,
  });

  double get subtotal => (quantity * unitPrice) - discount;
}

class _InvoiceScreenState extends State<InvoiceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _companyName = TextEditingController(
    text: 'M&N Holidays',
  );
  final TextEditingController _address = TextEditingController();
  final TextEditingController _vatBin = TextEditingController();
  final TextEditingController _tin = TextEditingController();
  final TextEditingController _license = TextEditingController();
  final TextEditingController _vatCircle = TextEditingController();
  final TextEditingController _phone = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _website = TextEditingController();
  final TextEditingController _invoiceNumber = TextEditingController();
  final TextEditingController _date = TextEditingController();
  final TextEditingController _dueDate = TextEditingController();
  final TextEditingController _paymentTerms = TextEditingController();
  final TextEditingController _salesPerson = TextEditingController();
  final TextEditingController _customerName = TextEditingController();
  final TextEditingController _customerAddress = TextEditingController();
  final TextEditingController _customerContact = TextEditingController();
  final TextEditingController _bankName = TextEditingController();
  final TextEditingController _accountNumber = TextEditingController();
  final TextEditingController _mobileFinance = TextEditingController();

  List<InvoiceItem> invoiceItems = [
    InvoiceItem(
      description: 'Visa Processing Service',
      quantity: 1,
      unitPrice: 0,
      discount: 0,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _date.text = DateTime.now().toString().split(' ')[0];
    _dueDate.text = DateTime.now()
        .add(const Duration(days: 7))
        .toString()
        .split(' ')[0];
  }

  @override
  void dispose() {
    _tabController.dispose();
    _companyName.dispose();
    _address.dispose();
    _vatBin.dispose();
    _tin.dispose();
    _license.dispose();
    _vatCircle.dispose();
    _phone.dispose();
    _email.dispose();
    _website.dispose();
    _invoiceNumber.dispose();
    _date.dispose();
    _dueDate.dispose();
    _paymentTerms.dispose();
    _salesPerson.dispose();
    _customerName.dispose();
    _customerAddress.dispose();
    _customerContact.dispose();
    _bankName.dispose();
    _accountNumber.dispose();
    _mobileFinance.dispose();
    super.dispose();
  }

  Future<void> _generatePDF() async {
    try {
      final pdf = pw.Document();
      double nonTaxableTotal = 0;
      double taxableTotal = 0;
      for (var item in invoiceItems) {
        taxableTotal += item.subtotal;
      }
      double vat = taxableTotal * 0.15;
      double grandTotal = nonTaxableTotal + taxableTotal + vat;

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Center(
                child: pw.Text(
                  'M&N HOLIDAYS - TAX INVOICE',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 12),
              pw.Divider(),
              pw.SizedBox(height: 12),
              pw.Text(
                'Company Information:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.Text(
                'Company Name: ${_companyName.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Address: ${_address.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'VAT BIN: ${_vatBin.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'TIN: ${_tin.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Trade License: ${_license.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'VAT Office/Circle: ${_vatCircle.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Phone: ${_phone.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Email: ${_email.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Website: ${_website.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Invoice Number: ${_invoiceNumber.text}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Date: ${_date.text}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Due Date: ${_dueDate.text}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Payment Terms: ${_paymentTerms.text}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Sales Person: ${_salesPerson.text}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Bill To (Customer):',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.Text(
                'Name: ${_customerName.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Address: ${_customerAddress.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Contact: ${_customerContact.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Service Details:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Table(
                border: pw.TableBorder.all(),
                children: [
                  pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Description',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Qty',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Unit Price',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Discount',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          'Subtotal',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ),
                  ...invoiceItems
                      .map(
                        (item) => pw.TableRow(
                          children: [
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                item.description,
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                '${item.quantity}',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                '${item.unitPrice.toStringAsFixed(2)}',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                '${item.discount.toStringAsFixed(2)}',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                            ),
                            pw.Padding(
                              padding: const pw.EdgeInsets.all(4),
                              child: pw.Text(
                                '${item.subtotal.toStringAsFixed(2)}',
                                style: const pw.TextStyle(fontSize: 8),
                              ),
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(
                        'Non-Taxable/Disbursements: BDT ${nonTaxableTotal.toStringAsFixed(2)}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'Taxable Service Charges: BDT ${taxableTotal.toStringAsFixed(2)}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                      pw.Text(
                        'VAT (15%): BDT ${vat.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.Divider(),
                      pw.Text(
                        'Grand Total: BDT ${grandTotal.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 10,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Text(
                'Payment Information:',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 11,
                ),
              ),
              pw.Text(
                'Bank: ${_bankName.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Account Number: ${_accountNumber.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
              pw.Text(
                'Mobile Finance: ${_mobileFinance.text}',
                style: const pw.TextStyle(fontSize: 9),
              ),
            ],
          ),
        ),
      );

      final dir = await getApplicationDocumentsDirectory();
      final fileName =
          'invoice_${_invoiceNumber.text}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      if (!mounted) return;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Success'),
          content: Text('Invoice saved successfully!\n\n${file.path}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  _tabController.index = 1;
                });
              },
              child: const Text('View Saved Invoices'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Error'),
          content: Text('Error generating PDF: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Invoice Manager'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[300],
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.edit), text: 'Create'),
            Tab(icon: Icon(Icons.folder), text: 'View Invoices'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildCreateInvoiceTab(), _buildViewInvoicesTab()],
      ),
    );
  }

  Widget _buildCreateInvoiceTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: ListView(
          children: [
            ExpansionTile(
              title: const Text(
                'Company Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                TextFormField(
                  controller: _companyName,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                ),
                TextFormField(
                  controller: _address,
                  decoration: const InputDecoration(labelText: 'Address'),
                ),
                TextFormField(
                  controller: _vatBin,
                  decoration: const InputDecoration(labelText: 'VAT BIN'),
                ),
                TextFormField(
                  controller: _tin,
                  decoration: const InputDecoration(labelText: 'TIN'),
                ),
                TextFormField(
                  controller: _license,
                  decoration: const InputDecoration(labelText: 'Trade License'),
                ),
                TextFormField(
                  controller: _vatCircle,
                  decoration: const InputDecoration(
                    labelText: 'VAT Office/Circle',
                  ),
                ),
                TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(labelText: 'Phone'),
                ),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                TextFormField(
                  controller: _website,
                  decoration: const InputDecoration(labelText: 'Website'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'Invoice Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                TextFormField(
                  controller: _invoiceNumber,
                  decoration: const InputDecoration(
                    labelText: 'Invoice Number',
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _date,
                  decoration: const InputDecoration(labelText: 'Date'),
                ),
                TextFormField(
                  controller: _dueDate,
                  decoration: const InputDecoration(labelText: 'Due Date'),
                ),
                TextFormField(
                  controller: _paymentTerms,
                  decoration: const InputDecoration(labelText: 'Payment Terms'),
                ),
                TextFormField(
                  controller: _salesPerson,
                  decoration: const InputDecoration(
                    labelText: 'Sales Person/Reference',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'Customer Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                TextFormField(
                  controller: _customerName,
                  decoration: const InputDecoration(labelText: 'Customer Name'),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Required' : null,
                ),
                TextFormField(
                  controller: _customerAddress,
                  decoration: const InputDecoration(
                    labelText: 'Customer Address',
                  ),
                ),
                TextFormField(
                  controller: _customerContact,
                  decoration: const InputDecoration(
                    labelText: 'Customer Contact',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'Service Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                ...List.generate(invoiceItems.length, (index) {
                  final item = invoiceItems[index];
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          TextField(
                            onChanged: (value) => item.description = value,
                            controller: TextEditingController(
                              text: item.description,
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Description',
                            ),
                          ),
                          TextField(
                            onChanged: (value) =>
                                item.quantity = double.tryParse(value) ?? 0,
                            controller: TextEditingController(
                              text: item.quantity.toString(),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Quantity',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            onChanged: (value) =>
                                item.unitPrice = double.tryParse(value) ?? 0,
                            controller: TextEditingController(
                              text: item.unitPrice.toString(),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Unit Price',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          TextField(
                            onChanged: (value) =>
                                item.discount = double.tryParse(value) ?? 0,
                            controller: TextEditingController(
                              text: item.discount.toString(),
                            ),
                            decoration: const InputDecoration(
                              labelText: 'Discount',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                          Text(
                            'Subtotal: BDT ${item.subtotal.toStringAsFixed(2)}',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              setState(() => invoiceItems.removeAt(index));
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      invoiceItems.add(
                        InvoiceItem(
                          description: '',
                          quantity: 1,
                          unitPrice: 0,
                          discount: 0,
                        ),
                      );
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Item'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ExpansionTile(
              title: const Text(
                'Payment Information',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              children: [
                TextFormField(
                  controller: _bankName,
                  decoration: const InputDecoration(labelText: 'Bank Name'),
                ),
                TextFormField(
                  controller: _accountNumber,
                  decoration: const InputDecoration(
                    labelText: 'Account Number',
                  ),
                ),
                TextFormField(
                  controller: _mobileFinance,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Finance (Bkash/Nagad/Rocket)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _generatePDF();
                }
              },
              icon: const Icon(Icons.picture_as_pdf),
              label: const Text('Generate & Save PDF'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.deepPurple,
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildViewInvoicesTab() {
    return FutureBuilder<List<File>>(
      future: _getInvoiceFiles(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text(
                  'No invoices saved yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final files = snapshot.data!;
        return ListView.builder(
          itemCount: files.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final file = files[index];
            final fileName = file.path.split('/').last;
            final fileSize = _formatFileSize(file.lengthSync());
            final modifiedDate = DateTime.fromMillisecondsSinceEpoch(
              file.lastModifiedSync().millisecondsSinceEpoch,
            );

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const Icon(
                  Icons.picture_as_pdf,
                  color: Colors.red,
                  size: 32,
                ),
                title: Text(
                  fileName.replaceAll('invoice_', '').replaceAll('.pdf', ''),
                ),
                subtitle: Text(
                  '$fileSize • ${modifiedDate.toString().split('.')[0]}',
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.open_in_new),
                          SizedBox(width: 8),
                          Text('Open'),
                        ],
                      ),
                      onTap: () => _openFile(file),
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.share),
                          SizedBox(width: 8),
                          Text('Share'),
                        ],
                      ),
                      onTap: () => _shareFile(file),
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.download),
                          SizedBox(width: 8),
                          Text('Download'),
                        ],
                      ),
                      onTap: () => _downloadFile(file),
                    ),
                    PopupMenuItem(
                      child: const Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      onTap: () => _deleteFile(file),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<File>> _getInvoiceFiles() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final files = dir
          .listSync()
          .whereType<File>()
          .where(
            (file) =>
                file.path.endsWith('.pdf') && file.path.contains('invoice_'),
          )
          .toList();
      files.sort(
        (a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()),
      );
      return files;
    } catch (e) {
      return [];
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(2)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }

  void _openFile(File file) async {
    try {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('File: ${file.path}')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not open file: $e')));
    }
  }

  void _shareFile(File file) async {
    try {
      await Share.shareXFiles([XFile(file.path)], text: 'Invoice');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not share file: $e')));
    }
  }

  void _downloadFile(File file) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('File already saved at: ${file.path}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not download file: $e')));
    }
  }

  void _deleteFile(File file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Invoice'),
        content: const Text('Are you sure you want to delete this invoice?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              try {
                file.deleteSync();
                Navigator.pop(context);
                setState(() {});
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invoice deleted')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Could not delete file: $e')),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
