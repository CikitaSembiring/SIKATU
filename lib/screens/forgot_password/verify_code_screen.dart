import 'package:flutter/material.dart';
import 'package:sikatu/theme/app_colors.dart';
import 'package:sikatu/widgets/primary_button.dart';
// --- UPDATE IMPORT INI ---
import 'package:sikatu/screens/forgot_password/set_new_password_screen.dart';

class VerifyCodeScreen extends StatelessWidget {
  final String email;
  const VerifyCodeScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                'Check your email',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                  color: AppColors.darkText,
                ),
              ),
              const SizedBox(height: 15),
              RichText(
                text: TextSpan(
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  children: [
                    const TextSpan(text: 'We sent a reset link to '),
                    TextSpan(text: email, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                    const TextSpan(text: '\nenter 5 digit code that mentioned in the email'),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Input Kode (Simulasi Tampilan)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(5, (index) => _buildCodeBox(context)),
              ),

              const SizedBox(height: 40),

              PrimaryButton(
                text: 'Verify Code',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SetNewPasswordScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                    "Haven't got the email yet? Resend email",
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14)
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCodeBox(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: TextField(
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          decoration: InputDecoration(
            border: InputBorder.none,
            counterText: "",
          ),
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}