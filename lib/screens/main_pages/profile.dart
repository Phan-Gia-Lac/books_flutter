import 'package:books_flutter/AppRoutes.dart';
import 'package:books_flutter/theme/app_theme.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController(text: 'Alex Reader');
  final _usernameController = TextEditingController(text: '@alex_reads');
  final _emailController = TextEditingController(text: 'alex@books.app');
  final _bioController = TextEditingController(
    text: 'Collector of paperbacks and late-night chapters.',
  );

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _onSaveChanges() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Changes saved'),
        backgroundColor: ProfileColors.surfaceRaised,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: ProfileColors.limeDim, width: 1),
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
                child: _AvatarSection(onChangePhoto: () {}),
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
                          usernameController: _usernameController,
                          emailController: _emailController,
                          bioController: _bioController,
                        ),
                      ),
                      const SizedBox(height: 14),
                      _SaveChangesButton(onPressed: _onSaveChanges),
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

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({required this.onChangePhoto});

  final VoidCallback onChangePhoto;

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
                  boxShadow: [
                    BoxShadow(
                      color: ProfileColors.lime.withValues(alpha: 0.08),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  size: 56,
                  color: ProfileColors.textMuted,
                ),
              ),
              Material(
                color: ProfileColors.surfaceRaised,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onChangePhoto,
                  customBorder: const CircleBorder(),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: ProfileColors.limeDim, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
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
    required this.usernameController,
    required this.emailController,
    required this.bioController,
  });

  final TextEditingController nameController;
  final TextEditingController usernameController;
  final TextEditingController emailController;
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
              ),
              const SizedBox(height: 14),
              _ProfileField(
                label: 'Username',
                controller: usernameController,
                icon: Icons.alternate_email_rounded,
              ),
              const SizedBox(height: 14),
              _ProfileField(
                label: 'Email',
                controller: emailController,
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 14),
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
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;

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
          style: const TextStyle(
            color: ProfileColors.textPrimary,
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
