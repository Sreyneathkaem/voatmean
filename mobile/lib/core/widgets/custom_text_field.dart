import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label; // Added to support new modal usage
  final String? hint; // Added to support new modal usage
  final String? labelText;
  final String? hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final Widget? trailingLabelWidget;
  final bool isRequired;

  const CustomTextField({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.labelText,
    this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.trailingLabelWidget,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveLabel = label ?? labelText ?? '';
    final effectiveHint = hint ?? hintText ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (effectiveLabel.isNotEmpty)
              Flexible(
                child: Text(
                  effectiveLabel,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.kantumruyPro(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            if (trailingLabelWidget != null) trailingLabelWidget!,
          ],
        ),
        if (effectiveLabel.isNotEmpty) const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            hintText: effectiveHint,
            hintStyle: GoogleFonts.kantumruyPro(
              fontSize: 12,
              color: AppColors.textSubtle,
            ),
            filled: true,
            fillColor: AppColors.inputBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
