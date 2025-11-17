import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // App Logo and Branding
                _buildLogo(context),
                
                const SizedBox(height: 32),
                
                // Value Proposition
                _buildValueProposition(context),
                
                const Spacer(flex: 3),
                
                // Action Buttons
                _buildActionButtons(context),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      children: [
        // App Icon/Logo placeholder - replace with actual logo
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryColor, AppTheme.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.handyman_rounded,
            size: 60,
            color: Colors.white,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // App Name
        Text(
          'Mester Platform',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 36, // Overriding for specific size
            letterSpacing: -0.5,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Platforma ta de afaceri',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.onSurfaceSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildValueProposition(BuildContext context) {
    return Column(
      children: [
        Text(
          'Găsește clienți serioși.\nFii plătit garantat.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            height: 1.3,
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Text(
          'Conectăm meșterii cu clienți verificați pentru lucrări de calitate, cu plăți securizate prin escrow.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.onSurfaceSecondary,
            height: 1.5,
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Trust indicators
        _buildTrustIndicators(context),
      ],
    );
  }

  Widget _buildTrustIndicators(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTrustItem(
          context: context,
          icon: Icons.verified_user,
          label: 'Verificați',
          color: AppTheme.primaryColor,
        ),
        _buildTrustItem(
          context: context,
          icon: Icons.security,
          label: 'Securizat',
          color: AppTheme.successColor,
        ),
        _buildTrustItem(
          context: context,
          icon: Icons.star,
          label: 'Evaluați',
          color: AppTheme.accentColor,
        ),
      ],
    );
  }

  Widget _buildTrustItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
            color: AppTheme.onSurfaceSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Primary CTA - Login
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/login');
            },
            child: const Text('Intră în Cont'),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Secondary CTA - Register
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/register');
            },
            child: const Text('Creează Cont'),
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Additional info
        Text(
          'Prin continuare, accepți Termenii și Condițiile',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: AppTheme.onSurfaceSecondary,
          ),
        ),
      ],
    );
  }
}
