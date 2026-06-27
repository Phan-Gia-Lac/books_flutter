import 'package:books_flutter/AppRoutes.dart';
import 'package:books_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:books_flutter/viewmodel/authVM.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'order_history_screen.dart';
// Fix user info by calling api
// Save changes has to change the information of that exact user
// add 2 step factor for changing email?


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  // late final TextEditingController _passwordController;
  late final TextEditingController _phonenumberController;
  late final TextEditingController _bioController;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    // _passwordController.dispose();
    _phonenumberController.dispose();
    _bioController.dispose();
    super.dispose();
  }
  void initState() {
    super.initState();

    final authVM = Provider.of<AuthVM>(context, listen: false);
    final currentUser = authVM.user;

    _nameController = TextEditingController(text: currentUser?.fullName ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
    // _passwordController = TextEditingController(text: currentUser?.password ?? '');
    _phonenumberController = TextEditingController(text: currentUser?.phoneNumber ?? '');
    _bioController = TextEditingController(text: 'Hello');
  }

  Future<bool> ValidationCheck() async {
    if (_nameController.text.trim().isEmpty || _phonenumberController.text.trim().isEmpty) {
      return false;
    }
    return true;
  }


  void _onSaveChanges() async {
  // 1. Run your validation checks first
  final bool check = await ValidationCheck();
  if (!check) return; // Exit early if validation fails

  // 2. Get the AuthVM instance
  final authVM = Provider.of<AuthVM>(context, listen: false);

  // 3. Call the updateProfile method with data from your controllers
  final bool success = await authVM.updateProfile(
    fullName: _nameController.text.trim(),
    phoneNumber: _phonenumberController.text.trim()
  );

  // 4. Check if the widget is still in the tree before showing UI elements
  if (!mounted) return;

  // 5. Show a SnackBar reflecting the real backend result
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        success ? 'Changes saved' : (authVM.error ?? 'Failed to save changes'),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      backgroundColor: success ? ProfileColors.surfaceRaised : Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      dismissDirection: DismissDirection.horizontal,
      margin: const EdgeInsets.only(
        bottom: 808 - 140,
        left: 16,
        right: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: success ? ProfileColors.limeDim : Colors.red, 
          width: 1,
        ),
      ),
    ),
  );
}

  void _onSignOut() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: ProfileColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: ProfileColors.wireFrame),
        ),
        title: const Text(
          'Sign out?',
          style: TextStyle(
            color: ProfileColors.textPrimary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
        content: const Text(
          'You will need to sign in again to access your library.',
          style: TextStyle(color: ProfileColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'Cancel',
              style: TextStyle(color: ProfileColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthVM>().logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (_) => false,
              );
            },
            child: const Text(
              'Sign out',
              style: TextStyle(
                color: ProfileColors.lime,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ProfileColors.background,
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: ProfileColors.background,
        centerTitle: true,
        title: const Text(
          'Edit profile',
          style: TextStyle(
            color: ProfileColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ProfileColors.borderOuter.withValues(alpha: 0.4),
                  ProfileColors.lime.withValues(alpha: 0.35),
                  ProfileColors.borderOuter.withValues(alpha: 0.4),
                ],
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _RetroFrame(
                child: AvatarSection(
                  onChangePhoto: () {

                    // Sẽ xử lý logic sau
                    print("Ảnh đại diện đã được thay đổi");
                  }
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _RetroFrame(
                        child: _UserInfoSection(
                          nameController: _nameController,
                          emailController: _emailController,
                          phonenumberController: _phonenumberController,
                          bioController: _bioController,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SaveChangesButton(onPressed: _onSaveChanges),
                      const SizedBox(height: 16),
                      _ProfileMenuTile(
                        icon: Icons.receipt_long_rounded,
                        label: 'Đơn hàng của tôi',
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.orderHistory);
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              _SignOutButton(onPressed: _onSignOut),
            ],
          ),
        ),
      ),
    );
  }
}

/// Double-rim retro panel matching auth screens.
class _RetroFrame extends StatelessWidget {
  const _RetroFrame({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: ProfileColors.borderOuter.withValues(alpha: 0.6),
          width: 2,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: ProfileColors.borderInner, width: 2),
          color: ProfileColors.surface,
        ),
        child: child,
      ),
    );
  }
}

class AvatarSection extends StatefulWidget {
  const AvatarSection({super.key, required this.onChangePhoto});

  final VoidCallback onChangePhoto;

  @override
  State<AvatarSection> createState() => _AvatarSectionState();
}

class _AvatarSectionState extends State<AvatarSection> {
  XFile? selectedImage;
  dynamic _pickImageError;
  final ImagePicker _picker = ImagePicker();

  Future<void> _onImageButtonPressed(
    ImageSource source, {
    required BuildContext context,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        setState(() {
          selectedImage = pickedFile;
        });
        widget.onChangePhoto();
      }
    } catch (e) {
      setState(() {
        _pickImageError = e;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot choose image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: 112,
                height: 112,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: ProfileColors.surfaceRaised,
                  border: Border.all(color: ProfileColors.wireFrame, width: 2),

                  image: selectedImage != null
                      ? DecorationImage(
                          image: FileImage(File(selectedImage!.path)),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: ProfileColors.lime.withValues(alpha: 0.08),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                // Only show the person placeholder icon if NO image has been selected yet
                child: selectedImage == null
                    ? const Icon(
                        Icons.person_rounded,
                        size: 56,
                        color: ProfileColors.textMuted,
                      )
                    : null,
              ),
              Material(
                color: ProfileColors.surfaceRaised,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () {
                    _onImageButtonPressed(ImageSource.gallery, context: context);
                  },
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ProfileColors.limeDim, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.picture_in_picture,
                      size: 18,
                      color: ProfileColors.lime,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Tap to change photo',
            style: TextStyle(
              color: ProfileColors.textSecondary.withValues(alpha: 0.9),
              fontSize: 12,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserInfoSection extends StatelessWidget {
  const _UserInfoSection({
    required this.nameController,
    required this.emailController,
    required this.phonenumberController,
    required this.bioController,
  });

  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phonenumberController;
  final TextEditingController bioController;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(9),
              topRight: Radius.circular(9),
            ),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                ProfileColors.headerGradientTop,
                ProfileColors.headerGradientMid,
                ProfileColors.headerGradientBottom,
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 3,
                height: 14,
                color: ProfileColors.lime,
              ),
              const SizedBox(width: 10),
              const Text(
                'USER INFO',
                style: TextStyle(
                  color: ProfileColors.textSecondary,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          child: Column(
            children: [
              _ProfileField(
                label: 'Display name',
                controller: nameController,
                icon: Icons.badge_outlined,
                readOnly: true,
              ),
              const SizedBox(height: 14),

              const SizedBox(height: 14),
              _ProfileField(
                label: 'Email',
                controller: emailController,
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                readOnly: true,
              ),
              const SizedBox(height: 14),

              const SizedBox(height: 14),
              _ProfileField(
                label: 'Phone Number',
                controller: phonenumberController,
                icon: Icons.phone,
              ),
              _ProfileField(
                label: 'Bio',
                controller: bioController,
                icon: Icons.notes_rounded,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
    this.readOnly = false
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: ProfileColors.textMuted,
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          style: TextStyle(
            color: readOnly ? ProfileColors.textSecondary : ProfileColors.textPrimary,
            fontSize: 14,
          ),
          cursorColor: ProfileColors.lime,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            prefixIcon: Icon(icon, size: 20, color: ProfileColors.textSecondary),
            filled: true,
            fillColor: ProfileColors.inputFill,
            enabledBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: ProfileColors.wireFrame, width: 1.5),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              borderSide: BorderSide(color: ProfileColors.limeDim, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class _SaveChangesButton extends StatelessWidget {
  const _SaveChangesButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                ProfileColors.saveGradientStart,
                ProfileColors.saveGradientMid,
                ProfileColors.saveGradientEnd,
              ],
            ),
            border: Border.all(color: ProfileColors.limeDim, width: 1),
            boxShadow: [
              BoxShadow(
                color: ProfileColors.lime.withValues(alpha: 0.15),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Center(
              child: Text(
                'Save changes',
                style: TextStyle(
                  color: ProfileColors.saveButtonText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileMenuTile extends StatelessWidget {
  const _ProfileMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _RetroFrame(
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: ProfileColors.lime),
        title: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: ProfileColors.textMuted),
      ),
    );
  }
}

class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: ProfileColors.textSecondary,
        backgroundColor: ProfileColors.surface,
        side: const BorderSide(color: ProfileColors.wireFrame, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.logout_rounded, size: 18, color: ProfileColors.signOutIcon),
          SizedBox(width: 8),
          Text(
            'Sign out',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
