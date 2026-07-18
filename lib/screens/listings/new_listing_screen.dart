import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../providers/auth_provider.dart';
import '../../providers/listings_provider.dart';
import '../../themes/app_theme.dart';
import '../../constants/app_constants.dart';
import '../../utils/validators.dart';

class NewListingScreen extends StatefulWidget {
  const NewListingScreen({super.key});
  @override
  State<NewListingScreen> createState() => _NewListingScreenState();
}

class _NewListingScreenState extends State<NewListingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _productCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();

  String _category = '';
  String _unit = 'kg';
  String _market = '';
  String _district = '';
  final List<File> _images = [];

  // Helper list to map and extract the 'name' key from your marketsInfo array
  List<String> get _marketNames {
    return AppConstants.marketsInfo
        .map((m) => m['name'] ?? '')
        .where((name) => name.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    _productCtrl.dispose();
    _qtyCtrl.dispose();
    _priceCtrl.dispose();
    _descCtrl.dispose();
    _contactCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(imageQuality: 70);
    if (picked.isNotEmpty) {
      setState(() {
        final toAdd = picked
            .map((x) => File(x.path))
            .take(5 - _images.length)
            .toList();
        _images.addAll(toAdd);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category.isEmpty) {
      _showMsg('Please select a category.');
      return;
    }
    if (_market.isEmpty) {
      _showMsg('Please select a market.');
      return;
    }
    if (_district.isEmpty) {
      _showMsg('Please select your district.');
      return;
    }

    final auth = context.read<AuthProvider>();
    final ok = await context.read<ListingsProvider>().createListing(
          farmerId: auth.user!.uid,
          farmerName: auth.user!.fullName,
          farmerDistrict: auth.user!.district,
          farmerPhone: auth.user!.phoneNumber,
          productName: _productCtrl.text.trim(),
          category: _category,
          quantity: double.parse(_qtyCtrl.text.trim()),
          unit: _unit,
          price: double.parse(_priceCtrl.text.trim()),
          market: _market,
          district: _district,
          description: _descCtrl.text.trim(),
          contactNumber: _contactCtrl.text.trim().isNotEmpty
              ? _contactCtrl.text.trim()
              : auth.user!.phoneNumber,
          images: _images,
        );

    if (ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing posted successfully!')));
      Navigator.pop(context);
    }
  }

  void _showMsg(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final lp = context.watch<ListingsProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('New Listing')),
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Images
              const Text('Enter product details',
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w700)),
              

              TextFormField(
                controller: _productCtrl,
                textInputAction: TextInputAction.next,
                decoration:
                    const InputDecoration(hintText: 'Product name'),
                validator: (v) => validateRequired(v, 'Product name'),
              ),
              const SizedBox(height: 12),

              _DropdownField(
                hint: 'Select category',
                value: _category.isEmpty ? null : _category,
                items: AppConstants.productCategories,
                onChanged: (v) => setState(() => _category = v ?? ''),
              ),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _qtyCtrl,
                      keyboardType: TextInputType.number,
                      textInputAction: TextInputAction.next,
                      decoration:
                          const InputDecoration(hintText: 'Quantity'),
                      validator: (v) => validateNumber(v, 'Quantity'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DropdownField(
                      hint: 'Unit',
                      value: _unit,
                      items: AppConstants.units,
                      onChanged: (v) =>
                          setState(() => _unit = v ?? 'kg'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _priceCtrl,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    hintText: 'Price (UGX per unit)'),
                validator: (v) => validateNumber(v, 'Price'),
              ),
              const SizedBox(height: 12),

              // Updated to parse and use your 11 custom markets configuration list
              _DropdownField(
                hint: 'Select market',
                value: _market.isEmpty ? null : _market,
                items: _marketNames,
                onChanged: (v) => setState(() => _market = v ?? ''),
              ),
              const SizedBox(height: 12),

              _DropdownField(
                hint: 'Select district',
                value: _district.isEmpty ? null : _district,
                items: AppConstants.ugandaDistricts,
                onChanged: (v) =>
                    setState(() => _district = v ?? ''),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _descCtrl,
                maxLines: 3,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                    hintText: 'Description (optional)'),
              ),
              const SizedBox(height: 12),

              TextFormField(
                controller: _contactCtrl,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                decoration: const InputDecoration(
                    hintText: 'Contact phone (optional)'),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: lp.isLoading ? null : _submit,
                child: lp.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Post Listing'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<String>(
        value: value,
        isExpanded: true,
        hint: Text(hint,
            style: const TextStyle(
                color: Color(0xFF9CA3AF), fontSize: 14)),
        items: items
            .map((i) => DropdownMenuItem(value: i, child: Text(i)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.border)),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppTheme.primary, width: 1.5)),
          filled: true,
          fillColor: const Color.fromARGB(255, 0, 0, 0),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      );
}