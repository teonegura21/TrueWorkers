import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _cuiController = TextEditingController();
  
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptTerms = false;
  bool _isCompany = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _companyNameController.dispose();
    _cuiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Creează Cont'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                
                // Welcome message
                _buildWelcomeMessage(),
                
                const SizedBox(height: 48),
                
                // Account type selection
                _buildAccountTypeSelection(),
                
                const SizedBox(height: 32),
                
                // Registration form
                _buildRegistrationForm(),
                
                const SizedBox(height: 24),
                
                // Terms and conditions
                _buildTermsCheckbox(),
                
                const SizedBox(height: 32),
                
                // Register button
                _buildRegisterButton(),
                
                const SizedBox(height: 32),
                
                // Login link
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeMessage() {
    return Column(
      children: [
        Text(
          'Creează-ți contul',
          style: GoogleFonts.lato(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: AppTheme.onSurfaceColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isCompany 
            ? 'Alătură-te platformei ca meșter profesionist' 
            : 'Găsește meșteri de încredere pentru lucrările tale',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.onSurfaceSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildAccountTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tip Cont',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildAccountTypeOption(
                'Client',
                Icons.person,
                !_isCompany,
                () {
                  setState(() {
                    _isCompany = false;
                  });
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildAccountTypeOption(
                'Meșter',
                Icons.business,
                _isCompany,
                () {
                  setState(() {
                    _isCompany = true;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAccountTypeOption(
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _isCompany ? 'Informații Companie' : 'Informații Personale',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        
        // Name field
        _buildTextFormField(
          controller: _nameController,
          label: _isCompany ? 'Nume Reprezentant' : 'Nume Complet',
          hint: _isCompany ? 'Introdu numele reprezentantului' : 'Introdu numele tău complet',
          icon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Te rog să introduci numele';
            }
            if (value.trim().split(' ').length < 2) {
              return 'Te rog să introduci numele complet';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Email field
        _buildTextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          label: 'Email',
          hint: 'Introdu adresa de email',
          icon: Icons.email_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Te rog să introduci emailul';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Te rog să introduci un email valid';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Phone field
        _buildTextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          label: 'Telefon',
          hint: 'Introdu numărul de telefon',
          icon: Icons.phone_outlined,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Te rog să introduci numărul de telefon';
            }
            if (value.length < 10) {
              return 'Te rog să introduci un număr de telefon valid';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        if (_isCompany) ...[
          // Company Name field
          _buildTextFormField(
            controller: _companyNameController,
            label: 'Nume Companie',
            hint: 'Introdu numele companiei tale',
            icon: Icons.business_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Te rog să introduci numele companiei';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
          
          // CUI field
          _buildTextFormField(
            controller: _cuiController,
            keyboardType: TextInputType.number,
            label: 'CUI',
            hint: 'Introdu codul unic de înregistrare',
            icon: Icons.badge_outlined,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Te rog să introduci CUI-ul';
              }
              if (value.length < 5) {
                return 'Te rog să introduci un CUI valid';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 16),
        ],
        
        // Password field
        _buildTextFormField(
          controller: _passwordController,
          obscureText: !_isPasswordVisible,
          label: 'Parolă',
          hint: 'Creează o parolă sigură',
          icon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _isPasswordVisible = !_isPasswordVisible;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Te rog să introduci parola';
            }
            if (value.length < 8) {
              return 'Parola trebuie să aibă cel puțin 8 caractere';
            }
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              return 'Parola trebuie să conțină litere mari, mici și cifre';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Confirm Password field
        _buildTextFormField(
          controller: _confirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          label: 'Confirmă Parola',
          hint: 'Introdu din nou parola',
          icon: Icons.lock_outline,
          suffixIcon: IconButton(
            icon: Icon(
              _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Te rog să confirmi parola';
            }
            if (value != _passwordController.text) {
              return 'Parolele nu se potrivesc';
            }
            return null;
          },
          onFieldSubmitted: (_) => _handleRegister(),
        ),
      ],
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      textInputAction: onFieldSubmitted != null ? TextInputAction.done : TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
          activeColor: AppTheme.primaryColor,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
                children: [
                  const TextSpan(text: 'Accept '),
                  TextSpan(
                    text: 'Termenii și Condițiile',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      // TODO: Navigate to terms and conditions screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navigare la Termeni și Condiții'),
                        ),
                      );
                    },
                  ),
                  const TextSpan(text: ' și '),
                  TextSpan(
                    text: 'Politica de Confidențialitate',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w500,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()..onTap = () {
                      // TODO: Navigate to privacy policy screen
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navigare la Politică de Confidențialitate'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _acceptTerms ? _handleRegister : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 8,
          shadowColor: AppTheme.primaryColor.withValues(alpha: 0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Creează Cont'),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Ai deja cont? ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurfaceSecondary,
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushNamed(context, '/login');
          },
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8),
          ),
          child: const Text('Intră în cont'),
        ),
      ],
    );
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate() && _acceptTerms) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      await Future.delayed(const Duration(milliseconds: 1500));

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isCompany 
                ? 'Cont de meșter creat cu succes!' 
                : 'Cont de client creat cu succes!',
            ),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Navigate to verification flow or main app
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/main',
          (route) => false,
        );
      }
    } else if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Te rog să accepți Termenii și Condițiile'),
          backgroundColor: AppTheme.warningColor,
        ),
      );
    }
  }
}
