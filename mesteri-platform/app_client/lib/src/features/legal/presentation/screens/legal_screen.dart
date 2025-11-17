import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({super.key});

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  bool _hasScrolledToEnd = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
        title: const Text('Documente Legale'),
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
            // Header with gradient
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // Tab Bar
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Termeni și Condiții'),
                Tab(text: 'Confidențialitate'),
                Tab(text: 'Verificare'),
              ],
              indicatorColor: AppTheme.primaryColor,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: AppTheme.onSurfaceSecondary,
            ),
            
            const SizedBox(height: 24),
            
            // Tab Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTermsAndConditionsTab(),
                  _buildPrivacyPolicyTab(),
                  _buildVerificationTab(),
                ],
              ),
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
            'Documente Legale',
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

  Widget _buildTermsAndConditionsTab() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction
          _buildLegalSection(
            '1. Introducere',
            'Acești Termeni și Condiții ("Termenii") guvernează utilizarea platformei digitale "Mesteri" ("Platforma"), operată de [Nume Companie] ("noi", "nos", "compania"). Prin accesarea sau utilizarea Platformei, sunteți de acord să respectați acești Termeni și toate legile și reglementările aplicabile.',
          ),
          
          const SizedBox(height: 24),
          
          // Services
          _buildLegalSection(
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
          _buildLegalSection(
            '3. Conturi de Utilizator',
            'Pentru a utiliza Platforma, trebuie să creați un cont. Sunteți responsabil pentru menținerea confidențialității parolei și a contului dumneavoastră. Vă angajați să furnizați informații adevărate, exacte, actuale și complete despre dumneavoastră, așa cum vi se solicită în formularul de înregistrare. Ne rezervăm dreptul de a suspenda sau închide contul dumneavoastră dacă descoperim că informațiile furnizate sunt false, inexacte, neactualizate sau incomplete.',
          ),
          
          const SizedBox(height: 24),
          
          // Verification Process
          _buildLegalSection(
            '4. Procesul de Verificare',
            'Toți meșterii trebuie să treacă printr-un proces de verificare KYC/KYB (Know Your Customer/Know Your Business) obligatoriu, realizat prin partenerul nostru Mangopay. Verificarea include:\n\n'
            '• Verificarea identității (act de identitate)\n'
            '• Verificarea calificărilor profesionale\n'
            '• Verificarea juridică (pentru persoane juridice)\n\n'
            'Meșterii pot opta pentru verificarea premium prin Risco.ro pentru a obține un statut "Meșter Premium Verificat".',
          ),
          
          const SizedBox(height: 24),
          
          // Escrow Payments
          _buildLegalSection(
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
          _buildLegalSection(
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
          _buildLegalSection(
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
          _buildLegalSection(
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
          _buildLegalSection(
            '9. Proprietate Intelectuală',
            'Toate drepturile de proprietate intelectuală asociate Platformei, inclusiv dar fără limitare la drepturile de autor, mărcile comerciale, logourile, designul și conținutul, aparțin companiei noastre sau licențiatorilor noștri. Nimic din acești Termeni nu vă acordă dreptul de a utiliza mărcile noastre comerciale sau alte drepturi de proprietate intelectuală fără acordul scris expres.',
          ),
          
          const SizedBox(height: 24),
          
          // Privacy and Data Protection
          _buildLegalSection(
            '10. Confidențialitate și Protecția Datelor',
            'Colectăm, utilizăm și protejăm datele dumneavoastră în conformitate cu Politica noastră de Confidențialitate și legislația GDPR aplicabilă. Prin utilizarea Platformei, consimțiți la colectarea și utilizarea informațiilor dumneavoastră conform acestei politici.',
          ),
          
          const SizedBox(height: 24),
          
          // Limitation of Liability
          _buildLegalSection(
            '11. Limitarea Răspunderii',
            'Platforma este furnizată "ca atare" și "după cum este disponibilă". Nu garantăm că Platforma va fi mereu disponibilă, fără erori sau viruși. Răspunderea noastră maximă față de utilizatori este limitată la valoarea plăților procesate prin platformă în ultimele 12 luni. Nu suntem răspunzători pentru pierderi indirecte, accidentale, speciale sau punitive.',
          ),
          
          const SizedBox(height: 24),
          
          // Termination
          _buildLegalSection(
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
          _buildLegalSection(
            '13. Legea Aplicabilă și Competența',
            'Acești Termeni și Condiții sunt guvernați de legile române. Orice litigiu rezultat din interpretarea sau executarea acestor Termeni va fi supus competenței instanțelor române.',
          ),
          
          const SizedBox(height: 24),
          
          // Changes to Terms
          _buildLegalSection(
            '14. Modificări ale Termenilor',
            'Ne rezervăm dreptul de a modifica acești Termeni și Condiții în orice moment. Vom notifica utilizatorii prin email și vom posta termenii actualizați pe Platformă. Utilizarea continuă a Platformei după publicarea modificărilor constituie acceptarea acestora.',
          ),
          
          const SizedBox(height: 24),
          
          // Contact Information
          _buildLegalSection(
            '15. Informații de Contact',
            'Pentru întrebări legate de acești Termeni și Condiții, ne puteți contacta la:\n\n'
            'Email: termeni@mesteri.ro\n'
            'Telefon: +40 721 000 000\n'
            'Adresă: Str. Exemplu nr. 123, București, România\n\n'
            'Sau prin formularul de contact disponibil în aplicație.',
          ),
          
          const SizedBox(height: 24),
          
          // Effective Date
          _buildLegalSection(
            'Data Intrării în Vigoare',
            'Acești Termeni și Condiții intră în vigoare la data de 1 ianuarie 2025.',
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyTab() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction
          _buildLegalSection(
            '1. Introducere',
            'Această Politică de Confidențialitate descrie modul în care [Nume Companie] ("noi", "nos", "compania") colectează, utilizează, dezvăluie și protejează informațiile dumneavoastră personale atunci când utilizați platforma noastră digitală "Mesteri" ("Platforma").\n\n'
            'Ne angajăm să protejăm confidențialitatea și securitatea datelor dumneavoastră personale în conformitate cu Regulamentul General privind Protecția Datelor (GDPR) și alte legi aplicabile privind protecția datelor.\n\n'
            'Prin utilizarea Platformei, consimțiți la practicile descrise în această politică.',
          ),
          
          const SizedBox(height: 24),
          
          // Information We Collect
          _buildLegalSection(
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
          _buildLegalSection(
            '3. Cum Utilizăm Informațiile Dumneavoastră',
            'Utilizăm informațiile dumneavoastră pentru:\n\n'
            'FUNCȚIONALITĂȚI DE BAZĂ:\n'
            '• Crearea și gestionarea contului dumneavoastră\n'
            '• Facilitarea conectării între clienți și meșteri\n'
            '• Procesarea plăților securizate prin escrow\n'
            '• Verificarea identității și calificărilor profesionale\n'
            '• Sistemul de recenzii și rating autentice\n'
            '• Comunicarea între utilizatori\n'
            '• Suport clienți și asistență tehnică\n\n'
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
          _buildLegalSection(
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
          _buildLegalSection(
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
          _buildLegalSection(
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
          _buildLegalSection(
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
          _buildLegalSection(
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
          _buildLegalSection(
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
          _buildLegalSection(
            '10. Protecția Copiilor',
            'Platforma este destinată utilizatorilor cu vârsta de minimum 18 ani. Nu colectăm intenționat informații de la persoane sub 18 ani. Dacă descoperim că am colectat accidental date de la un minor, vom șterge imediat aceste informații și vom lua măsuri pentru a preveni viitoare colecții similare.\n\n'
            'Pentru utilizatorii între 18 și 21 de ani, părinții sau tutorii legali pot solicita informații despre datele colectate prin contactarea noastră la adresa de email indicată mai jos.',
          ),
          
          const SizedBox(height: 24),
          
          // Data Protection Officer
          _buildLegalSection(
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
          _buildLegalSection(
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
          _buildLegalSection(
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
          _buildLegalSection(
            'Data Intrării în Vigoare',
            'Această Politică de Confidențialitate intră în vigoare la data de 1 ianuarie 2025.',
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationTab() {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Introduction
          _buildLegalSection(
            '1. Introducere',
            'Această Politică de Verificare descrie procesul de verificare a meșterilor ("Meșterii") pe platforma noastră digitală "Mesteri" ("Platforma"), operată de [Nume Companie] ("noi", "nos", "compania").\n\n'
            'Ne angajăm să asigurăm un ecosistem de încredere prin verificarea riguroasă a identității și calificărilor profesionale ale tuturor meșterilor.\n\n'
            'Prin utilizarea Platformei, consimțiți la practicile descrise în această politică.',
          ),
          
          const SizedBox(height: 24),
          
          // Verification Process
          _buildLegalSection(
            '2. Procesul de Verificare',
            'Toți meșterii trebuie să treacă printr-un proces de verificare KYC/KYB (Know Your Customer/Know Your Business) obligatoriu, realizat prin partenerul nostru Mangopay:\n\n'
            'VERIFICAREA DE BAZĂ (OBLIGATORIE):\n'
            '• Verificarea identității (act de identitate)\n'
            '• Verificarea calificărilor profesionale\n'
            '• Verificarea juridică (pentru persoane juridice)\n\n'
            'VERIFICAREA PREMIUM (OPȚIONALĂ):\n'
            '• Verificarea extinsă prin Risco.ro\n'
            '• Certificat "Meșter Premium Verificat"\n'
            '• Ecuson vizual distinctiv\n'
            '• Prioritate în recomandări',
          ),
          
          const SizedBox(height: 24),
          
          // Required Documents
          _buildLegalSection(
            '3. Documentele Necesare',
            'Pentru persoane fizice (PFA):\n'
            '• Carte de identitate (fața și verso)\n'
            '• Certificat de naștere (pentru verificare completă)\n'
            '• Dovada adresei (factură utilități sau extras bancar)\n'
            '• Certificat de calificare profesională\n'
            '• Certificat de competență tehnică\n\n'
            'Pentru persoane juridice (SRL):\n'
            '• Act constitutiv și dovada înregistrării\n'
            '• CUI și date registrul comerțului\n'
            '• Act de identitate administrator\n'
            '• Certificat de înregistrare TVA\n'
            '• Certificat de calificare profesională\n'
            '• Asigurare R.C.A. pentru activitatea desfășurată',
          ),
          
          const SizedBox(height: 24),
          
          // Verification Timeline
          _buildLegalSection(
            '4. Timpul de Verificare',
            'Procesul de verificare este structurat în etape:\n\n'
            'ETAPELE PROCESULUI:\n'
            '• Încărcare documente: 5-10 minute\n'
            '• Verificare preliminară: 24-48 de ore\n'
            '• Verificare detaliată: 3-5 zile lucrătoare\n'
            '• Verificare premium (opțională): 5-7 zile lucrătoare\n\n'
            'STATUSURI POSIBILE:\n'
            '• În Așteptare: Documentele au fost încărcate\n'
            '• Validat: Verificarea de bază a fost finalizată\n'
            '• Respins: Documentele nu sunt conforme\n'
            '• Premium Verificat: Verificarea extinsă a fost finalizată',
          ),
          
          const SizedBox(height: 24),
          
          // Trust Badges
          _buildLegalSection(
            '5. Ecusoanele de Încredere',
            'După verificare, meșterii primesc ecusoane vizuale:\n\n'
            'ECUSOANE DE BAZĂ:\n'
            '• "Verificat": Pentru meșterii cu verificarea de bază finalizată\n'
            '• "Premium Verificat": Pentru meșterii cu verificarea extinsă\n\n'
            'AFIȘARE PE PLATFORMĂ:\n'
            '• Profilul public al meșterilor verificați\n'
            '• Lângă numele meșterului în oferte și mesaje\n'
            '• În rezultatele de căutare și recomandări\n'
            '• Pe cardurile de job acceptate',
          ),
          
          const SizedBox(height: 24),
          
          // Data Security
          _buildLegalSection(
            '6. Securitatea Datelor de Verificare',
            'Implementăm măsuri de securitate pentru protecția documentelor:\n\n'
            'STOCARE ȘI TRANSMISIE:\n'
            '• Criptare AES-256 pentru toate documentele încărcate\n'
            '• Transmitere securizată prin HTTPS/TLS\n'
            '• Stocare în cloud securizat (Google Cloud)\n'
            '• Backup-uri automate zilnice criptate\n\n'
            'ACCES ȘI CONFIDENȚIALITATE:\n'
            '• Acces restricționat doar pentru echipa de verificare\n'
            '• Monitorizare 24/7 a activităților suspecte\n'
            '• Audituri periodice de securitate\n'
            '• Ștergere automată după 30 de zile de la respingere',
          ),
          
          const SizedBox(height: 24),
          
          // Verification Appeals
          _buildLegalSection(
            '7. Contestarea Verificărilor',
            'Dacă verificarea este respinsă:\n\n'
            'PROCEDURA DE CONTESTAȚIE:\n'
            '• Vei primi un email cu motivul respingerii\n'
            '• Ai 7 zile lucrătoare pentru a încărca documente corecte\n'
            '• Poți solicita o revizuire prin suport tehnic\n'
            '• Echipa noastră va răspunde în 24-48 de ore\n\n'
            'APROBARE AUTOMATĂ:\n'
            '• Documentele corecte sunt aprobate automat în 24 de ore\n'
            '• Documentele complexe pot necesita verificare manuală\n'
            '• Vei primi notificări push pentru fiecare actualizare',
          ),
          
          const SizedBox(height: 24),
          
          // Premium Verification
          _buildLegalSection(
            '8. Verificarea Premium prin Risco.ro',
            'Meșterii pot opta pentru verificarea premium:\n\n'
            'BENEFICII PREMIUM:\n'
            '• Statut "Meșter Premium Verificat"\n'
            '• Prioritate în recomandări și căutări\n'
            '• Ecuson aur distinctiv\n'
            '• Acces la funcții avansate de profil\n'
            '• Suport dedicat 24/7\n\n'
            'PROCESUL PREMIUM:\n'
            '• Verificare extinsă prin Risco.ro\n'
            '• Interviu video cu echipa de experți\n'
            '• Verificare fizică a locației de lucru\n'
            '• Audit anual obligatoriu\n'
            '• Taxă anuală de 299 RON',
          ),
          
          const SizedBox(height: 24),
          
          // Professional Standards
          _buildLegalSection(
            '9. Standardele Profesionale',
            'Meșterii verificați trebuie să respecte:\n\n'
            'STANDARDE DE CALITATE:\n'
            '• Furnizarea unor servicii profesionale de calitate\n'
            '• Respectarea termenilor de livrare conveniți\n'
            '• Menținerea curățeniei și ordinii în zona de lucru\n'
            '• Comunicarea transparentă cu clienții\n'
            '• Respectarea normelor de securitate și sănătate în muncă\n\n'
            'CONSECINȚE PENTRU NECONFORMITATE:\n'
            '• Suspendarea temporară a contului\n'
            '• Revocarea ecusonului de verificare\n'
            '• Solicitarea unei noi verificări\n'
            '• Închiderea definitivă a contului în cazuri repetate',
          ),
          
          const SizedBox(height: 24),
          
          // Continuous Verification
          _buildLegalSection(
            '10. Verificarea Continuă',
            'Verificarea este un proces continuu:\n\n'
            'MONITORIZARE ACTIVĂ:\n'
            '• Evaluarea periodică a ratingului și recenziilor\n'
            '• Monitorizarea activității suspicioase\n'
            '• Verificarea actualizărilor documentelor\n'
            '• Audituri ale tranzacțiilor și plăților\n\n'
            'RENOUARE VERIFICARE:\n'
            '• Verificarea de bază trebuie reînnoită anual\n'
            '• Verificarea premium necesită audit anual\n'
            '• Notificări automate cu 30 de zile înainte de expirare\n'
            '• Suspendarea contului dacă nu se reînnoiește la timp',
          ),
          
          const SizedBox(height: 24),
          
          // Contact Information
          _buildLegalSection(
            '11. Informații de Contact',
            'Pentru întrebări legate de procesul de verificare:\n\n'
            'ECHIPA DE VERIFICARE:\n'
            'Email: verificare@mesteri.ro\n'
            'Telefon: +40 721 000 000\n\n'
            'PARTENERI DE VERIFICARE:\n'
            'Mangopay KYC: kyc@mangopay.com\n'
            'Risco.ro Premium: premium@risco.ro\n\n'
            'Sau prin formularul de contact disponibil în aplicație.',
          ),
          
          const SizedBox(height: 24),
          
          // Effective Date
          _buildLegalSection(
            'Data Intrării în Vigoare',
            'Această Politică de Verificare intră în vigoare la data de 1 ianuarie 2025.',
          ),
        ],
      ),
    );
  }

  Widget _buildLegalSection(String title, String content) {
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

