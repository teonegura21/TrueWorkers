import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({super.key});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _minBudgetController = TextEditingController();
  final _maxBudgetController = TextEditingController();

  String? _selectedCategory;
  String? _selectedCity;
  String _urgency = 'MEDIUM';

  final List<Map<String, String>> _categories = [
    {'value': 'INSTALATII_SANITARE', 'label': 'Instalații Sanitare'},
    {'value': 'ELECTRIK', 'label': 'Instalații Electrice'},
    {'value': 'CONSTRUCTII', 'label': 'Construcții & Renovări'},
    {'value': 'ZUGRAVEALA', 'label': 'Zugrăveli & Vopsitorie'},
    {'value': 'TAMPLARIE', 'label': 'Tâmplărie'},
    {'value': 'CLIMATIZARE', 'label': 'Climatizare & Încălzire'},
    {'value': 'CURATENIE', 'label': 'Curățenie'},
    {'value': 'DESIGN_INTERIOR', 'label': 'Design Interior'},
    {'value': 'ALTELE', 'label': 'Altele'},
  ];

  final List<String> _romanianCities = [
    'București',
    'Cluj-Napoca',
    'Timișoara',
    'Iași',
    'Constanța',
    'Craiova',
    'Brașov',
    'Galați',
    'Ploiești',
    'Oradea',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _minBudgetController.dispose();
    _maxBudgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postează un Job'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildSectionTitle('Informații de bază'),
            const SizedBox(height: 16),
            
            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Titlu job *',
                hintText: 'Ex: Renovare baie garsonieră',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Titlul este obligatoriu';
                }
                if (value.length < 10) {
                  return 'Titlul trebuie să aibă minim 10 caractere';
                }
                return null;
              },
              maxLength: 100,
            ),
            const SizedBox(height: 16),

            // Category
            DropdownButtonFormField<String>(
              initialValue: _selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Categorie *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category),
              ),
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category['value'],
                  child: Text(category['label']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Selectează o categorie';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descriere *',
                hintText: 'Descrie detaliat ce lucrări trebuie executate...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 5,
              maxLength: 1000,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Descrierea este obligatorie';
                }
                if (value.length < 50) {
                  return 'Descrierea trebuie să aibă minim 50 caractere';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Locație'),
            const SizedBox(height: 16),

            // City
            DropdownButtonFormField<String>(
              initialValue: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'Oraș *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_city),
              ),
              items: _romanianCities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCity = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Selectează orașul';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Location/Address
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Adresă *',
                hintText: 'Ex: Str. Aviației, Nr. 12',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Adresa este obligatorie';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Buget'),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _minBudgetController,
                    decoration: const InputDecoration(
                      labelText: 'Buget minim (RON) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoriu';
                      }
                      final min = int.tryParse(value);
                      if (min == null || min < 0) {
                        return 'Suma invalidă';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _maxBudgetController,
                    decoration: const InputDecoration(
                      labelText: 'Buget maxim (RON) *',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Obligatoriu';
                      }
                      final max = int.tryParse(value);
                      final min = int.tryParse(_minBudgetController.text);
                      if (max == null || max < 0) {
                        return 'Suma invalidă';
                      }
                      if (min != null && max < min) {
                        return 'Mai mic decât minimul';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Urgență'),
            const SizedBox(height: 16),

            _buildUrgencySelector(),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _submitJob,
                icon: const Icon(Icons.publish),
                label: const Text(
                  'Publică Job',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              '* Câmpuri obligatorii',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildUrgencySelector() {
    return Column(
      children: [
        _buildUrgencyOption(
          value: 'LOW',
          label: 'Scăzută',
          description: 'Pot aștepta câteva săptămâni',
          icon: Icons.schedule,
          color: Colors.green,
        ),
        const SizedBox(height: 12),
        _buildUrgencyOption(
          value: 'MEDIUM',
          label: 'Medie',
          description: 'Preferabil în 1-2 săptămâni',
          icon: Icons.alarm,
          color: Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildUrgencyOption(
          value: 'HIGH',
          label: 'Mare',
          description: 'Urgent, în câteva zile',
          icon: Icons.priority_high,
          color: Colors.red,
        ),
        const SizedBox(height: 12),
        _buildUrgencyOption(
          value: 'EMERGENCY',
          label: 'Urgență',
          description: 'Imediat, situație de urgență',
          icon: Icons.warning,
          color: Colors.red[900]!,
        ),
      ],
    );
  }

  Widget _buildUrgencyOption({
    required String value,
    required String label,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _urgency == value;
    
    return GestureDetector(
      onTap: () {
        setState(() => _urgency = value);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? color : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 28),
          ],
        ),
      ),
    );
  }

  void _submitJob() {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Te rugăm să completezi toate câmpurile obligatorii'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare job data
    final jobData = {
      'title': _titleController.text,
      'description': _descriptionController.text,
      'category': _selectedCategory,
      'city': _selectedCity,
      'location': _locationController.text,
      'budgetMin': int.parse(_minBudgetController.text),
      'budgetMax': int.parse(_maxBudgetController.text),
      'urgency': _urgency,
    };

    // TODO: Send to backend API
    print('Job Data: $jobData');

    // Show success message
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Succes!'),
          ],
        ),
        content: const Text(
          'Job-ul tău a fost publicat cu succes! Vei primi oferte de la meșteri în curând.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
