import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_appl_latihan/routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class _LoginTheme {
  static const Color primary = Color(0xFF1976D2);
  static const Color primaryDark = Color(0xFF0D47A1);

  static const Color background = Color(0xFFF5F9FF);
  static const Color white = Colors.white;

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color inputBackground = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF16A34A);
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

 
  // LOGIN
 
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://sijala.biz.id/api/v1/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': emailController.text.trim(),
          'password': passwordController.text,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        final token = data['data']['token'];

        if (token == null) throw Exception('Token tidak ditemukan.');

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', token.toString());

        if (data['data'] != null) {
          await prefs.setString('user', jsonEncode(data['data']));
        }

        if (!mounted) return;

        _showSnackBar(message: 'Login berhasil!', isSuccess: true);
        context.go(AppRoutes.dashboard);
      } else {
        final message = data['message'] ?? 'Email atau password salah.';
        throw Exception(message);
      }
    } catch (e) {
      if (!mounted) return;

      _showSnackBar(
        message: e.toString().replaceFirst('Exception: ', ''),
        isSuccess: false,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  
  // SNACKBAR
  
  void _showSnackBar({required String message, required bool isSuccess}) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isSuccess ? _LoginTheme.success : _LoginTheme.error,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle_outline : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }


  // BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _LoginTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
  
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
     
                _buildHeader(),
                const SizedBox(height: 40),

                _buildInputField(
                  label: 'Email',
                  hint: 'Masukkan email',
                  icon: Icons.email_outlined,
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email wajib diisi';
                    }
                    if (!value.contains('@')) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                _buildInputField(
                  label: 'Password',
                  hint: 'Masukkan password',
                  icon: Icons.lock_outline,
                  controller: passwordController,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!isLoading) login();
                  },
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                    icon: Icon(
                      obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: _LoginTheme.textMuted,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password wajib diisi';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 32),

                _buildLoginButton(),

                const SizedBox(height: 24),

                _buildRegisterSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  // HEADER / BRANDING

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center, 
      children: [
        Text(
          'CDG SURVEI',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: _LoginTheme.primary,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'login untuk info lebih lanjut',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: _LoginTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'cdg survey website for client to survey locations',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 12,
            color: _LoginTheme.textMuted,
          ),
        ),
      ],
    );
  }


  // INPUT FIELD

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _LoginTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          enabled: !isLoading,
          onFieldSubmitted: onFieldSubmitted,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            color: _LoginTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: _LoginTheme.textMuted,
            ),
            prefixIcon: Icon(icon, color: _LoginTheme.primary, size: 20),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: _LoginTheme.inputBackground,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 16), 
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _LoginTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _LoginTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _LoginTheme.primary, width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _LoginTheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _LoginTheme.error, width: 1.5),
            ),
            errorStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: _LoginTheme.error,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }


  // LOGIN BUTTON

  Widget _buildLoginButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : login,
        style: ElevatedButton.styleFrom(
          backgroundColor: _LoginTheme.primary,
          disabledBackgroundColor: _LoginTheme.primary.withOpacity(0.5),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Login',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
                ],
              ),
      ),
    );
  }

  // REGISTER SECTION

  Widget _buildRegisterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Belum punya akun?',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            color: _LoginTheme.textSecondary,
          ),
        ),
        const SizedBox(width: 5),
        InkWell(
          borderRadius: BorderRadius.circular(5),
          onTap: () {
            context.push(AppRoutes.register);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 2),
            child: Text(
              'Daftar',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: _LoginTheme.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}