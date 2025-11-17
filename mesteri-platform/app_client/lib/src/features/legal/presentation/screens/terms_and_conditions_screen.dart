import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';

class TermsAndConditionsScreen extends StatefulWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  State<TermsAndConditionsScreen> createState() => _TermsAndConditionsScreenState();
}

class _TermsAndConditionsScreenState extends State<TermsAndConditionsScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToEnd = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      if (!_hasScrolledToEnd) {
        setState(() {
          _hasScrolledToEnd = true;
        });
      }
    }
  }

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
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Terms Content
            Expanded(
              child: _buildTermsContent(),
            ),
            
            const SizedBox(height: 24),
            
            // Agreement Section
            _buildAgreementSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.gavel,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Termeni și Condiții',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Ultima actualizare: 15 Decembrie 2024',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTermsContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction
          _buildSection(
            '1. Introducere',
            'Acești Termeni și Condiții ("Termenii") guvernează utilizarea platformei digitale "Mesteri" ("Platforma"), operată de [Nume Companie] ("noi", "nos", "compania"). Prin accesarea sau utilizarea Platformei, sunteți de acord să respectați acești Termeni și toate legile și reglementările aplicabile.',
          ),
          
          const SizedBox(height: 24),
          
          // Services
          _buildSection(
            '2. Serviciile Furnizate',
            'Platforma facilitează conectarea dintre clienți care caută servicii profesionale ("Clienți") și meșteri autorizați ("Meșteri"). Serviciile includ:\n\n'
            '• Postarea și gestionarea proiectelor\n'
            '• Sistemul de ofertare și selecție\n'
            '• Sistemul de plăți securizate prin escrow\n'
            '• Verificarea identității și calificărilor meșterilor\n'
            '• Sistemul de recenzii și rating autentice\n'
            '• Asistență clienți și suport tehnic\n'
            '• Mesagerie internă între utilizatori\n'
            '• Notificări push pentru actualizări importante\n'
            '• Panou de administrare pentru meșterii verificați',
          ),
          
          const SizedBox(height: 24),
          
          // User Accounts
          _buildSection(
            '3. Conturi de Utilizator',
            'Pentru a utiliza Platforma, trebuie să creați un cont. Sunteți responsabil pentru menținerea confidențialității parolei și a contului dumneavoastră. Vă angajați să furnizați informații adevărate, exacte, actuale și complete despre dumneavoastră, așa cum vi se solicită în formularul de înregistrare. Ne rezervăm dreptul de a suspenda sau închide contul dumneavoastră dacă descoperim că informațiile furnizate sunt false, inexacte, neactualizate sau incomplete.',
          ),
          
          const SizedBox(height: 24),
          
          // Verification Process
          _buildSection(
            '4. Procesul de Verificare',
            'Toți meșterii trebuie să treacă printr-un proces de verificare KYC/KYB (Know Your Customer/Know Your Business) obligatoriu, realizat prin partenerul nostru Mangopay. Verificarea include:\n\n'
            '• Verificarea identității (act de identitate)\n'
            '• Verificarea calificărilor profesionale\n'
            '• Verificarea juridică (pentru persoane juridice)\n\n'
            'Meșterii pot opta pentru verificarea premium prin Risco.ro pentru a obține un statut "Meșter Premium Verificat".',
          ),
          
          const SizedBox(height: 24),
          
          // Escrow Payments
          _buildSection(
            '5. Plăți Securizate prin Escrow',
            'Toate plățile pentru servicii sunt procesate prin sistemul nostru de escrow, în parteneriat cu Mangopay:\n\n'
            '• Fondurile sunt păstrate într-un cont securizat până la finalizarea lucrării\n'
            '• Plățile sunt eliberate doar după confirmarea clientului\n'
            '• Taxa platformei este de 5-15% din valoarea totală a proiectului\n'
            '• Toate tranzacțiile sunt protejate de fraudă și disputări\n'
            '• Sistemul este conform cu reglementările PSD2 și GDPR',
          ),
          
          const SizedBox(height: 24),
          
          // Verified Reviews
          _buildSection(
            '6. Recenzii Verificate',
            'Sistemul de recenzii este conceput pentru autenticitate:\n\n'
            '• Doar clienții care au finalizat plăți reale pot lăsa recenzii\n'
            '• Recenziile sunt verificate tehnic prin webhook-uri de la procesatorul de plăți\n'
            '• Rating-ul multi-criterial include: Calitatea execuției, Comunicare, Punctualitate, Curățenie\n'
            '• Toate recenziile sunt publice și contribuie la reputația meșterului\n'
            '• Recenziile false sunt șterse automat și conturile implicate sunt suspendate',
          ),
          
          const SizedBox(height: 24),
          
          // User Obligations
          _buildSection(
            '7. Obligațiile Utilizatorilor',
            'Clienți:\n'
            '• Descrierea clară și completă a proiectului\n'
            '• Respectarea termenilor de plată conveniți\n'
            '• Comunicarea corectă și promptă cu meșterii\n'
            '• Oferirea accesului necesar pentru executarea lucrării\n\n'
            'Meșteri:\n'
            '• Furnizarea unor servicii profesionale de calitate\n'
            '• Respectarea termenilor de livrare conveniți\n'
            '• Menținerea curățeniei și ordinii în zona de lucru\n'
            '• Comunicarea transparentă cu clienții\n'
            '• Respectarea normelor de securitate și sănătate în muncă',
          ),
          
          const SizedBox(height: 24),
          
          // Dispute Resolution
          _buildSection(
            '8. Rezolvarea Disputelor',
            'În cazul unui conflict între client și meșter:\n\n'
            '• Partile sunt încurajate să încerce rezolvarea amiabilă\n'
            '• Platforma oferă asistență neutră prin echipa de suport\n'
            '• Fondurile în escrow rămân blocate până la rezolvarea disputei\n'
            '• În cazuri complexe, putem solicita intervenția unui expert independent\n'
            '• Decizia finală este luată în interesul tuturor părților și al integrității platformei',
          ),
          
          const SizedBox(height: 24),
          
          // Intellectual Property
          _buildSection(
            '9. Proprietate Intelectuală',
            'Toate drepturile de proprietate intelectuală asociate Platformei, inclusiv dar fără limitare la drepturile de autor, mărcile comerciale, logourile, designul și conținutul, aparțin companiei noastre sau licențiatorilor noștri. Nimic din acești Termeni nu vă acordă dreptul de a utiliza mărcile noastre comerciale sau alte drepturi de proprietate intelectuală fără acordul scris expres.',
          ),
          
          const SizedBox(height: 24),
          
          // Privacy and Data Protection
          _buildSection(
            '10. Confidențialitate și Protecția Datelor',
            'Colectăm, utilizăm și protejăm datele dumneavoastră în conformitate cu Politica noastră de Confidențialitate și legislația GDPR aplicabilă. Prin utilizarea Platformei, consimțiți la colectarea și utilizarea informațiilor dumneavoastră conform acestei politici.',
          ),
          
          const SizedBox(height: 24),
          
          // Limitation of Liability
          _buildSection(
            '11. Limitarea Răspunderii',
            'Platforma este furnizată "ca atare" și "după cum este disponibilă". Nu garantăm că Platforma va fi mereu disponibilă, fără erori sau viruși. Răspunderea noastră maximă față de utilizatori este limitată la valoarea plăților procesate prin platformă în ultimele 12 luni. Nu suntem răspunzători pentru pierderi indirecte, accidentale, speciale sau punitive.',
          ),
          
          const SizedBox(height: 24),
          
          // Termination
          _buildSection(
            '12. Încetarea Relației Contractuale',
            'Ne rezervăm dreptul de a suspenda sau închide contul dumneavoastră și accesul la Platformă dacă:\n\n'
            '• Încălcați acești Termeni și Condiții\n'
            '• Furnizați informații false sau înșelătoare\n'
            '• Implicați în activități ilegale sau frauduloase\n'
            '• Nu respectați deciziile privind rezolvarea disputelor\n\n'
            'În caz de încetare, toate plățile în așteptare vor fi procesate conform procedurilor stabilite.',
          ),
          
          const SizedBox(height: 24),
          
          // Governing Law
          _buildSection(
            '13. Legea Aplicabilă și Competența',
            'Acești Termeni și Condiții sunt guvernați de legile române. Orice litigiu rezultat din interpretarea sau executarea acestor Termeni va fi supus competenței instanțelor române.',
          ),
          
          const SizedBox(height: 24),
          
          // Changes to Terms
          _buildSection(
            '14. Modificări ale Termenilor',
            'Ne rezervăm dreptul de a modifica acești Termeni și Condiții în orice moment. Vom notifica utilizatorii prin email și vom posta termenii actualizați pe Platformă. Utilizarea continuă a Platformei după publicarea modificărilor constituie acceptarea acestora.',
          ),
          
          const SizedBox(height: 24),
          
          // Contact Information
          _buildSection(
            '15. Informații de Contact',
            'Pentru întrebări legate de acești Termeni și Condiții, ne puteți contacta la:\n\n'
            'Email: termeni@mesteri.ro\n'
            'Telefon: +40 721 000 000\n'
            'Adresă: Str. Exemplu nr. 123, București, România\n\n'
            'Sau prin formularul de contact disponibil în aplicație.',
          ),
          
          const SizedBox(height: 24),
          
          // Effective Date
          _buildSection(
            'Data Intrării în Vigoare',
            'Acești Termeni și Condiții intră în vigoare la data de 1 ianuarie 2025.',
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurfaceSecondary,
            height: 1.6,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  Widget _buildAgreementSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Checkbox(
                value: _agreedToTerms,
                onChanged: _hasScrolledToEnd
                    ? (value) {
                        setState(() {
                          _agreedToTerms = value ?? false;
                        });
                      }
                    : null,
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Am citit și sunt de acord cu Termenii și Condițiile',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _hasScrolledToEnd
                ? 'Pentru a accepta Termenii, trebuie să derulați până la sfârșit.'
                : 'Derulați până la sfârșit pentru a putea accepta Termenii și Condițiile.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.onSurfaceSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _agreedToTerms
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Termenii și Condițiile au fost acceptați!'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  : null,
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
              child: _agreedToTerms
                  ? const Text('Acceptă Termenii')
                  : const Text('Acceptă Termenii'),
            ),
          ),
        ],
      ),
    );
  }
}

