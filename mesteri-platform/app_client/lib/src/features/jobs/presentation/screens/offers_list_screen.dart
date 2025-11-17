import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';
import 'package:app_client/src/core/models/job_models.dart';
import 'package:app_client/src/core/services/comprehensive_service.dart';

class OffersListScreen extends StatefulWidget {
  final String jobId;
  final List<Offer> offers;

  const OffersListScreen({super.key, required this.jobId, required this.offers});

  @override
  State<OffersListScreen> createState() => _OffersListScreenState();
}

class _OffersListScreenState extends State<OffersListScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Oferte Primite'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: widget.offers.isEmpty
          ? const Center(
              child: Text('Nu există oferte pentru această lucrare.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.offers.length,
              itemBuilder: (context, index) {
                final offer = widget.offers[index];
                return _buildOfferCard(offer);
              },
            ),
    );
  }

  Widget _buildOfferCard(Offer offer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  offer.mesterName ?? 'Meșter Necunoscut',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  '${offer.price.toStringAsFixed(2)} RON',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              offer.description ?? offer.details,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (offer.status == 'pending') ...[
                  OutlinedButton(
                    onPressed: _isLoading ? null : () => _handleDecline(offer.id!),
                    child: const Text('Refuză'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _isLoading ? null : () => _handleAccept(offer.id!),
                    child: const Text('Acceptă'),
                  ),
                ] else if (offer.status == 'accepted')
                  Chip(
                    label: const Text('Ofertă Acceptată'),
                    backgroundColor: AppTheme.successColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: AppTheme.successColor),
                  )
                else if (offer.status == 'rejected')
                  Chip(
                    label: const Text('Ofertă Refuzată'),
                    backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: AppTheme.errorColor),
                  )
                else if (offer.status == 'withdrawn')
                  Chip(
                    label: const Text('Ofertă Retrasă'),
                    backgroundColor: AppTheme.warningColor.withOpacity(0.1),
                    labelStyle: TextStyle(color: AppTheme.warningColor),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleAccept(String offerId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await mesteriService.updateOfferStatus(offerId, 'accepted');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ofertă acceptată cu succes!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      // Optionally refresh job details or navigate back
      Navigator.pop(context); // Go back to job details
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare la acceptarea ofertei: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleDecline(String offerId) async {
    setState(() {
      _isLoading = true;
    });
    try {
      await mesteriService.updateOfferStatus(offerId, 'rejected');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ofertă refuzată cu succes!'),
          backgroundColor: AppTheme.successColor,
        ),
      );
      // Optionally refresh job details or update UI to reflect declined status
      Navigator.pop(context); // Go back to job details
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Eroare la refuzarea ofertei: $e'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
