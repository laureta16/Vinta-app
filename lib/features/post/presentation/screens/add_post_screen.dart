import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/albanian_cities.dart';
import '../../../../core/models/clothing_item.dart';
import '../../../../core/providers/clothing_provider.dart';
import '../../../../core/providers/auth_provider.dart';
import '../../../../theme/app_colors.dart';

class AddPostScreen extends StatefulWidget {
  const AddPostScreen({super.key});

  @override
  State<AddPostScreen> createState() => _AddPostScreenState();
}

class _AddPostScreenState extends State<AddPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  
  String _title = '';
  double _price = 0;
  String _brand = '';
  String _size = 'M';
  String _customSize = '';
  ClothingCondition _condition = ClothingCondition.brandNew;
  String _selectedCity = albanianCities.first;
  
  final List<XFile> _selectedImages = [];
  XFile? _selectedVideo;

  Future<void> _pickImages() async {
    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      setState(() {
        if (_selectedImages.length + images.length <= 10) {
          _selectedImages.addAll(images);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Maximum 10 images allowed')),
          );
        }
      });
    }
  }

  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
    if (video != null) {
      setState(() {
        _selectedVideo = video;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('SELL ON VINTA'),
        actions: [
          TextButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                if (_selectedImages.isEmpty && _selectedVideo == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please add at least one photo or video')),
                  );
                  return;
                }
                
                _formKey.currentState!.save();
                final finalSize = _size == 'Enter size' ? _customSize : _size;
                
                final newItem = ClothingItem(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  title: _title,
                  description: _title,
                  brand: _brand.isEmpty ? 'Generic' : _brand,
                  price: _price,
                  size: finalSize,
                  condition: _condition,
                  city: _selectedCity,
                  imageUrls: [], // Will be filled by the Provider after cloud upload
                  sellerId: auth.user?.id ?? 'u1',
                  sellerName: auth.user?.username ?? 'Me',
                );

                try {
                  await Provider.of<ClothingProvider>(context, listen: false).addPost(
                    newItem,
                    images: _selectedImages,
                    video: _selectedVideo,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Item listed live on Vinta!')),
                    );
                    // Navigator.pop(context); // Optional: go back after successful post
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Failed to post item: $e'), backgroundColor: AppColors.error),
                    );
                  }
                }
                
                _formKey.currentState!.reset();
                setState(() {
                  _condition = ClothingCondition.brandNew;
                  _size = 'M';
                  _customSize = '';
                  _selectedCity = albanianCities.first;
                  _selectedImages.clear();
                  _selectedVideo = null;
                });
              }
            },
            child: const Text('POST', 
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.accentColor, letterSpacing: 1.2)),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Media Picker Section
              const Text('MEDIA (Upto 10 Photos or 1 Video)', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickImages,
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: _selectedImages.isEmpty 
                          ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo_rounded, color: AppColors.accentColor), Text('Add Photos')])
                          : ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _selectedImages.length,
                              itemBuilder: (context, i) => Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(_selectedImages[i].path, width: 100, fit: BoxFit.cover)),
                              ),
                            ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: _pickVideo,
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: _selectedVideo == null 
                          ? const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.video_library_rounded, color: AppColors.accentColor), Text('Add Video')])
                          : Stack(
                              alignment: Alignment.center,
                              children: [
                                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 48),
                                Positioned(bottom: 8, child: Text(_selectedVideo!.name, style: const TextStyle(fontSize: 10))),
                              ],
                            ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              const Text('PRODUCT DETAILS', 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1.5, color: AppColors.textSecondary)),
              const SizedBox(height: 20),
              
              TextFormField(
                decoration: const InputDecoration(hintText: 'What are you selling?', labelText: 'Title'),
                validator: (value) => value == null || value.isEmpty ? 'Title is required' : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(hintText: '0', labelText: 'Price (Lek)'),
                      validator: (value) => value == null || double.tryParse(value) == null ? 'Invalid price' : null,
                      onSaved: (value) => _price = double.parse(value!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _size,
                      decoration: const InputDecoration(labelText: 'Size'),
                      items: ['XS', 'S', 'M', 'L', 'XL', 'XXL', 'Enter size']
                          .map((size) => DropdownMenuItem(value: size, child: Text(size)))
                          .toList(),
                      onChanged: (value) => setState(() => _size = value!),
                    ),
                  ),
                ],
              ),
              
              if (_size == 'Enter size') ...[
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(hintText: 'e.g. 44, XXXL, or Custom', labelText: 'Custom Size'),
                  onChanged: (value) => _customSize = value,
                  validator: (value) => _size == 'Enter size' && (value == null || value.isEmpty) ? 'Enter a size' : null,
                ),
              ],
              
              const SizedBox(height: 16),
              
              TextFormField(
                decoration: const InputDecoration(hintText: 'Brand name (optional)', labelText: 'Brand'),
                onSaved: (value) => _brand = value ?? '',
              ),
              const SizedBox(height: 16),
              
              const Text('CONDITION', 
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textPrimary)),
              const SizedBox(height: 10),
              SegmentedButton<ClothingCondition>(
                segments: const [
                  ButtonSegment(value: ClothingCondition.brandNew, label: Text('Brand New'), icon: Icon(Icons.new_releases_rounded, size: 16)),
                  ButtonSegment(value: ClothingCondition.used, label: Text('Gently Used'), icon: Icon(Icons.check_circle_rounded, size: 16)),
                ],
                selected: {_condition},
                onSelectionChanged: (selected) => setState(() => _condition = selected.first),
                style: ButtonStyle(
                  side: MaterialStateProperty.all(const BorderSide(color: AppColors.border)),
                  shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                ),
              ),
              const SizedBox(height: 16),
              
              DropdownButtonFormField<String>(
                value: _selectedCity,
                decoration: const InputDecoration(labelText: 'Location (City)'),
                items: albanianCities
                    .map((city) => DropdownMenuItem(value: city, child: Text(city)))
                    .toList(),
                onChanged: (value) => setState(() => _selectedCity = value!),
              ),
              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
