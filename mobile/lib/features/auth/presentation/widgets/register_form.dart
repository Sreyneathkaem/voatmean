import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/utils/validators.dart';
import 'package:voatmean_mobile/core/widgets/custom_button.dart';
import 'package:voatmean_mobile/core/widgets/custom_text_field.dart';
import '../../data/services/auth_service.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _authService = AuthService();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  void _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final success = await _authService.register(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (success) {
      _showToast('កំណត់ពាក្យសម្ងាត់ជោគជ័យ! សូមចូលប្រើប្រាស់។', isError: false);
      Navigator.pop(context);
    } else {
      _showToast('មិនអាចកំណត់ពាក្យសម្ងាត់បានទេ។ សូមពិនិត្យអុីមែលម្តងទៀត។');
    }
  }

  void _showToast(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.kantumruyPro(fontSize: 12)),
        backgroundColor: isError ? AppColors.danger : Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            labelText: 'អុីមែល (Email)',
            hintText: 'បញ្ចូលអុីមែលដែលបានចុះឈ្មោះ',
            validator: Validators.validateEmail,
            prefixIcon: const Icon(LucideIcons.mail, size: 18),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _passwordController,
            labelText: 'ពាក្យសម្ងាត់ថ្មី (New Password)',
            hintText: '••••••••',
            obscureText: _obscurePassword,
            validator: Validators.validatePassword,
            prefixIcon: const Icon(LucideIcons.lock, size: 18),
          ),
          const SizedBox(height: 16),
          CustomTextField(
            controller: _confirmPasswordController,
            labelText: 'បញ្ជាក់ពាក្យសម្ងាត់ (Confirm Password)',
            hintText: '••••••••',
            obscureText: _obscurePassword,
            validator: (val) {
              if (val != _passwordController.text) return 'ពាក្យសម្ងាត់មិនដូចគ្នាទេ';
              return null;
            },
            prefixIcon: const Icon(LucideIcons.shieldCheck, size: 18),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 18,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'កំណត់ពាក្យសម្ងាត់',
            onPressed: _handleSubmit,
            isLoading: _isSubmitting,
          ),
        ],
      ),
    );
  }
}
