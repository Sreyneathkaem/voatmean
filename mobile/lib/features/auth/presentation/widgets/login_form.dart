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
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;

  DetectedRole? _detectedRole;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onEmailChanged);
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

    widget.onSubmit(role, email, password);
    
    // We don't reset _isSubmitting here because the parent LoginScreen 
    // will handle the loading state or navigation.
    // However, to be safe if login fails:
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _isSubmitting = false);
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
          const SizedBox(height: 20),

          // 4. Submit Button
          CustomButton(
            text: AppStrings.signInButton,
            isLoading: _isSubmitting,
            icon: const Icon(LucideIcons.logIn, size: 16),
            onPressed: _handleFormSubmit,
          ),
          const SizedBox(height: 24),

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
          const SizedBox(height: 24),

          // 6. Google Sign-In Button
          CustomButton(
            text: AppStrings.googleSignIn,
            isOutlined: true,
            backgroundColor: Colors.white,
            textColor: AppColors.textSecondary,
            icon: _buildGoogleIcon(),
            onPressed: () => widget.onSocialLogin('Google'),
            height: 52,
          ),
          const SizedBox(height: 16),

          // Quick Demo Shortcuts
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.slateBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.sparkles, size: 14, color: AppColors.primary),
                    const SizedBox(width: 6),
                    Text(
                      'ចូលសាកល្បងរហ័ស (Quick Demo):',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _emailController.text = 'admin@voatmean.edu.kh';
                          _passwordController.text = 'admin123';
                          _handleFormSubmit();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.blueBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.blueBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.shield, size: 14, color: AppColors.blueText),
                              const SizedBox(width: 6),
                              Text(
                                'Admin (គ្រប់គ្រង)',
                                style: GoogleFonts.kantumruyPro(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.blueText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          _emailController.text = 'teacher@voatmean.edu.kh';
                          _passwordController.text = 'teacher123';
                          _handleFormSubmit();
                        },
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.emeraldBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.emeraldBorder),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(LucideIcons.graduationCap, size: 14, color: AppColors.emeraldText),
                              const SizedBox(width: 6),
                              Text(
                                'Teacher (គ្រូ)',
                                style: GoogleFonts.kantumruyPro(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.emeraldText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 8. Register Link
          Center(
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/register'),
              child: RichText(
                text: TextSpan(
                  text: 'ចូលប្រើប្រាស់លើកដំបូង? ',
                  style: GoogleFonts.kantumruyPro(fontSize: 12, color: AppColors.textMuted),
                  children: [
                    TextSpan(
                      text: 'កំណត់ពាក្យសម្ងាត់',
                      style: GoogleFonts.kantumruyPro(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget? _buildRoleBadge() {
    if (_detectedRole == null || _emailController.text.isEmpty) return null;

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
      width: 20,
      height: 20,
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
