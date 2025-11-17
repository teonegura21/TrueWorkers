import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToEnd = false;
  bool _agreedToPrivacy = false;

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
        title: const Text('Politica de Confidențialitate'),
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
            
            // Privacy Content
            Expanded(
              child: _buildPrivacyContent(),
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
              Icons.policy,
              color: Colors.white,
              size: 48,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Politica de Confidențialitate',
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

  Widget _buildPrivacyContent() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction
          _buildSection(
            '1. Introducere',
            'Această Politică de Confidențialitate descrie modul în care [Nume Companie] ("noi", "nos", "compania") colectează, utilizează, dezvăluie și protejează informațiile dumneavoastră personale atunci când utilizați platforma noastră digitală "Mesteri" ("Platforma").\n\n'
            'Ne angajăm să protejăm confidențialitatea și securitatea datelor dumneavoastră personale în conformitate cu Regulamentul General privind Protecția Datelor (GDPR) și alte legi aplicabile privind protecția datelor.\n\n'
            'Prin utilizarea Platformei, consimțiți la practicile descrise în această politică.',
          ),
          
          const SizedBox(height: 24),
          
          // Information We Collect
          _buildSection(
            '2. Informațiile pe Care le Colectăm',
            'Colectăm următoarele categorii de informații:\n\n'
            'INFORMAȚII OFERITE DE DUMNEAVOASTRĂ:\n'
            '• Informații de identificare (nume, adresă, email, telefon)\n'
            '• Informații de profil (fotografie, descriere, specializări)\n'
            '• Informații de verificare (acte de identitate, certificate profesionale)\n'
            '• Informații de plată (prin partenerul nostru Mangopay)\n'
            '• Conținutul comunicărilor (mesaje, recenzii, comentarii)\n'
            '• Preferințele și setările contului\n\n'
            'INFORMAȚII COLECTATE AUTOMAT:\n'
            '• Informații despre dispozitiv (model, sistem de operare, ID unic)\n'
            '• Informații despre utilizare (pagini vizitate, timp petrecut, funcții utilizate)\n'
            '• Informații despre locație (cu consimțământul dumneavoastră)\n'
            '• Informații despre rețea (adresă IP, tip conexiune)\n'
            '• Jurnalele de eroare și performanță\n\n'
            'INFORMAȚII DIN ALTE SURSE:\n'
            '• Informații din rețelele sociale (dacă alegeți să vă conectați)\n'
            '• Informații din partenerii noștri de plată și verificare\n'
            '• Informații din autoritățile publice (pentru verificare KYC/KYB)',
          ),
          
          const SizedBox(height: 24),
          
          // How We Use Your Information
          _buildSection(
            '3. Cum Utilizăm Informațiile Dumneavoastră',
            'Utilizăm informațiile dumneavoastră pentru:\n\n'
            'FUNCȚIONALITĂȚI DE BAZĂ:\n'
            '• Crearea și gestionarea contului dumneavoastră\n'
            '• Facilitarea conectării între clienți și meșteri\n'
            '• Procesarea plăților securizate prin escrow\n'
            '• Verificarea identității și calificărilor profesionale\n'
            '• Sistemul de recenzii și rating autentice\n'
            '• Comunicarea între utilizatori\n'
            '• Suport clienți și asistență tehnică\n'
            '• Mesagerie internă între utilizatori\n'
            '• Notificări push pentru actualizări importante\n'
            '• Panou de administrare pentru meșterii verificați\n\n'
            'ÎMBUNĂTĂȚIREA SERVICIILOR:\n'
            '• Personalizarea experienței utilizatorului\n'
            '• Dezvoltarea și testarea noilor funcționalități\n'
            '• Analiza tendințelor și comportamentului utilizatorilor\n'
            '• Optimizarea performanței și securității Platformei\n'
            '• Prevenirea fraudelor și abuzurilor\n\n'
            'COMUNICARE:\n'
            '• Trimiterea de notificări importante despre cont\n'
            '• Actualizări despre proiectele și ofertele active\n'
            '• Newslettere și comunicări de marketing (cu opțiunea de dezabonare)\n'
            '• Invitații la evenimente și campanii promoționale',
          ),
          
          const SizedBox(height: 24),
          
          // Legal Basis for Processing
          _buildSection(
            '4. Baza Juridică pentru Prelucrare',
            'Prelucrăm datele dumneavoastră personale în baza următoarelor temeiuri juridice:\n\n'
            'CONSIMȚĂMÂNTUL DUMNEAVOASTRĂ:\n'
            '• Pentru funcții suplimentare precum notificări push\n'
            '• Pentru analiza comportamentului utilizatorilor\n'
            '• Pentru comunicări de marketing și newslettere\n\n'
            'EXECUTAREA CONTRACTULUI:\n'
            '• Pentru furnizarea serviciilor esențiale ale Platformei\n'
            '• Pentru procesarea plăților și gestionarea conturilor\n'
            '• Pentru facilitarea comunicării între utilizatori\n\n'
            'INTERESUL LEGITIM:\n'
            '• Pentru prevenirea fraudelor și asigurarea securității\n'
            '• Pentru îmbunătățirea și optimizarea serviciilor\n'
            '• Pentru protejarea drepturilor și proprietății noastre\n\n'
            'OBLIGAȚIILE LEGALE:\n'
            '• Pentru respectarea reglementărilor KYC/KYB\n'
            '• Pentru păstrarea registrelor contabile\n'
            '• Pentru cooperarea cu autoritățile competente',
          ),
          
          const SizedBox(height: 24),
          
          // Data Sharing and Disclosure
          _buildSection(
            '5. Partajarea și Dezvăluirea Datelor',
            'Putem partaja informațiile dumneavoastră cu:\n\n'
            'PARTENERI TEHNICI ȘI DE PLATĂ:\n'
            '• Mangopay pentru procesarea plăților și verificarea KYC\n'
            '• Risco.ro pentru verificarea premium a meșterilor\n'
            '• Cloudflare pentru securitate și optimizare CDN\n'
            '• Google Cloud pentru infrastructură și stocare\n\n'
            'SERVICII DE ANALIZĂ ȘI MARKETING:\n'
            '• Google Analytics pentru analiza traficului\n'
            '• Firebase pentru notificări push și analitică\n'
            '• Mailchimp pentru comunicări de marketing\n\n'
            'AUTORITĂȚI ȘI INSTANȚE:\n'
            '• Autoritățile fiscale și financiare conform legii\n'
            '• Instanțele judecătorești în baza unui ordin judecătoresc\n'
            '• Autoritățile de supraveghere în domeniul protecției datelor\n\n'
            'ALȚI UTILIZATORI (INFORMAȚII PUBLICE):\n'
            '• Profilul public al meșterilor verificați\n'
            '• Recenziile și ratingurile verificate\n'
            '• Informațiile despre proiectele finalizate',
          ),
          
          const SizedBox(height: 24),
          
          // Data Security
          _buildSection(
            '6. Securitatea Datelor',
            'Implementăm măsuri de securitate tehnice și organizatorice pentru a proteja datele dumneavoastră:\n\n'
            'MĂSURI TEHNICE:\n'
            '• Criptare AES-256 pentru datele sensibile\n'
            '• Autentificare multifactorială pentru accesul administrativ\n'
            '• Firewall-uri și sisteme de detectare a intruziunilor\n'
            '• Backup-uri automate zilnice criptate\n'
            '• Monitorizare 24/7 a activităților suspecte\n\n'
            'MĂSURI ORGANIZATORICE:\n'
            '• Politici stricte de acces la date\n'
            '• Formare regulată a personalului în securitate\n'
            '• Audituri periodice de securitate\n'
            '• Proceduri de răspuns la incidente de securitate\n\n'
            'CERTIFICĂRI ȘI CONFORMITATE:\n'
            '• Certificat SSL/TLS pentru toate comunicațiile\n'
            '• Conform cu standardele PCI DSS pentru plăți\n'
            '• Certificare ISO 27001 în curs de obținere',
          ),
          
          const SizedBox(height: 24),
          
          // Data Retention
          _buildSection(
            '7. Păstrarea Datelor',
            'Păstrăm datele dumneavoastră pentru perioadele necesare:\n\n'
            'DATE ACTIVE:\n'
            '• Până la închiderea contului dumneavoastră\n'
            '• Pentru tranzacțiile în desfășurare, până la finalizare\n\n'
            'DATE DE ARHIVĂ (INACTIVE):\n'
            '• 5 ani de la închiderea contului pentru motive legale\n'
            '• 10 ani pentru documente fiscale și contabile\n'
            '• Permanent pentru datele anonimizate de analiză\n\n'
            'DATE ȘTERSE IMEDIAT:\n'
            '• Parolele (criptate și șterse la schimbare)\n'
            '• Token-urile de sesiune (expiră automat)\n'
            '• Fișierele temporare (șterse automat)',
          ),
          
          const SizedBox(height: 24),
          
          // Your Rights
          _buildSection(
            '8. Drepturile Dumneavoastră',
            'Conform GDPR, aveți următoarele drepturi:\n\n'
            'DREPTUL LA INFORMARE:\n'
            '• Să primiți informații clare despre prelucrarea datelor\n'
            '• Să solicitați detalii despre scopurile și temeiurile prelucrării\n\n'
            'DREPTUL DE ACCES:\n'
            '• Să obțineți o copie a datelor personale pe care le deținem\n'
            '• Să aflați dacă vă prelucrăm datele și în ce scop\n\n'
            'DREPTUL LA RECTIFICARE:\n'
            '• Să corectați datele incorecte sau incomplete\n'
            '• Să actualizați informațiile despre profil\n\n'
            'DREPTUL LA ȘTERGERE ("DREPTUL DE A FI UITAT"):\n'
            '• Să solicitați ștergerea datelor în anumite condiții\n'
            '• Să închideți contul și să ștergem datele asociate\n\n'
            'DREPTUL LA LIMITAREA PRELUCRĂRII:\n'
            '• Să solicitați pauzarea prelucrării în anumite situații\n'
            '• Să restricționați accesul la anumite funcții\n\n'
            'DREPTUL LA PORTABILITATEA DATELOR:\n'
            '• Să primiți datele în format structurat, uzual și lizibil\n'
            '• Să transferați datele către un alt operator\n\n'
            'DREPTUL DE OPȚIUNE:\n'
            '• Să vă retrageți consimțământul oricând\n'
            '• Să vă opuneți prelucării în scopuri de marketing\n'
            '• Să vă opuneți prelucării bazate pe interes legitim',
          ),
          
          const SizedBox(height: 24),
          
          // International Data Transfers
          _buildSection(
            '9. Transferuri Internaționale de Date',
            'Unele date pot fi transferate în afara Uniunii Europene:\n\n'
            'GARANȚII DE SECURITATE:\n'
            '• Toate transferurile respectă clauzele contractuale standard ale Comisiei Europene\n'
            '• Partenerii noștri sunt certificați conform Privacy Shield sau au măsuri echivalente\n'
            '• Implementăm măsuri suplimentare de protecție pentru transferurile către țări terțe\n\n'
            'ȚĂRI CU NIVEL ADECVAT DE PROTECȚIE:\n'
            '• Statele Unite ale Americii (pentru parteneri certificați)\n'
            '• Canada, Elveția, Noua Zeelandă, Israel, Japonia\n\n'
            'TRANSFERURI SPECIALE:\n'
            '• Datele de plată sunt procesate doar prin Mangopay în UE\n'
            '• Verificările KYC pot implica transferuri către autorități din țări terțe\n'
            '• Toate transferurile sunt documentate și justificate legal',
          ),
          
          const SizedBox(height: 24),
          
          // Children's Privacy
          _buildSection(
            '10. Protecția Copiilor',
            'Platforma este destinată utilizatorilor cu vârsta de minimum 18 ani. Nu colectăm intenționat informații de la persoane sub 18 ani. Dacă descoperim că am colectat accidental date de la un minor, vom șterge imediat aceste informații și vom lua măsuri pentru a preveni viitoare colecții similare.\n\n'
            'Pentru utilizatorii între 18 și 21 de ani, părinții sau tutorii legali pot solicita informații despre datele colectate prin contactarea noastră la adresa de email indicată mai jos.',
          ),
          
          const SizedBox(height: 24),
          
          // Data Protection Officer
          _buildSection(
            '11. Responsabil cu Protecția Datelor',
            'Am desemnat un Responsabil cu Protecția Datelor (RPD/DPO) pentru a asigura conformitatea cu legislația privind protecția datelor:\n\n'
            'NUME: [Nume Responsabil]\n'
            'EMAIL: dpo@mesteri.ro\n'
            'TELEFON: +40 721 000 000\n\n'
            'Roluri și responsabilități:\n'
            '• Monitorizarea conformității cu GDPR\n'
            '• Coordonarea răspunsurilor la solicitările utilizatorilor\n'
            '• Colaborarea cu Autoritatea Națională de Supraveghere\n'
            '• Actualizarea politicilor și procedurilor\n'
            '• Formarea personalului în protecția datelor',
          ),
          
          const SizedBox(height: 24),
          
          // Changes to Privacy Policy
          _buildSection(
            '12. Modificări ale Politicii de Confidențialitate',
            'Ne rezervăm dreptul de a actualiza această politică:\n\n'
            'NOTIFICARE ÎN CAZ DE MODIFICĂRI SEMNIFICATIVE:\n'
            '• Vom publica modificările pe Platformă cu cel puțin 30 de zile înainte\n'
            '• Vom trimite notificări prin email pentru schimbări majore\n'
            '• Vom solicita consimțământul suplimentar dacă este necesar\n\n'
            'MODIFICĂRI MINORE:\n'
            '• Actualizări redacționale sau de clarificare\n'
            '• Adaptări la schimbări legislative minore\n'
            '• Optimizări ale descrierii practicilor existente\n\n'
            'DATA EFECTIVĂ:\n'
            '• Fiecare versiune va avea o dată de intrare în vigoare clar indicată\n'
            '• Versiunile anterioare vor fi păstrate pentru referință',
          ),
          
          const SizedBox(height: 24),
          
          // Contact Information
          _buildSection(
            '13. Informații de Contact',
            'Pentru întrebări privind această politică sau pentru exercitarea drepturilor dumneavoastră:\n\n'
            'RESPONSABIL CU PROTECȚIA DATELOR:\n'
            'Email: dpo@mesteri.ro\n'
            'Telefon: +40 721 000 000\n\n'
            'DEPARTAMENTUL JURIDIC:\n'
            'Email: juridic@mesteri.ro\n'
            'Adresă: Str. Exemplu nr. 123, București, România\n\n'
            'AUTORITATEA NAȚIONALĂ DE SUPRAVEGHERE:\n'
            'ANSPDCP: www.dataprotection.ro\n'
            'Plângeri online: ec.europa.eu/odr',
          ),
          
          const SizedBox(height: 24),
          
          // Effective Date
          _buildSection(
            'Data Intrării în Vigoare',
            'Această Politică de Confidențialitate intră în vigoare la data de 1 ianuarie 2025.',
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
                value: _agreedToPrivacy,
                onChanged: _hasScrolledToEnd
                    ? (value) {
                        setState(() {
                          _agreedToPrivacy = value ?? false;
                        });
                      }
                    : null,
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Am citit și înțeleg Politica de Confidențialitate',
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
                ? 'Pentru a accepta Politica, trebuie să derulați până la sfârșit.'
                : 'Derulați până la sfârșit pentru a putea accepta Politica de Confidențialitate.',
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
              onPressed: _agreedToPrivacy
                  ? () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Politica de Confidențialitate a fost acceptată!'),
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
              child: _agreedToPrivacy
                  ? const Text('Acceptă Politica')
                  : const Text('Acceptă Politica'),
            ),
          ),
        ],
      ),
    );
  }
}

