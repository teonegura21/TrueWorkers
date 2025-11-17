import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termeni și Condiții'),
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
                gradient: LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.gavel,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Termeni și Condiții',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ultima actualizare: Decembrie 2024',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Introduction
            Text(
              '1. Acceptarea Termenilor',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Prin accesarea sau utilizarea platformei Mesteri.ro, confirmi că ai citit, înțeles și acceptat acești Termeni și Condiții. Dacă nu accepți acești termeni, te rugăm să nu folosești platforma noastră.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Services
            Text(
              '2. Descrierea Serviciilor',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Mesteri.ro este o platformă digitală care conectează clienți care au nevoie de servicii de meșterie cu meșteri verificați. Platforma oferă următoarele servicii principale:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildServiceItem(
              context: context,
              title: 'Postare Lucrări',
              description: 'Clienții pot posta descrieri detaliate ale lucrărilor necesare',
            ),
            const SizedBox(height: 8),
            _buildServiceItem(
              context: context,
              title: 'Oferte de la Meșteri',
              description: 'Meșterii verificați pot trimite oferte personalizate pentru fiecare lucrare',
            ),
            const SizedBox(height: 8),
            _buildServiceItem(
              context: context,
              title: 'Sistem de Plăți Escrow',
              description: 'Plățile sunt gestionate în siguranță prin sistemul nostru de escrow',
            ),
            const SizedBox(height: 8),
            _buildServiceItem(
              context: context,
              title: 'Verificare Meșteri',
              description: 'Toți meșterii sunt verificați pentru calitate și profesionalism',
            ),
            const SizedBox(height: 8),
            _buildServiceItem(
              context: context,
              title: 'Sistem de Recenzii',
              description: 'Utilizatorii pot lăsa recenzii și evalua meșterii',
            ),
            
            const SizedBox(height: 24),
            
            // User obligations
            Text(
              '3. Obligațiile Utilizatorilor',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Ca utilizator al platformei, ești de acord să:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildObligationItem(
              context: context,
              number: '3.1',
              text: 'Furnizezi informații adevărate, complete și actualizate în timpul înregistrării și utilizării platformei',
            ),
            const SizedBox(height: 8),
            _buildObligationItem(
              context: context,
              number: '3.2',
              text: 'Respecți drepturile de proprietate intelectuală ale platformei și ale altor utilizatori',
            ),
            const SizedBox(height: 8),
            _buildObligationItem(
              context: context,
              number: '3.3',
              text: 'Nu transmiți conținut ilegal, ofensator, fraudulos sau care încalcă drepturile altora',
            ),
            const SizedBox(height: 8),
            _buildObligationItem(
              context: context,
              number: '3.4',
              text: 'Respecți confidențialitatea și intimitatea altor utilizatori',
            ),
            const SizedBox(height: 8),
            _buildObligationItem(
              context: context,
              number: '3.5',
              text: 'Respecți toate legile și reglementările aplicabile în România',
            ),
            
            const SizedBox(height: 24),
            
            // Payments and fees
            Text(
              '4. Plăți și Comisioane',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Platforma Mesteri.ro percepe următoarele comisioane:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildFeeItem(
              context: context,
              service: 'Comision pentru meșteri',
              rate: '5-15% din valoarea lucrării',
              description: 'Aplicat la finalizarea fiecărei lucrări',
            ),
            const SizedBox(height: 8),
            _buildFeeItem(
              context: context,
              service: 'Taxă de procesare plăți',
              rate: '2.9% + 2 RON',
              description: 'Taxă percepută de procesatorul de plăți (Mangopay)',
            ),
            const SizedBox(height: 16),
            Text(
              'Toate plățile sunt procesate prin sistemul nostru de escrow, asigurând securitatea tranzacțiilor.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Dispute resolution
            Text(
              '5. Rezolvarea Disputelor',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'În cazul unui conflict între utilizatori, platforma oferă următorul proces de rezolvare:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildProcessStep(
              context: context,
              step: '5.1',
              title: 'Depunerea Reclamației',
              description: 'Utilizatorul depune o reclamație detaliată prin sistemul nostru de suport',
            ),
            const SizedBox(height: 8),
            _buildProcessStep(
              context: context,
              step: '5.2',
              title: 'Investigație',
              description: 'Echipa noastră investighează situația și colectează dovezi',
            ),
            const SizedBox(height: 8),
            _buildProcessStep(
              context: context,
              step: '5.3',
              title: 'Mediere',
              description: 'Încercăm să mediem între părți pentru a găsi o soluție amiabilă',
            ),
            const SizedBox(height: 8),
            _buildProcessStep(
              context: context,
              step: '5.4',
              title: 'Decizie Finală',
              description: 'Dacă medierea eșuează, echipa noastră ia o decizie finală bazată pe dovezi',
            ),
            
            const SizedBox(height: 24),
            
            // Limitation of liability
            Text(
              '6. Limitarea Răspunderii',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Platforma Mesteri.ro este furnizată "ca atare" și "disponibilă". Nu garantăm că platforma va fi fără întreruperi sau erori. În măsura maximă permisă de lege, nu ne asumăm răspunderea pentru:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildLiabilityItem(
              context: context,
              item: '6.1',
              description: 'Pierderi indirecte, accidentale, speciale, punitive sau consecutive',
            ),
            const SizedBox(height: 8),
            _buildLiabilityItem(
              context: context,
              item: '6.2',
              description: 'Pierderi de profit, venituri, date sau fond comercial',
            ),
            const SizedBox(height: 8),
            _buildLiabilityItem(
              context: context,
              item: '6.3',
              description: 'Erori sau întârzieri în funcționarea platformei',
            ),
            const SizedBox(height: 8),
            _buildLiabilityItem(
              context: context,
              item: '6.4',
              description: 'Acțiuni ale altor utilizatori sau terțe părți',
            ),
            
            const SizedBox(height: 24),
            
            // Termination
            Text(
              '7. Încetarea Contractului',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Putem suspenda sau încheia accesul tău la platformă în următoarele situații:',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            const SizedBox(height: 12),
            _buildTerminationReason(
              context: context,
              reason: '7.1',
              description: 'Încălcarea acestor Termeni și Condiții',
            ),
            const SizedBox(height: 8),
            _buildTerminationReason(
              context: context,
              reason: '7.2',
              description: 'Activități frauduloase sau ilegale',
            ),
            const SizedBox(height: 8),
            _buildTerminationReason(
              context: context,
              reason: '7.3',
              description: 'Neutilizarea platformei timp de 12 luni consecutive',
            ),
            const SizedBox(height: 8),
            _buildTerminationReason(
              context: context,
              reason: '7.4',
              description: 'Cererea explicită a utilizatorului',
            ),
            
            const SizedBox(height: 24),
            
            // Governing law
            Text(
              '8. Legea Aplicabilă',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Acești Termeni și Condiții sunt guvernați de legile României. Orice litigiu va fi supus competenței instanțelor din București.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.6,
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
            
            const SizedBox(height: 32),
            
            // Contact information
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
                    'Contact și Informații',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Dacă ai întrebări despre acești Termeni și Condiții, ne poți contacta la:',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      height: 1.6,
                      color: AppTheme.onSurfaceSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildContactInfo(
                    context: context,
                    icon: Icons.email,
                    label: 'Email',
                    value: 'contact@mesteri.ro',
                  ),
                  const SizedBox(height: 8),
                  _buildContactInfo(
                    context: context,
                    icon: Icons.phone,
                    label: 'Telefon',
                    value: '+40 7XX XXX XXX',
                  ),
                  const SizedBox(height: 8),
                  _buildContactInfo(
                    context: context,
                    icon: Icons.location_on,
                    label: 'Adresă',
                    value: 'București, România',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required BuildContext context,
    required String title,
    required String description,
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
              Icons.check_circle,
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
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
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

  Widget _buildObligationItem({
    required BuildContext context,
    required String number,
    required String text,
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
              number,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeeItem({
    required BuildContext context,
    required String service,
    required String rate,
    required String description,
  }) {
    return Card(
      elevation: 1,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              service,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              rate,
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.onSurfaceSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessStep({
    required BuildContext context,
    required String step,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: AppTheme.accentColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
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

  Widget _buildLiabilityItem({
    required BuildContext context,
    required String item,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item,
          style: TextStyle(
            color: AppTheme.primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTerminationReason({
    required BuildContext context,
    required String reason,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppTheme.errorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            reason,
            style: TextStyle(
              color: AppTheme.errorColor,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfo({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurfaceSecondary,
          ),
        ),
      ],
    );
  }
}

