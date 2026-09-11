import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import 'package:voatmean_mobile/core/constants/app_colors.dart';
import 'package:voatmean_mobile/core/constants/app_strings.dart';
import 'package:voatmean_mobile/core/utils/validators.dart';
import 'package:voatmean_mobile/core/widgets/custom_button.dart';
import 'package:voatmean_mobile/core/widgets/custom_text_field.dart';

class LoginForm extends StatefulWidget {
  final Function(DetectedRole role, String email, String password) onSubmit;
  final Function(String provider) onSocialLogin;

  const LoginForm({
    super.key,
    required this.onSubmit,
    required this.onSocialLogin,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController =
      TextEditingController(text: 'sok.samnang@school.edu');
  final _passwordController = TextEditingController(text: 'password123');

  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isSubmitting = false;

  DetectedRole? _detectedRole;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
    _onEmailChanged();
  }

  @override
  void dispose() {
    _emailController.removeListener(_onEmailChanged);
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onEmailChanged() {
    final role = Validators.detectRoleFromEmail(_emailController.text);
    if (_detectedRole != role) {
      setState(() => _detectedRole = role);
    }
  }

  void _handleFormSubmit() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final role = _detectedRole ?? DetectedRole.teacher;

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      widget.onSubmit(role, email, password);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Email Field
          CustomTextField(
            controller: _emailController,
            labelText: AppStrings.emailLabel,
            hintText: AppStrings.emailHint,
            keyboardType: TextInputType.emailAddress,
            validator: Validators.validateEmail,
            prefixIcon: const Icon(LucideIcons.mail,
                size: 18, color: AppColors.textSubtle),
            trailingLabelWidget: _buildRoleBadge(),
          ),
          const SizedBox(height: 14),

          // 2. Password Field
          CustomTextField(
            controller: _passwordController,
            labelText: AppStrings.passwordLabel,
            hintText: AppStrings.passwordHint,
            obscureText: _obscurePassword,
            validator: Validators.validatePassword,
            prefixIcon: const Icon(LucideIcons.lock,
                size: 18, color: AppColors.textSubtle),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? LucideIcons.eyeOff : LucideIcons.eye,
                size: 18,
                color: AppColors.textSubtle,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
          const SizedBox(height: 10),

          // 3. Remember Me & Forgot Password
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: _rememberMe,
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4)),
                      side: const BorderSide(color: AppColors.borderHover),
                      onChanged: (v) => setState(() => _rememberMe = v ?? true),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppStrings.rememberMe,
                    style: GoogleFonts.kantumruyPro(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'តំណភ្ជាប់កំណត់ពាក្យសម្ងាត់ត្រូវបានផ្ញើ',
                        style: GoogleFonts.kantumruyPro(),
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(
                  AppStrings.forgotPassword,
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 4. Submit Button
          CustomButton(
            text: AppStrings.signInButton,
            isLoading: _isSubmitting,
            icon: const Icon(LucideIcons.logIn, size: 16),
            onPressed: _handleFormSubmit,
          ),
          const SizedBox(height: 16),

          // 5. Divider
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.border)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  AppStrings.orSignInWith,
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 11,
                    color: AppColors.textSubtle,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.border)),
            ],
          ),
          const SizedBox(height: 16),

          // 6. Google Sign-In Button
          CustomButton(
            text: AppStrings.googleSignIn,
            isOutlined: true,
            backgroundColor: Colors.white,
            textColor: AppColors.textSecondary,
            icon: _buildGoogleIcon(),
            onPressed: () => widget.onSocialLogin('Google'),
            height: 44,
          ),
          const SizedBox(height: 10),

          // 7. Facebook Sign-In Button
          CustomButton(
            text: AppStrings.facebookSignIn,
            isOutlined: true,
            backgroundColor: Colors.white,
            textColor: AppColors.textSecondary,
            icon: const Icon(Icons.facebook,
                size: 18, color: AppColors.facebook),
            onPressed: () => widget.onSocialLogin('Facebook'),
            height: 44,
          ),
        ],
      ),
    );
  }

  Widget? _buildRoleBadge() {
    if (_detectedRole == null) return null;

    Color bg;
    Color border;
    Color textColor;
    IconData icon;
    String label;

    switch (_detectedRole!) {
      case DetectedRole.dual:
        bg = AppColors.purpleBg;
        border = AppColors.purpleBorder;
        textColor = AppColors.purpleText;
        icon = LucideIcons.layers;
        label = AppStrings.roleDual;
        break;
      case DetectedRole.admin:
        bg = AppColors.blueBg;
        border = AppColors.blueBorder;
        textColor = AppColors.blueText;
        icon = LucideIcons.shield;
        label = AppStrings.roleAdmin;
        break;
      case DetectedRole.teacher:
        bg = AppColors.emeraldBg;
        border = AppColors.emeraldBorder;
        textColor = AppColors.emeraldText;
        icon = LucideIcons.graduationCap;
        label = AppStrings.roleTeacher;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: GoogleFonts.kantumruyPro(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return SizedBox(
      width: 18,
      height: 18,
      child: CustomPaint(painter: _GoogleIconPainter()),
    );
  }
}

class _GoogleIconPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height), -0.5, 1.5, true, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height), 1.0, 1.5, true, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height), 2.5, 1.2, true, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height), 3.7, 1.4, true, paint);

    paint.color = Colors.white;
    canvas.drawCircle(
        Offset(size.width / 2, size.height / 2), size.width * 0.32, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
