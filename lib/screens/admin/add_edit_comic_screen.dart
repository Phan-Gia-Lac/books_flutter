import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../models/data_model.dart';
import '../../viewmodel/adminVM.dart';
import '../../viewmodel/authVM.dart';
import '../../viewmodel/productsVM.dart';


// ── AddEditComicScreen ─────────────────────────────────────────────────────
class AddEditComicScreen extends StatefulWidget {
  final Book? book; // null = add mode, non-null = edit mode

  const AddEditComicScreen({super.key, this.book});

  @override
  State<AddEditComicScreen> createState() => _AddEditComicScreenState();
}

class _AddEditComicScreenState extends State<AddEditComicScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleController;
  late final TextEditingController _priceController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _coverImageController;

  int? _selectedCategoryId;
  int? _selectedAuthorId;
  bool _isSubmitting = false;

  bool get _isEditMode => widget.book != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.book?.title ?? '');
    _priceController = TextEditingController(text: widget.book?.price.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.book?.description ?? '');
    _coverImageController = TextEditingController(text: widget.book?.coverImage ?? '');

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productsVM = context.read<ProductsVM>();
      productsVM.fetchCategories();
      productsVM.fetchAuthors();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    _coverImageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(
        backgroundColor: ProfileColors.background,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppColors.white),
        title: Text(
          _isEditMode ? 'Edit Comic' : 'Add New Comic',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _buildCoverPreview(),
              const SizedBox(height: 24),

              _buildLabel('Title'),
              _buildTextField(
                controller: _titleController,
                hint: 'e.g. One Piece Vol. 1',
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required' : null,
              ),
              const SizedBox(height: 16),

              _buildLabel('Price'),
              _buildTextField(
                controller: _priceController,
                hint: 'e.g. 9.99',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Price is required';
                  if (double.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              _buildLabel('Cover Image (asset path or URL)'),
              _buildTextField(
                controller: _coverImageController,
                hint: 'assets/covers/one_piece.jpg',
              ),
              const SizedBox(height: 16),

              _buildLabel('Category'),
              _buildCategoryDropdown(),
              const SizedBox(height: 16),

              _buildLabel('Author'),
              _buildAuthorDropdown(),
              const SizedBox(height: 16),

              _buildLabel('Description'),
              _buildTextField(
                controller: _descriptionController,
                hint: 'Short description of the comic...',
                maxLines: 5,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Description is required' : null,
              ),
              const SizedBox(height: 32),

              _buildSubmitButton(),

              if (_isEditMode) ...[
                const SizedBox(height: 12),
                _buildDeleteButton(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── UI Pieces ──────────────────────────────────────────────

  Widget _buildCoverPreview() {
    final imageUrl = _coverImageController.text.trim();
    final isNetwork = imageUrl.startsWith('http') || imageUrl.startsWith('https');

    return Center(
      child: Container(
        width: 140,
        height: 190,
        decoration: BoxDecoration(
          color: ProfileColors.surfaceRaised,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white12),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageUrl.isNotEmpty
              ? (isNetwork
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.broken_image_rounded, color: Colors.white38, size: 48),
                      ),
                    )
                  : Image.asset(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.book_rounded, color: Colors.white38, size: 48),
                      ),
                    ))
              /* 
              // OLD CODE: Only supported assets
              : _coverImageController.text.isNotEmpty
                  ? Image.asset(
                      _coverImageController.text,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Center(
                        child: Icon(Icons.book_rounded, color: Colors.white38, size: 48),
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.book_rounded, color: Colors.white38, size: 48),
                    ),
              */
              : const Center(
                  child: Icon(Icons.book_rounded, color: Colors.white38, size: 48),
                ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppColors.white),
      validator: validator,
      onChanged: (_) => setState(() {}), // refresh cover preview live
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        filled: true,
        fillColor: ProfileColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<ProductsVM>(
      builder: (context, vm, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: ProfileColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              dropdownColor: ProfileColors.surface,
              value: _selectedCategoryId,
              hint: const Text('Select category', style: TextStyle(color: Colors.white38)),
              style: const TextStyle(color: AppColors.white),
              items: vm.categories.map((cat) {
                return DropdownMenuItem<int>(
                  value: cat.id,
                  child: Text(cat.name),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCategoryId = val),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAuthorDropdown() {
    return Consumer<ProductsVM>(
      builder: (context, vm, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: ProfileColors.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<int>(
              isExpanded: true,
              dropdownColor: ProfileColors.surface,
              value: _selectedAuthorId,
              hint: const Text('Select author', style: TextStyle(color: Colors.white38)),
              style: const TextStyle(color: AppColors.white),
              items: vm.authors.map((author) {
                return DropdownMenuItem<int>(
                  value: author.id,
                  child: Text(author.name),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedAuthorId = val),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _handleSubmit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                width: 22, height: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(
                _isEditMode ? 'Save Changes' : 'Add Comic',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15),
              ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: OutlinedButton(
        onPressed: _isSubmitting ? null : null,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.redAccent),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: const Text('Delete Comic', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.w600)),
      ),
    );
  }

  // ── Actions ──────────────────────────────────────────────

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null || _selectedAuthorId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category and author')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final token = context.read<AuthVM>().accessToken ?? '';
    final adminVM = context.read<AdminVM>();

    final success = _isEditMode
        ? await adminVM.updateBook(
            id: widget.book!.id,
            title: _titleController.text.trim(),
            price: double.parse(_priceController.text),
            description: _descriptionController.text.trim(),
            token: token,
            coverImage: _coverImageController.text.trim(), // Added coverImage
          )
        : await adminVM.addBook(
            title: _titleController.text.trim(),
            price: double.parse(_priceController.text),
            description: _descriptionController.text.trim(),
            categoryId: _selectedCategoryId!,
            authorId: _selectedAuthorId!,
            token: token,
            coverImage: _coverImageController.text.trim(), // Added coverImage
          );
    
    /*
    // OLD CODE: coverImage was missing
    final success = _isEditMode
        ? await adminVM.updateBook(
            id: widget.book!.id,
            title: _titleController.text.trim(),
            price: double.parse(_priceController.text),
            description: _descriptionController.text.trim(),
            token: token,
          )
        : await adminVM.addBook(
            title: _titleController.text.trim(),
            price: double.parse(_priceController.text),
            description: _descriptionController.text.trim(),
            categoryId: _selectedCategoryId!,
            authorId: _selectedAuthorId!,
            token: token,
          );
    */

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_isEditMode ? 'Comic updated' : 'Comic added')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(adminVM.error ?? 'Something went wrong')),
      );
    }
  }
}