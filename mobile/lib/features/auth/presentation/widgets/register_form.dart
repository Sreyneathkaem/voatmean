import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/utils/validators.dart';
import 'package:voatmean_mobile/core/widgets/custom_button.dart';
import 'package:voatmean_mobile/core/widgets/custom_text_field.dart';
import 'package:voatmean_mobile/features/auth/data/services/auth_service.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isSubmitting = false;

  void _onRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isSubmitting = true);
      
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();
      
      final user = await _authService.signUpWithEmail(email, password);
      
      if (!mounted) return;
      setState(() => _isSubmitting = false);

      if (user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('បង្កើតគណនីជោគជ័យ! សូមចូលប្រើប្រាស់។'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('ការបង្កើតគណនីមិនបានជោគជ័យ។ សូមព្យាយាមម្តងទៀត។'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _nameController,
            labelText: "Full Name",
            hintText: "John Doe",
            validator: (value) => Validators.validateRequired(value, "ឈ្មោះពេញ"),
            prefixIcon: const Icon(LucideIcons.user, size: 18),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _emailController,
            labelText: "Email",
            hintText: "example@mail.com",
            validator: Validators.validateEmail,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(LucideIcons.mail, size: 18),
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _passwordController,
            labelText: "Password",
            hintText: "••••••••",
            validator: Validators.validatePassword,
            obscureText: true,
            prefixIcon: const Icon(LucideIcons.lock, size: 18),
          ),
          const SizedBox(height: 32),
          CustomButton(
            text: "Sign Up",
            isLoading: _isSubmitting,
            onPressed: _onRegister,
          ),
        ],
      ),
    );
  }
}
