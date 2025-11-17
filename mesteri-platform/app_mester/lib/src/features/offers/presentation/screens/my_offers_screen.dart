import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../../../core/services/offers_service.dart';
import '../../../../core/theme/app_theme.dart';

enum OffersView { all, active, accepted, rejected }

class OffersSummary {
  final int active;
  final int accepted;
  final int rejected;
  final int total;

  const OffersSummary({
    required this.active,
    required this.accepted,
    required this.rejected,
    required this.total,
  });
}

class MyOffer {
  final String id;
  final String jobId;
  final String jobTitle;
  final String clientName;
  final double proposedPrice;
  final String description;
  final String status;
  final DateTime submittedDate;
  final String? responseMessage;
  final DateTime? responseDate;

  const MyOffer({
    required this.id,
    required this.jobId,
    required this.jobTitle,
    required this.clientName,
    required this.proposedPrice,
    required this.description,
    required this.status,
    required this.submittedDate,
    this.responseMessage,
    this.responseDate,
  });

  Color getStatusColor() {
    switch (status) {
      case 'pending':
        return AppTheme.warningColor;
      case 'accepted':
        return AppTheme.successColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return AppTheme.onSurfaceSecondary;
    }
  }

  Color getStatusBackgroundColor() {
    switch (status) {
      case 'pending':
        return AppTheme.warningColor.withValues(alpha: 0.1);
      case 'accepted':
        return AppTheme.successColor.withValues(alpha: 0.1);
      case 'rejected':
        return AppTheme.errorColor.withValues(alpha: 0.1);
      default:
        return AppTheme.surfaceVariant;
    }
  }
}

// Mock data for development
final List<MyOffer> mockOffers = [
  MyOffer(
    id: '1',
    jobId: 'job1',
    jobTitle: 'Reparație robinet bucătărie',
    clientName: 'Maria Popescu',
    proposedPrice: 180.0,
    description: 'Voi efectua reparația în 2 ore. Am toate piesele necesare.',
    status: 'pending',
    submittedDate: DateTime.now().subtract(const Duration(hours: 2)),
  ),

  MyOffer(
    id: '2',
    jobId: 'job2',
    jobTitle: 'Montaj ușă de intrare',
    clientName: 'Ion Dumitrescu',
    proposedPrice: 320.0,
    description: 'Montaj profesional cu toate finisările incluse.',
    status: 'accepted',
    submittedDate: DateTime.now().subtract(const Duration(hours: 24)),
    responseMessage: 'Excelent preț. Te contactăm pentru programare.',
    responseDate: DateTime.now().subtract(const Duration(hours: 12)),
  ),

  MyOffer(
    id: '3',
    jobId: 'job3',
    jobTitle: 'Vopsire apartament 3 camere',
    clientName: 'Elena Alexandru',
    proposedPrice: 1900.0,
    description: 'Preț competitiv, materiale profesionale incluse.',
    status: 'rejected',
    submittedDate: DateTime.now().subtract(const Duration(hours: 48)),
    responseMessage: 'Am ales alt meșter cu mai multă experiență.',
    responseDate: DateTime.now().subtract(const Duration(hours: 24)),
  ),

  MyOffer(
    id: '4',
    jobId: 'job4',
    jobTitle: 'Înlocuire priză defectă',
    clientName: 'Mihai Vasilescu',
    proposedPrice: 95.0,
    description: 'Repar professional cu toate normativele respectate.',
    status: 'pending',
    submittedDate: DateTime.now().subtract(const Duration(hours: 6)),
  ),

  MyOffer(
    id: '5',
    jobId: 'job5',
    jobTitle: 'Gresie și faianță baie',
    clientName: 'Alexandru Georgescu',
    proposedPrice: 950.0,
    description: 'Montaj expert, completare în 3 zile.',
    status: 'accepted',
    submittedDate: DateTime.now().subtract(const Duration(hours: 36)),
    responseMessage: 'Sună pentru programare când poți începe.',
    responseDate: DateTime.now().subtract(const Duration(hours: 30)),
  ),
];

class MyOffersScreen extends StatefulWidget {
  const MyOffersScreen({super.key});

  @override
  State<MyOffersScreen> createState() => _MyOffersScreenState();
}

class _MyOffersScreenState extends State<MyOffersScreen> {
  final OffersService _offersService = OffersService();

  List<dynamic> _offers = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMyOffers();
  }

  Future<void> _loadMyOffers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() {
        _errorMessage = 'Trebuie să fii autentificat';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final offers = await _offersService.getMyCraftsmanOffers(user.uid);
      setState(() {
        _offers = offers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _withdrawOffer(String offerId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Retrage oferta'),
        content: const Text('Sigur dorești să retragi această ofertă?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Anulează'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Retrage'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _offersService.withdrawOffer(offerId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Oferta a fost retrasă'),
            backgroundColor: Colors.green,
          ),
        );
        _loadMyOffers();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ofertele mele'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadMyOffers,
              child: const Text('Încearcă din nou'),
            ),
          ],
        ),
      );
    }

    if (_offers.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.mail_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'Nu ai trimis nicio ofertă încă',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.work),
              label: const Text('Caută proiecte'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMyOffers,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _offers.length,
        itemBuilder: (context, index) {
          final offer = _offers[index];
          return _buildOfferCard(offer);
        },
      ),
    );
  }

  Widget _buildOfferCard(Map<String, dynamic> offer) {
    final job = offer['job'] as Map<String, dynamic>?;
    final bidAmount = offer['bidAmount'] ?? 0;
    final estimatedDays = offer['estimatedDays'] ?? 0;
    final createdAt = offer['createdAt'] != null
        ? DateTime.tryParse(offer['createdAt'].toString())
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job Title
            Row(
              children: [
                Expanded(
                  child: Text(
                    job?['title'] ?? 'Fără titlu',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusBadge(offer),
              ],
            ),
            const SizedBox(height: 12),

            // Offer Details
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.attach_money, size: 18),
                      const SizedBox(width: 8),
                      const Text('Prețul oferit:'),
                      const Spacer(),
                      Text(
                        '$bidAmount RON',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 18),
                      const SizedBox(width: 8),
                      const Text('Durata estimată:'),
                      const Spacer(),
                      Text(
                        '$estimatedDays zile',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              offer['description'] ?? '',
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),

            // Footer
            Row(
              children: [
                Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  createdAt != null
                      ? _formatDate(createdAt)
                      : 'Dată necunoscută',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () => _withdrawOffer(offer['id']),
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text('Retrage', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(Map<String, dynamic> offer) {
    // For now, all offers are pending as status is not in schema
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule, size: 14, color: Colors.orange),
          const SizedBox(width: 4),
          const Text(
            'ÎN AȘTEPTARE',
            style: TextStyle(
              color: Colors.orange,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Acum ${difference.inMinutes} minute';
      }
      return 'Acum ${difference.inHours} ore';
    } else if (difference.inDays == 1) {
      return 'Ieri';
    } else if (difference.inDays < 7) {
      return 'Acum ${difference.inDays} zile';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
