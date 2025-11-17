import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';

class CookiePolicyScreen extends StatelessWidget {
  const CookiePolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Politica de Cookies'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.cookie,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Politica de Cookies',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ultima actualizare: Decembrie 2024',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.onSurfaceSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Introduction
            Text(
              'Ce sunt cookie-urile?',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Cookie-urile sunt fișiere text mici pe care le stocăm pe dispozitivul tău atunci când vizitezi site-ul nostru. Acestea ne ajută să îți oferim o experiență mai bună și să înțelegem modul în care folosești platforma noastră.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Types of cookies
            Text(
              'Tipuri de cookie-uri pe care le folosim',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            _buildCookieTypeCard(
              context: context,
              title: 'Cookie-uri esențiale',
              description: 'Aceste cookie-uri sunt necesare pentru funcționarea platformei și nu pot fi dezactivate. Ele ne permit să îți menținem sesiunea de autentificare și să îți oferim serviciile de bază.',
              duration: 'Sesiune sau până la 1 an',
              isEssential: true,
            ),
            
            const SizedBox(height: 16),
            
            _buildCookieTypeCard(
              context: context,
              title: 'Cookie-uri de performanță',
              description: 'Aceste cookie-uri ne ajută să înțelegem cum folosesc utilizatorii platforma noastră, pentru a o îmbunătăți. Colectăm informații anonime despre paginile vizitate și erorile apărute.',
              duration: 'Până la 2 ani',
              isEssential: false,
            ),
            
            const SizedBox(height: 16),
            
            _buildCookieTypeCard(
              context: context,
              title: 'Cookie-uri de funcționalitate',
              description: 'Aceste cookie-uri permit platformei să îți amintească alegerile (cum ar fi limba sau regiunea) pentru o experiență mai personalizată.',
              duration: 'Până la 1 an',
              isEssential: false,
            ),
            
            const SizedBox(height: 16),
            
            _buildCookieTypeCard(
              context: context,
              title: 'Cookie-uri de publicitate',
              description: 'Aceste cookie-uri sunt folosite pentru a îți afișa reclame relevante. Ele pot fi setate de partenerii noștri de publicitate și pot fi folosite pentru a construi un profil despre interesele tale.',
              duration: 'Până la 1 an',
              isEssential: false,
            ),
            
            const SizedBox(height: 32),
            
            // Third party cookies
            Text(
              'Cookie-uri de la terți',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Platforma noastră poate folosi servicii de la terți care pot seta propriile cookie-uri:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildThirdPartyCookie(
              context: context,
              service: 'Google Analytics',
              purpose: 'Analiză trafic și comportament utilizatori',
            ),
            const SizedBox(height: 8),
            _buildThirdPartyCookie(
              context: context,
              service: 'Firebase',
              purpose: 'Autentificare și gestionare conturi',
            ),
            const SizedBox(height: 8),
            _buildThirdPartyCookie(
              context: context,
              service: 'Stripe/Mangopay',
              purpose: 'Procesare plăți securizate',
            ),
            
            const SizedBox(height: 32),
            
            // Your rights
            Text(
              'Drepturile tale',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Conform legislației GDPR, ai următoarele drepturi:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildRightItem(
              context: context,
              icon: Icons.info,
              title: 'Dreptul la informare',
              description: 'Să fii informat despre utilizarea cookie-urilor',
            ),
            const SizedBox(height: 12),
            _buildRightItem(
              context: context,
              icon: Icons.settings,
              title: 'Dreptul la alegere',
              description: 'Să alegi ce tipuri de cookie-uri să fie folosite',
            ),
            const SizedBox(height: 12),
            _buildRightItem(
              context: context,
              icon: Icons.delete,
              title: 'Dreptul la ștergere',
              description: 'Să soliciti ștergerea cookie-urilor existente',
            ),
            
            const SizedBox(height: 32),
            
            // How to manage cookies
            Text(
              'Cum poți gestiona cookie-urile',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Poți controla și/sau șterge cookie-urile în orice moment:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _buildInstructionItem(
              context: context,
              step: '1',
              instruction: 'Setările browserului tău îți permit să refuzi cookie-urile',
            ),
            const SizedBox(height: 8),
            _buildInstructionItem(
              context: context,
              step: '2',
              instruction: 'Poți șterge cookie-urile existente din setările browserului',
            ),
            const SizedBox(height: 8),
            _buildInstructionItem(
              context: context,
              step: '3',
              instruction: 'Platforma noastră oferă un panou de control pentru cookie-uri',
            ),
            
            const SizedBox(height: 24),
            
            // Cookie settings button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Deschidere panou setări cookie-uri'),
                      backgroundColor: AppTheme.primaryColor,
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  side: BorderSide(color: AppTheme.primaryColor),
                ),
                child: Text(
                  'Personalizează setările de cookie-uri',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Contact
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryColor.withValues(alpha: 0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ai întrebări despre cookie-uri?',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Ne poți contacta la adresa de email: privacy@mesteri.ro sau prin formularul de contact din aplicație.',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: AppTheme.onSurfaceSecondary,
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

  Widget _buildCookieTypeCard({
    required BuildContext context,
    required String title,
    required String description,
    required String duration,
    required bool isEssential,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isEssential ? AppTheme.successColor : AppTheme.primaryColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isEssential ? Icons.lock : Icons.cookie,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isEssential)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.successColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.successColor.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      'Esențial',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.onSurfaceSecondary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Durată: $duration',
                    style: TextStyle(
                      color: AppTheme.onSurfaceSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
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

  Widget _buildThirdPartyCookie({
    required BuildContext context,
    required String service,
    required String purpose,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.link,
              size: 16,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  purpose,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRightItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(
            icon,
            size: 16,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem({
    required BuildContext context,
    required String step,
    required String instruction,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            instruction,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

