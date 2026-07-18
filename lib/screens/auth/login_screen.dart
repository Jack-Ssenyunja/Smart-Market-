import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_market/screens/home/home_screen.dart';
import '../../providers/auth_provider.dart';
import '../../themes/app_theme.dart';
import '../../utils/validators.dart';
import '../home/main_shell.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _showPassword = false;
  bool _usePhone = false;
  bool _otpSent = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleEmailLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithEmail(_emailCtrl.text, _passwordCtrl.text);
    if (ok && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell(child: HomeScreen())),
        (_) => false,
      );
    }
  }

  Future<void> _handleSendOtp() async {
    if (_phoneCtrl.text.trim().length < 9) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Enter a valid phone number.')));
      return;
    }
    final auth = context.read<AuthProvider>();
    String phone = _phoneCtrl.text.trim();
    if (!phone.startsWith('+')) phone = '+256${phone.replaceFirst(RegExp('^0'), '')}';
    await auth.sendOtp(phone, onCodeSent: (_) {
      if (mounted) setState(() => _otpSent = true);
    });
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpCtrl.text.trim().length < 4) return;
    final auth = context.read<AuthProvider>();
    final ok = await auth.verifyOtp(_otpCtrl.text.trim());
    if (ok && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell(child: HomeScreen())),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Logo
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.primary,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.eco, color: Colors.white, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Welcome Back',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Sign in to your Smart Market account',
                  style: TextStyle(fontSize: 14, color: AppTheme.textSecondary)),
              const SizedBox(height: 32),

              // Tab toggle
              Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(71, 59, 128, 53),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(4),
                child: Row(
                  children: [
                    _TabButton(
                        label: 'Email',
                        active: !_usePhone,
                        onTap: () => setState(() {
                              _usePhone = false;
                              _otpSent = false;
                              context.read<AuthProvider>().clearError();
                            })),
                    _TabButton(
                        label: 'Phone / OTP',
                        active: _usePhone,
                        onTap: () => setState(() {
                              _usePhone = true;
                              _otpSent = false;
                              context.read<AuthProvider>().clearError();
                            })),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              if (!_usePhone) ...[
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          hintText: 'Email address',
                          prefixIcon: Icon(Icons.mail_outline, size: 18),
                        ),
                        validator: validateEmail,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: !_showPassword,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleEmailLogin(),
                        decoration: InputDecoration(
                          hintText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline, size: 18),
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                                size: 18),
                            onPressed: () =>
                                setState(() => _showPassword = !_showPassword),
                          ),
                        ),
                        validator: validatePassword,
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () async {
                            if (_emailCtrl.text.isNotEmpty) {
                              await auth.sendPasswordReset(_emailCtrl.text);
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Password reset email sent!')),
                                );
                              }
                            }
                          },
                          child: const Text('Forgot password?',
                              style: TextStyle(
                                  fontSize: 12, color: AppTheme.primary)),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else ...[
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  enabled: !_otpSent,
                  decoration: const InputDecoration(
                    hintText: 'Phone number (e.g. 0700123456)',
                    prefixIcon: Icon(Icons.phone_outlined, size: 18),
                  ),
                ),
                if (_otpSent) ...[
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    decoration: const InputDecoration(
                      hintText: 'Enter OTP code',
                      prefixIcon: Icon(Icons.lock_outline, size: 18),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text('OTP sent to ${_phoneCtrl.text}',
                      style: const TextStyle(
                          fontSize: 12, color: AppTheme.textSecondary)),
                ],
              ],

              if (auth.error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(auth.error,
                    style: const TextStyle(color: AppTheme.destructive, fontSize: 13)),
              ],

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: auth.isLoading
                    ? null
                    : _usePhone
                        ? _otpSent ? _handleVerifyOtp : _handleSendOtp
                        : _handleEmailLogin,
                child: auth.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(_usePhone
                        ? _otpSent ? 'Verify OTP' : 'Send OTP'
                        : 'Sign In'),
              ),

              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account?  ",
                      style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const SignupScreen())),
                    child: const Text('Sign Up',
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton(
      {required this.label, required this.active, required this.onTap});
  final String label;
  final bool active;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: active ? Colors.white : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: active ? AppTheme.textPrimary : AppTheme.textSecondary)),
          ),
        ),
      );
}
