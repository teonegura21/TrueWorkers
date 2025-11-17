import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:signature/signature.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/theme/app_theme.dart';

class SignatureCaptureScreen extends StatefulWidget {
  final String contractId;

  const SignatureCaptureScreen({super.key, required this.contractId});

  @override
  State<SignatureCaptureScreen> createState() => _SignatureCaptureScreenState();
}

class _SignatureCaptureScreenState extends State<SignatureCaptureScreen> {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 5,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  bool _isSigning = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _signContract() async {
    if (!_controller.isNotEmpty) {
      setState(() {
        _errorMessage = 'Vă rugăm să desenați semnătura în spațiul de mai sus';
      });
      return;
    }

    setState(() {
      _isSigning = true;
      _errorMessage = null;
    });

    try {
      // Export the signature as an image
      final signaturePng = await _controller.toPngBytes();
      if (signaturePng == null) {
        throw Exception('Nu s-a putut genera semnătura');
      }

      // In a real implementation, you would send this signature to your backend
      // to be attached to the contract. For now, we'll simulate this process.
      
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('Utilizator neautentificat');
      }

      final idToken = await user.getIdToken();
      
      // Simulate contract signing API call
      final response = await ApiClient.instance.post(
        '/contracts/${widget.contractId}/sign',
        data: {
          'signatureData': signaturePng,
          'signerType': 'CRAFTSMAN', // Since this is the craftsman app
        },
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Contractul a fost semnat cu succes!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate back to the contract details screen
          Navigator.pop(context, true);
        }
      } else {
        throw Exception('Cod de eroare: ${response.statusCode}');
      }
    } catch (e) {
      final errorMessage = e.toString().contains('Exception: ')
          ? e.toString().substring(e.toString().indexOf('Exception: ') + 11)
          : e.toString();
      
      if (mounted) {
        setState(() {
          _errorMessage = errorMessage;
          _isSigning = false;
        });
      }
    }
  }

  Future<void> _clearSignature() async {
    setState(() {
      _controller.clear();
      _errorMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semnează Contractul'),
        backgroundColor: AppTheme.surfaceColor,
        foregroundColor: AppTheme.onSurfaceColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Instructions
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.surfaceVariant,
            child: const Text(
              'Vă rugăm să semnați în spațiul de mai jos pentru a accepta contractul.',
              style: TextStyle(fontSize: 16, color: AppTheme.onSurfaceColor),
              textAlign: TextAlign.center,
            ),
          ),

          // Signature pad
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Signature(
                controller: _controller,
                height: 300,
                backgroundColor: Colors.white,
              ),
            ),
          ),

          // Error message if any
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Controls
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSigning ? null : _clearSignature,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Curăță'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isSigning ? null : _signContract,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isSigning
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Semnează Contractul',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Semnând acest contract, sunteți de acord cu toți termenii și condițiile menționate.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.onSurfaceSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}