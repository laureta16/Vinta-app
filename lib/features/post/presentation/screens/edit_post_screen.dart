import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/clothing_item.dart';
import '../../../../core/providers/clothing_provider.dart';
import '../../../../core/constants/albanian_cities.dart';
import '../../../../theme/app_colors.dart';

class EditPostScreen extends StatefulWidget {
  final ClothingItem item;
  const EditPostScreen({super.key, required this.item});

  @override
  State<EditPostScreen> createState() => _EditPostScreenState();
}

class _EditPostScreenState extends State<EditPostScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late double _price;
  late String _brand;
  late String _size;
  late ClothingCondition _condition;
  late String _city;

  @override
  void initState() {
    super.initState();
    _title = widget.item.title;
    _description = widget.item.description;
    _price = widget.item.price;
    _brand = widget.item.brand;
    _size = widget.item.size;
    _condition = widget.item.condition;
    _city = albanianCities.contains(widget.item.city) ? widget.item.city : albanianCities.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EDIT LISTING',
            style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1, fontSize: 16)),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('SAVE',
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: AppColors.accentColor,
                    letterSpacing: 1)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview image
              if (widget.item.imageUrls.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.network(widget.item.imageUrls.first,
                      height: 200, width: double.infinity, fit: BoxFit.cover),
                ),
              const SizedBox(height: 24),

              TextFormField(
                initialValue: _title,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
                onSaved: (v) => _title = v!,
              ),
              const SizedBox(height: 16),

              TextFormField(
                initialValue: _description,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (v) => _description = v ?? '',
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _price.toStringAsFixed(0),
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Price (Lek)'),
                      validator: (v) => v == null || double.tryParse(v) == null ? 'Invalid' : null,
                      onSaved: (v) => _price = double.parse(v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _brand,
                      decoration: const InputDecoration(labelText: 'Brand'),
                      onSaved: (v) => _brand = v ?? '',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: ['XS', 'S', 'M', 'L', 'XL', 'XXL'].contains(_size) ? _size : 'M',
                decoration: const InputDecoration(labelText: 'Size'),
                items: ['XS', 'S', 'M', 'L', 'XL', 'XXL']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => _size = v!,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _city,
                decoration: const InputDecoration(labelText: 'City'),
                items: albanianCities
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => _city = v!,
              ),
              const SizedBox(height: 16),

              const Text('CONDITION', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              SegmentedButton<ClothingCondition>(
                segments: const [
                  ButtonSegment(value: ClothingCondition.brandNew, label: Text('New')),
                  ButtonSegment(value: ClothingCondition.used, label: Text('Used')),
                ],
                selected: {_condition},
                onSelectionChanged: (s) => setState(() => _condition = s.first),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final updated = widget.item.copyWith(
        title: _title,
        description: _description,
        price: _price,
        brand: _brand,
        size: _size,
        condition: _condition,
        city: _city,
      );
      final provider = Provider.of<ClothingProvider>(context, listen: false);
      await provider.updatePost(updated);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing updated!')),
        );
        Navigator.pop(context);
      }
    }
  }
}
