import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:voatmean_mobile/core/utils/validators.dart';
import 'package:voatmean_mobile/core/widgets/custom_button.dart';
import 'package:voatmean_mobile/core/widgets/custom_text_field.dart';

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

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      // Handle register logic
      debugPrint("Registering ${_nameController.text}");
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
            onPressed: _onRegister,
          ),
        ],
      ),
    );
  }
}
