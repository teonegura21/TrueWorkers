import 'package:flutter/material.dart';
import 'package:app_client/src/core/theme/app_theme.dart';
import 'package:app_client/src/core/services/comprehensive_service.dart';
import 'package:app_client/src/core/config/app_config.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _budgetMinController = TextEditingController();
  final _budgetMaxController = TextEditingController();

  String? _selectedCategory;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _budgetMinController.dispose();
    _budgetMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Postează un Job Nou'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTitleAndDescription(),
                const SizedBox(height: 24),
                _buildCategoryDropdown(),
                const SizedBox(height: 24),
                _buildLocationField(),
                const SizedBox(height: 24),
                _buildBudgetFields(),
                const SizedBox(height: 32),
                _buildPostJobButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitleAndDescription() {
    return Column(
      children: [
        TextFormField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Titlu Job',
            hintText: 'Ex: Reparație robinet bucătărie',
            prefixIcon: Icon(Icons.title),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Te rog să introduci un titlu';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          maxLines: 5,
          decoration: const InputDecoration(
            labelText: 'Descriere Job',
            hintText: 'Descrie detaliat lucrarea necesară...',
            prefixIcon: Icon(Icons.description),
            alignLabelWithHint: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Te rog să introduci o descriere';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      initialValue: _selectedCategory,
      decoration: const InputDecoration(
        labelText: 'Categorie',
        prefixIcon: Icon(Icons.category),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      hint: const Text('Selectează o categorie'),
      items: AppConfig.jobCategories.map((String category) {
        return DropdownMenuItem<String>(
          value: category,
          child: Text(category),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _selectedCategory = newValue;
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Te rog să selectezi o categorie';
        }
        return null;
      },
    );
  }

  Widget _buildLocationField() {
    return DropdownButtonFormField<String>(
      initialValue: _locationController.text.isEmpty ? null : _locationController.text,
      decoration: const InputDecoration(
        labelText: 'Locație',
        prefixIcon: Icon(Icons.location_on_outlined),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      hint: const Text('Selectează locația'),
      items: AppConfig.majorRomanianCities.map((String city) {
        return DropdownMenuItem<String>(
          value: city,
          child: Text(city),
        );
      }).toList(),
      onChanged: (String? newValue) {
        setState(() {
          _locationController.text = newValue ?? '';
        });
      },
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Te rog să selectezi o locație';
        }
        return null;
      },
    );
  }

  Widget _buildBudgetFields() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: _budgetMinController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Buget Minim',
              hintText: 'Ex: 200',
              prefixIcon: Icon(Icons.attach_money),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Minim';
              }
              if (double.tryParse(value) == null) {
                return 'Număr invalid';
              }
              return null;
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _budgetMaxController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Buget Maxim',
              hintText: 'Ex: 500',
              prefixIcon: Icon(Icons.money),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Maxim';
              }
              if (double.tryParse(value) == null) {
                return 'Număr invalid';
              }
              final min = double.tryParse(_budgetMinController.text ?? '');
              final max = double.tryParse(value);
              if (min != null && max != null && max < min) {
                return 'Mai mare decât minim';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPostJobButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handlePostJob,
      child: _isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text('Postează Job'),
    );
  }

  void _handlePostJob() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final jobData = {
          'title': _titleController.text.trim(),
          'description': _descriptionController.text.trim(),
          'category': _selectedCategory!, // Ensure category is not null due to validation
          'location': _locationController.text.trim(),
          'budgetMin': double.parse(_budgetMinController.text.trim()),
          'budgetMax': double.parse(_budgetMaxController.text.trim()),
          // Add clientId here, assuming it comes from the authenticated user
          // 'clientId': 'current_user_id', // TODO: Replace with actual client ID
        };

        await mesteriService.postJob(jobData);

        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Job-ul a fost postat cu succes!'),
            backgroundColor: AppTheme.successColor,
          ),
        );

        // Navigate back or to job details screen
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare la postarea job-ului: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
