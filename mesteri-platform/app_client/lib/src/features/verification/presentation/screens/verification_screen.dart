import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  int _currentStep = 0;
  bool _isLoading = false;
  final List<String> _documents = [];
  
  final List<Map<String, dynamic>> _verificationSteps = [
    {
      'title': 'Informații Personale',
      'description': 'Completează datele tale personale pentru verificare',
      'icon': Icons.person,
    },
    {
      'title': 'Documente Identitate',
      'description': 'Încarcă actul de identitate și dovada domiciliului',
      'icon': Icons.document_scanner,
    },
    {
      'title': 'Verificare Facială',
      'description': 'Realizează un selfie pentru verificarea identității',
      'icon': Icons.camera_alt,
    },
    {
      'title': 'Așteaptă Verificarea',
      'description': 'Echipa noastră va verifica documentele în 24-48 de ore',
      'icon': Icons.hourglass_empty,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verificare Cont'),
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
            // Header with trust indicators
            _buildHeader(),
            
            const SizedBox(height: 32),
            
            // Verification progress stepper
            _buildVerificationStepper(),
            
            const SizedBox(height: 32),
            
            // Current step content
            _buildStepContent(),
            
            const SizedBox(height: 32),
            
            // Action buttons
            _buildActionButtons(),
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
        borderRadius: BorderRadius.circular(20),
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
            Icons.verified_user,
            size: 48,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            'Verificare Cont',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Construiește încrederea cu clienții prin verificarea contului tău',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.white70,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          _buildTrustBadges(),
        ],
      ),
    );
  }

  Widget _buildTrustBadges() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildTrustBadge(
          icon: Icons.shield,
          label: 'Securizat',
          color: AppTheme.successColor,
        ),
        _buildTrustBadge(
          icon: Icons.star,
          label: 'Verificat',
          color: AppTheme.accentColor,
        ),
        _buildTrustBadge(
          icon: Icons.lock,
          label: 'Privat',
          color: Colors.white,
        ),
      ],
    );
  }

  Widget _buildTrustBadge({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationStepper() {
    return Column(
      children: List.generate(_verificationSteps.length, (index) {
        final step = _verificationSteps[index];
        final isCompleted = index < _currentStep;
        final isCurrent = index == _currentStep;
        
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isCompleted || isCurrent 
                        ? AppTheme.primaryColor 
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: isCompleted
                        ? const Icon(Icons.check, color: Colors.white, size: 20)
                        : Icon(
                            step['icon'] as IconData,
                            color: isCurrent ? Colors.white : Colors.grey[600],
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step['title'] as String,
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          color: isCurrent ? AppTheme.primaryColor : AppTheme.onSurfaceColor,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        step['description'] as String,
                        style: TextStyle(
                          color: AppTheme.onSurfaceSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (index < _verificationSteps.length - 1)
              Container(
                margin: const EdgeInsets.only(left: 20, top: 8, bottom: 8),
                width: 2,
                height: 24,
                color: isCompleted ? AppTheme.primaryColor : Colors.grey[300],
              ),
          ],
        );
      }),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildDocumentsStep();
      case 2:
        return _buildFacialVerificationStep();
      case 3:
        return _buildWaitingStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Informații Personale',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Aceste informații sunt necesare pentru verificarea identității tale și nu vor fi făcute publice.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurfaceSecondary,
          ),
        ),
        const SizedBox(height: 24),
        _buildTextField(label: 'Nume complet', hint: 'Ex: Popescu Ion'),
        const SizedBox(height: 16),
        _buildTextField(label: 'CNP', hint: 'Cod numeric personal'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Adresă completă', hint: 'Strada, număr, oraș, județ'),
        const SizedBox(height: 16),
        _buildTextField(label: 'Telefon', hint: '+40 7XX XXX XXX'),
      ],
    );
  }

  Widget _buildDocumentsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Documente Necesare',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Încarcă următoarele documente pentru verificare:',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurfaceSecondary,
          ),
        ),
        const SizedBox(height: 24),
        _buildDocumentUploadCard(
          title: 'Act de identitate',
          subtitle: 'Carte de identitate sau pașaport',
          onUpload: () => _uploadDocument('id'),
        ),
        const SizedBox(height: 16),
        _buildDocumentUploadCard(
          title: 'Dovada domiciliului',
          subtitle: 'Factură utilitate sau extras bancar (max. 3 luni)',
          onUpload: () => _uploadDocument('address'),
        ),
        const SizedBox(height: 16),
        _buildDocumentUploadCard(
          title: 'Certificat fiscal',
          subtitle: 'Certificat unic de înregistrare (opțional)',
          onUpload: () => _uploadDocument('tax'),
        ),
      ],
    );
  }

  Widget _buildFacialVerificationStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verificare Facială',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Realizează un selfie pentru a confirma că ești persoana din documentele încărcate.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.onSurfaceSecondary,
          ),
        ),
        const SizedBox(height: 32),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.camera_alt,
                size: 64,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Atinge pentru a face un selfie',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Asigură-te că chipul tău este bine iluminat',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Condiții pentru selfie:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildConditionItem('Chipul tău trebuie să fie vizibil și recunoscut'),
        _buildConditionItem('Fondul să fie neutru, fără alte persoane'),
        _buildConditionItem('Lumina să fie suficientă, fără reflexii'),
        _buildConditionItem('Documentul să fie ținut lângă față pentru comparație'),
      ],
    );
  }

  Widget _buildWaitingStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.hourglass_empty,
            size: 64,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 32),
        Text(
          'Verificare în curs',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Echipa noastră verifică documentele tale. Procesul durează între 24-48 de ore.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppTheme.onSurfaceSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.info,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Nu posta lucrări până la finalizarea verificării. Contul tău va fi activat automat după aprobare.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.amber[800],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Status verificare:',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'Documente primite și în procesare',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.successColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({required String label, required String hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadCard({
    required String title,
    required String subtitle,
    required VoidCallback onUpload,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.upload_file,
                color: AppTheme.primaryColor,
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
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurfaceSecondary,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.upload, color: AppTheme.primaryColor),
              onPressed: onUpload,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConditionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.check_circle,
          size: 16,
          color: AppTheme.successColor,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: OutlinedButton(
              onPressed: _previousStep,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Înapoi'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _nextStep,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: AppTheme.primaryColor,
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
                : Text(
                    _currentStep == _verificationSteps.length - 1 
                        ? 'Finalizare' 
                        : 'Continuă',
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        ),
      ],
    );
  }

  void _uploadDocument(String type) {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate upload
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _documents.add(type);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Document $type încărcat cu succes!'),
              backgroundColor: AppTheme.successColor,
            ),
          );
        });
      }
    });
  }

  void _nextStep() {
    if (_currentStep < _verificationSteps.length - 1) {
      setState(() {
        _currentStep++;
      });
    } else {
      // Final step - show completion
      _showCompletionDialog();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.verified, color: AppTheme.successColor, size: 32),
              SizedBox(width: 12),
              Text('Verificare Finalizată!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Documentele tale au fost trimise pentru verificare!',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Vei primi un email de confirmare în 24-48 de ore. Contul tău va fi activat automat după aprobare.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true); // Return success
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.successColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Închide',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }
}

