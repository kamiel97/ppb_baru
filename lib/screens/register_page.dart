import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class _RegisterTheme {
  static const Color primary = Color(0xFF7A1025);
  static const Color background = Color(0xFFFCF8F9);
  static const Color surface = Colors.white;

  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color inputBackground = Color(0xFFF8FAFC);
  static const Color border = Color(0xFFE2E8F0);

  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF16A34A);
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();

  String? gender;
  bool isLoading = false;

 
  // REGISTER

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (gender == null) {
      _showSnackBar(
        message: 'Silakan pilih jenis kelamin.',
        isSuccess: false,
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse('https://sijala.biz.id/api/v1/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': nameController.text.trim(),
          'gender': gender,
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
        }),
      );

      final data = jsonDecode(response.body);

      // Registrasi berhasil
      if (response.statusCode == 200 || response.statusCode == 201) {
        if (data['status'] == true) {
          if (!mounted) return;

          _showSnackBar(
            message: data['message'] ?? 'Registrasi berhasil. Silakan login.',
            isSuccess: true,
          );

          Navigator.pop(context);
        } else {
          throw Exception(data['message'] ?? 'Registrasi gagal.');
        }
      } else {
        final message = data['message'] ?? 'Registrasi gagal.';
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
        backgroundColor: isSuccess
            ? _RegisterTheme.success
            : const Color.fromARGB(255, 53, 123, 229),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
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

 
  // DISPOSE
 
  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  
  // BUILD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _RegisterTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),

            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
           
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center, 
                    children: [
                      const SizedBox(height: 10),
                      
                 
                      Text(
                        'Buat Akun',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: _RegisterTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Lengkapi data untuk membuat akun baru.',
                        textAlign: TextAlign.left,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: _RegisterTheme.textSecondary,
                        ),
                      ),

                      const SizedBox(height: 30),

                
                      _buildNameField(),
                      const SizedBox(height: 20),

                      _buildGenderField(),
                      const SizedBox(height: 20),

                      _buildEmailField(),
                      const SizedBox(height: 20),

                      _buildPhoneField(),

                      const SizedBox(height: 32),

                   
                      _buildSubmitButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

 
  // TOP BAR

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color.fromARGB(255, 20, 26, 36),
            ),
          ),
          const SizedBox(width: 2),
        ],
      ),
    );
  }


  // NAME

  Widget _buildNameField() {
    return _buildTextField(
      label: 'Nama Lengkap',
      hint: 'Masukkan nama lengkap',
      icon: Icons.person_outline,
      controller: nameController,
      textInputAction: TextInputAction.next,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nama wajib diisi';
        }
        return null;
      },
    );
  }

  // GENDER
  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Jenis Kelamin',
          style: GoogleFonts.plusJakartaSans(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: _RegisterTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          initialValue: gender,
          onChanged: isLoading
              ? null
              : (value) {
                  setState(() {
                    gender = value;
                  });
                },
          items: const [
            DropdownMenuItem(
              value: 'L',
              child: Text('Laki-laki'),
            ),
            DropdownMenuItem(
              value: 'P',
              child: Text('Perempuan'),
            ),
          ],
          decoration: InputDecoration(
            hintText: 'Pilih jenis kelamin',
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: _RegisterTheme.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.wc_outlined,
              color: Color.fromARGB(255, 25, 120, 184),
              size: 20,
            ),
            filled: true,
            fillColor: _RegisterTheme.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _RegisterTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _RegisterTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 22, 106, 155),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 53, 135, 229),
              ),
            ),
          ),
          validator: (value) {
            if (value == null) {
              return 'Jenis kelamin wajib dipilih';
            }
            return null;
          },
        ),
      ],
    );
  }

  // EMAIL

  Widget _buildEmailField() {
    return _buildTextField(
      label: 'Email',
      hint: 'nama@email.com',
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
    );
  }

  // PHONE

  Widget _buildPhoneField() {
    return _buildTextField(
      label: 'Nomor WhatsApp',
      hint: '08xxxxxxxxxx',
      icon: Icons.phone_outlined,
      controller: phoneController,
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      onFieldSubmitted: (_) {
        if (!isLoading) {
          register();
        }
      },
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Nomor WhatsApp wajib diisi';
        }
        return null;
      },
    );
  }

 
  // TEXT FIELD

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
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
            color: _RegisterTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          enabled: !isLoading,
          onFieldSubmitted: onFieldSubmitted,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: _RegisterTheme.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: GoogleFonts.plusJakartaSans(
              fontSize: 14,
              color: _RegisterTheme.textMuted,
            ),
            prefixIcon: Icon(
              icon,
              color: const Color.fromARGB(255, 19, 117, 173),
              size: 20,
            ),
            filled: true,
            fillColor: _RegisterTheme.inputBackground,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _RegisterTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _RegisterTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 20, 97, 185),
                width: 1.5,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 30, 127, 206),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color.fromARGB(255, 53, 173, 229),
                width: 1.5,
              ),
            ),
            errorStyle: GoogleFonts.plusJakartaSans(
              fontSize: 11,
              color: const Color.fromARGB(255, 53, 150, 229),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  // SUBMIT BUTTON
  
  
  Widget _buildSubmitButton() {
    return SizedBox(
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : register,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 37, 127, 201),
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
                    'Daftar Sekarang',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }
}