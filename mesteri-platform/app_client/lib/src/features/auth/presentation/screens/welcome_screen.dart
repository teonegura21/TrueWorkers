import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/services/comprehensive_service.dart';
import '../../../../core/network/api_client.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = false;
  bool _showEmailAuth = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isLogin = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDarkMode
                ? [
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                    const Color(0xFF0F3460),
                  ]
                : [
                    MesteriColors.primaryLight,
                    Colors.white,
                    MesteriColors.background,
                  ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 48.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: size.height * 0.08),
                  _buildAnimatedLogo(),
                  const SizedBox(height: 48),
                  _buildBrandingSection(),
                  const SizedBox(height: 64),
                  if (!_showEmailAuth) ...[
                    _buildGoogleSignInButton(),
                    const SizedBox(height: 16),
                    _buildDivider(),
                    const SizedBox(height: 16),
                    _buildEmailPasswordButton(),
                  ] else ...[
                    _buildEmailAuthForm(),
                  ],
                  const SizedBox(height: 24),
                  if (!_showEmailAuth) _buildFeaturesList(),
                  const SizedBox(height: 32),
                  _buildFooter(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: MesteriColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: MesteriColors.primary.withValues(alpha: 0.4),
                blurRadius: 30,
                spreadRadius: 5,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.construction_rounded,
            size: 64,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildBrandingSection() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            Text(
              'True Workers',
              style: GoogleFonts.poppins(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                foreground: Paint()
                  ..shader = LinearGradient(
                    colors: [
                      MesteriColors.primary,
                      MesteriColors.primaryDark,
                    ],
                  ).createShader(const Rect.fromLTWH(0, 0, 300, 70)),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Îndeplinim dorința dumneavoastră de a colabora doar cu profesioniști verificați',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 18,
                color: MesteriColors.onSurfaceSecondary,
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: MesteriColors.primaryUltraLowOpacity,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: MesteriColors.primaryLowOpacity,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: MesteriColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.verified,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'De încredere • Verificat • Profesionist',
                    style: GoogleFonts.lato(
                      fontSize: 12,
                      color: MesteriColors.primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          child: OutlinedButton(
            onPressed: _isLoading ? null : _handleGoogleSignIn,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: MesteriColors.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
              side: BorderSide(
                color: MesteriColors.primary,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(MesteriColors.primary),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.network(
                        'https://www.gstatic.com/firebasejs/ui/2.0.0/images/auth/google.svg',
                        height: 24,
                        width: 24,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: MesteriColors.primaryLowOpacity,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.g_mobiledata,
                              size: 18,
                              color: MesteriColors.primary,
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Continuă cu Google',
                        style: GoogleFonts.lato(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: MesteriColors.onSurface,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: MesteriColors.outline,
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'SAU',
            style: GoogleFonts.lato(
              fontSize: 12,
              color: MesteriColors.onSurfaceTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Divider(
            color: MesteriColors.outline,
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildEmailPasswordButton() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: OutlinedButton(
          onPressed: () {
            setState(() {
              _showEmailAuth = true;
            });
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: MesteriColors.primary,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
            side: BorderSide(
              color: MesteriColors.primary,
              width: 2,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.email_outlined,
                color: MesteriColors.primary,
                size: 24,
              ),
              const SizedBox(width: 16),
              Text(
                'Continuă cu Email',
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: MesteriColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailAuthForm() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                color: MesteriColors.primaryUltraLowOpacity,
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLogin = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: _isLogin ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: _isLogin
                              ? [
                                  BoxShadow(
                                    color: MesteriColors.primary.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Autentificare',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _isLogin ? MesteriColors.primary : MesteriColors.onSurfaceSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isLogin = false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !_isLogin ? Colors.white : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: !_isLogin
                              ? [
                                  BoxShadow(
                                    color: MesteriColors.primary.withValues(alpha: 0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          'Înregistrare',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: !_isLogin ? MesteriColors.primary : MesteriColors.onSurfaceSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (!_isLogin) ...[
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nume Complet',
                  hintText: 'Introduceți numele dumneavoastră',
                  prefixIcon: Icon(Icons.person_outline, color: MesteriColors.primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: MesteriColors.outline),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: MesteriColors.outline),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: MesteriColors.primary, width: 2),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
            ],
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Introduceți adresa de email',
                prefixIcon: Icon(Icons.email_outlined, color: MesteriColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: MesteriColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: MesteriColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: MesteriColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: 'Parolă',
                hintText: 'Introduceți parola',
                prefixIcon: Icon(Icons.lock_outline, color: MesteriColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: MesteriColors.outline),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: MesteriColors.outline),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: MesteriColors.primary, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            if (_isLogin) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _handleForgotPassword,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Ai uitat parola?',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: MesteriColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _handleEmailPasswordAuth,
              style: ElevatedButton.styleFrom(
                backgroundColor: MesteriColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 24),
                elevation: 4,
                shadowColor: MesteriColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : Text(
                      _isLogin ? 'Autentificare' : 'Creează Cont',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _showEmailAuth = false;
                  _emailController.clear();
                  _passwordController.clear();
                  _nameController.clear();
                });
              },
              child: Text(
                'Înapoi la opțiuni de autentificare',
                style: GoogleFonts.lato(
                  fontSize: 14,
                  color: MesteriColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesList() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          _buildFeatureItem(
            Icons.security_rounded,
            'Plăți sigure cu escrow',
            'Banii tăi sunt protejați până la finalizarea lucrării',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            Icons.verified_user_rounded,
            'Meșteri verificați',
            'Toți profesioniștii sunt verificați și evaluați',
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            Icons.stars_rounded,
            'Recenzii autentice',
            'Vezi feedback real de la clienți mulțumiți',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: MesteriColors.primary.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: MesteriColors.primaryUltraLowOpacity,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: MesteriColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.lato(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: MesteriColors.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    color: MesteriColors.onSurfaceSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        children: [
          Text(
            'Continuând, accepți',
            style: GoogleFonts.lato(
              fontSize: 12,
              color: MesteriColors.onSurfaceTertiary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Termenii de utilizare',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: MesteriColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              Text(
                ' și ',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: MesteriColors.onSurfaceTertiary,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  'Politica de confidențialitate',
                  style: GoogleFonts.lato(
                    fontSize: 12,
                    color: MesteriColors.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // For web, use signInWithPopup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');

        userCredential = await FirebaseAuth.instance.signInWithPopup(googleProvider);
      } else {
        // For mobile (Android/iOS), use Google Sign-In package
        final GoogleSignIn googleSignIn = GoogleSignIn(
          scopes: ['email', 'profile'],
        );

        // Sign out first to force account selection
        await googleSignIn.signOut();

        // Trigger the authentication flow
        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

        if (googleUser == null) {
          // User cancelled the sign-in
          setState(() => _isLoading = false);
          return;
        }

        // Obtain the auth details from the request
        final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

        // Create a new credential
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        // Sign in to Firebase with the Google credential
        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      }

      final user = userCredential.user;

      if (user != null) {
        debugPrint('✅ Google Sign In successful: ${user.email}');
        
        // Get Firebase ID token
        final idToken = await user.getIdToken();
        if (idToken != null) {
          ApiClient.setAuthToken(idToken);

          // Sync user with backend
          try {
            await mesteriService.syncFirebaseUser({
              'uid': user.uid,
              'email': user.email ?? '',
              'name': user.displayName ?? '',
              'phone': user.phoneNumber ?? '',
              'role': 'client',
              'photoUrl': user.photoURL,
            });
            debugPrint('✅ Backend sync successful');
          } catch (e) {
            debugPrint('⚠️ Backend sync failed: $e');
            // Continue anyway - user is authenticated in Firebase
          }
        }

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  'Bine ai venit, ${user.displayName ?? "User"}!',
                  style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: MesteriColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to main app
        debugPrint('🚀 Navigating to /main');
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/main',
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      String errorMessage = 'Autentificare eșuată';

      switch (e.code) {
        case 'account-exists-with-different-credential':
          errorMessage = 'Există deja un cont cu acest email';
          break;
        case 'invalid-credential':
          errorMessage = 'Credențiale invalide';
          break;
        case 'operation-not-allowed':
          errorMessage = 'Autentificarea Google nu este activată';
          break;
        case 'user-disabled':
          errorMessage = 'Acest cont a fost dezactivat';
          break;
        case 'user-not-found':
          errorMessage = 'Nu există cont cu acest email';
          break;
        case 'popup-closed-by-user':
          // User closed the popup, just return without error
          setState(() => _isLoading = false);
          return;
        case 'cancelled-popup-request':
          // Popup was cancelled, just return without error
          setState(() => _isLoading = false);
          return;
        default:
          errorMessage = 'Eroare: ${e.message}';
      }

      _showErrorSnackBar(errorMessage);
    } catch (e) {
      if (!mounted) return;
      debugPrint('❌ General Error: $e');
      _showErrorSnackBar('Autentificare eșuată. Te rog încearcă din nou.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleEmailPasswordAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final name = _nameController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('Te rog completează toate câmpurile');
      return;
    }

    if (!_isLogin && name.isEmpty) {
      _showErrorSnackBar('Te rog introduceți numele');
      return;
    }

    setState(() => _isLoading = true);

    try {
      UserCredential userCredential;

      if (_isLogin) {
        // Login
        debugPrint('🔑 Attempting email login for: $email');
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        debugPrint('✅ Login successful');
      } else {
        // Register
        debugPrint('📝 Attempting email registration for: $email');
        userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        debugPrint('✅ Registration successful');

        // Update display name
        await userCredential.user?.updateDisplayName(name);
        debugPrint('✅ Display name updated to: $name');
      }

      final user = userCredential.user;

      if (user != null) {
        // Get Firebase ID token
        final idToken = await user.getIdToken();
        if (idToken != null) {
          ApiClient.setAuthToken(idToken);

          // Sync user with backend
          try {
            await mesteriService.syncFirebaseUser({
              'uid': user.uid,
              'email': user.email ?? '',
              'name': user.displayName ?? name,
              'phone': user.phoneNumber ?? '',
              'role': 'client',
              'photoUrl': user.photoURL,
            });
            debugPrint('✅ Backend sync successful');
          } catch (e) {
            debugPrint('⚠️ Backend sync failed: $e');
            // Continue anyway - user is authenticated in Firebase
          }
        }

        if (!mounted) return;

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text(
                  _isLogin
                      ? 'Bine ai revenit!'
                      : 'Bine ai venit, ${user.displayName ?? name}!',
                  style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            backgroundColor: MesteriColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            duration: const Duration(seconds: 2),
          ),
        );

        // Navigate to main app
        debugPrint('🚀 Navigating to /main');
        await Future.delayed(const Duration(milliseconds: 500));
        if (!mounted) return;
        
        Navigator.of(context).pushNamedAndRemoveUntil(
          '/main',
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      debugPrint('❌ Firebase Auth Error: ${e.code} - ${e.message}');
      String errorMessage = 'Autentificare eșuată';

      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Există deja un cont cu acest email';
          break;
        case 'invalid-email':
          errorMessage = 'Adresa de email nu este validă';
          break;
        case 'weak-password':
          errorMessage = 'Parola este prea slabă (minim 6 caractere)';
          break;
        case 'user-not-found':
          errorMessage = 'Nu există cont cu acest email';
          break;
        case 'wrong-password':
          errorMessage = 'Parolă incorectă';
          break;
        case 'user-disabled':
          errorMessage = 'Acest cont a fost dezactivat';
          break;
        case 'invalid-credential':
          errorMessage = 'Email sau parolă incorectă';
          break;
        default:
          errorMessage = 'Eroare: ${e.message}';
      }

      _showErrorSnackBar(errorMessage);
    } catch (e) {
      if (!mounted) return;
      debugPrint('❌ General Error: $e');
      _showErrorSnackBar('Autentificare eșuată. Te rog încearcă din nou.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.lato(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
        backgroundColor: MesteriColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  Future<void> _handleForgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showErrorSnackBar('Te rog introduceți adresa de email');
      return;
    }

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Email de resetare trimis! Verifică inbox-ul pentru $email',
                  style: GoogleFonts.lato(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          backgroundColor: MesteriColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          duration: const Duration(seconds: 5),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      String errorMessage = 'Eroare la trimiterea email-ului';

      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'Nu există cont cu acest email';
          break;
        case 'invalid-email':
          errorMessage = 'Adresa de email nu este validă';
          break;
        default:
          errorMessage = 'Eroare: ${e.message}';
      }

      _showErrorSnackBar(errorMessage);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Eroare la trimiterea email-ului. Te rog încearcă din nou.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
