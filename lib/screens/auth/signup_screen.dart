import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/app_user.dart';
import '../../themes/app_theme.dart';
import '../../utils/validators.dart';
import '../../constants/app_constants.dart';
import '../home/main_shell.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  String _district = '';
  final List<String> _preferredProducts = [];
  UserRole _role = UserRole.buyer;
  bool _showDistricts = false;
  bool _showProducts = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _pwdCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_district.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select your district.')));
      return;
    }
    final ok = await context.read<AuthProvider>().signUp(
          email: _emailCtrl.text,
          password: _pwdCtrl.text,
          fullName: _nameCtrl.text,
          phoneNumber: _phoneCtrl.text,
          district: _district,
          role: _role,
          preferredProducts: _preferredProducts,
        );
    if (ok && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const MainShell(child: SizedBox())),
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
              const SizedBox(height: 20),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.eco, color: Colors.white, size: 28),
              ),
              const SizedBox(height: 14),
              const Text('Create Account',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              const Text('Join Smart Market today',
                  style:
                      TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 24),

              // Role
              Text('I am a',
                  style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.8)),
              const SizedBox(height: 8),
              Row(
                children: UserRole.values.map((r) {
                  final selected = _role == r;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _role = r),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? AppTheme.primary : Colors.white,
                          border: Border.all(
                              color: selected
                                  ? AppTheme.primary
                                  : AppTheme.border),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          r == UserRole.farmer ? 'Farmer' : 'Buyer',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: selected
                                ? Colors.white
                                : AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Full name',
                        prefixIcon: Icon(Icons.person_outline, size: 18),
                      ),
                      validator: (v) => validateRequired(v, 'Full name'),
                    ),
                    const SizedBox(height: 12),
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
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: 'Phone number (e.g. 0700123456)',
                        prefixIcon: Icon(Icons.phone_outlined, size: 18),
                      ),
                      validator: validatePhone,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _pwdCtrl,
                      obscureText: true,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        hintText: 'Password (min. 6 characters)',
                        prefixIcon: Icon(Icons.lock_outline, size: 18),
                      ),
                      validator: validatePassword,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('District', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => setState(() => _showDistricts = !_showDistricts),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: AppTheme.border),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.location_on_outlined, size: 18, color: AppTheme.textSecondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _district.isEmpty ? 'Select district' : _district,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _district.isEmpty ? const Color(0xFF9CA3AF) : AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                              if (_showDistricts)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: AppTheme.border),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.builder(
                                    itemCount: AppConstants.ugandaDistricts.length,
                                    itemBuilder: (_, i) {
                                      final d = AppConstants.ugandaDistricts[i];
                                      return InkWell(
                                        onTap: () => setState(() {
                                          _district = d;
                                          _showDistricts = false;
                                        }),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: _district == d ? AppTheme.primary.withOpacity(0.08) : null,
                                            border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
                                          ),
                                          child: Text(d, style: TextStyle(fontSize: 14, color: _district == d ? AppTheme.primary : AppTheme.textPrimary, fontWeight: _district == d ? FontWeight.w500 : FontWeight.normal)),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Preferred products', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                              const SizedBox(height: 6),
                              GestureDetector(
                                onTap: () => setState(() => _showProducts = !_showProducts),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: AppTheme.border),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.inventory_2_outlined, size: 18, color: AppTheme.textSecondary),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _preferredProducts.isEmpty ? 'Select products' : _preferredProducts.join(', '),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: _preferredProducts.isEmpty ? const Color(0xFF9CA3AF) : AppTheme.textPrimary,
                                          ),
                                        ),
                                      ),
                                      const Icon(Icons.keyboard_arrow_down, color: AppTheme.textSecondary),
                                    ],
                                  ),
                                ),
                              ),
                              if (_showProducts)
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  height: 180,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: AppTheme.border),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListView.builder(
                                    itemCount: AppConstants.marketProducts.length,
                                    itemBuilder: (_, i) {
                                      final product = AppConstants.marketProducts[i];
                                      final selected = _preferredProducts.contains(product);
                                      return InkWell(
                                        onTap: () => setState(() {
                                          if (selected) {
                                            _preferredProducts.remove(product);
                                          } else {
                                            if (_preferredProducts.length < 5) {
                                              _preferredProducts.add(product);
                                            }
                                          }
                                        }),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                          decoration: BoxDecoration(
                                            color: selected ? AppTheme.primary.withOpacity(0.08) : null,
                                            border: Border(bottom: BorderSide(color: AppTheme.border, width: 0.5)),
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(child: Text(product, style: TextStyle(fontSize: 14, color: selected ? AppTheme.primary : AppTheme.textPrimary))),
                                              if (selected) const Icon(Icons.check, size: 16, color: AppTheme.primary),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (auth.error.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(auth.error,
                    style: const TextStyle(
                        color: AppTheme.destructive, fontSize: 13)),
              ],

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: auth.isLoading ? null : _handleSignUp,
                child: auth.isLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Create Account'),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Already have an account?  ',
                      style: TextStyle(
                          color: AppTheme.textSecondary, fontSize: 14)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text('Sign In',
                        style: TextStyle(
                            color: AppTheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14)),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
