# Mesteri Platform - UI/UX Implementation Guide

**Purpose**: Practical code examples and implementation patterns for UI/UX improvements
**Target Audience**: Flutter developers working on Mesteri Platform
**Last Updated**: November 18, 2025

---

## 🎨 Table of Contents

1. [Theme System Consolidation](#theme-system-consolidation)
2. [Accessibility Implementation](#accessibility-implementation)
3. [Loading States & Skeleton Screens](#loading-states--skeleton-screens)
4. [Error Handling Patterns](#error-handling-patterns)
5. [State Management with Provider](#state-management-with-provider)
6. [Form Validation](#form-validation)
7. [Animations & Micro-interactions](#animations--micro-interactions)
8. [Bottom Navigation Implementation](#bottom-navigation-implementation)
9. [Code Quality Checklist](#code-quality-checklist)

---

## 1. Theme System Consolidation

### Current Problem
Two conflicting color systems exist:
- **MesteriColors**: `#4C6EF5` (modern trust blue)
- **AppTheme**: `#2196F3` (legacy Material blue)

### Solution: Use Only MesteriColors

**Step 1: Update `app_theme.dart`**
```dart
// lib/src/core/theme/app_theme.dart

import 'package:flutter/material.dart';

// KEEP THIS - MesteriColors (Primary System)
class MesteriColors {
  // Primary Colors - Trust Blue
  static const Color primary = Color(0xFF4C6EF5);
  static const Color primaryDark = Color(0xFF364FC7);
  static const Color primaryLight = Color(0xFFE9EDFF);

  // Secondary Colors
  static const Color secondary = Color(0xFFFF7F50); // Coral
  static const Color secondaryAlt = Color(0xFF00B4D8); // Cyan

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFF44336);
  static const Color info = Color(0xFF2196F3);

  // Neutral Colors
  static const Color background = Color(0xFFF5F6FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color outline = Color(0xFFE0E0E0);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textDisabled = Color(0xFFBDBDBD);
}

// DELETE THIS - AppTheme (Remove completely)
// class AppTheme {
//   static const Color primaryColor = Color(0xFF2196F3); // DELETE
//   ...
// }

// Spacing Constants (KEEP AND USE)
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double xxxl = 48.0;
}

// Theme Data Configuration
class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: MesteriColors.primary,
        primary: MesteriColors.primary,
        secondary: MesteriColors.secondary,
        error: MesteriColors.error,
        surface: MesteriColors.surface,
        background: MesteriColors.background,
      ),
      scaffoldBackgroundColor: MesteriColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: MesteriColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: MesteriColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.lg,
          ),
        ),
      ),
    );
  }
}
```

**Step 2: Find & Replace Across Codebase**
```bash
# Use VS Code or Android Studio "Find in Files" feature
# Find: AppTheme.primaryColor
# Replace: MesteriColors.primary

# Find: AppTheme.primaryDark
# Replace: MesteriColors.primaryDark

# Find: AppTheme.secondaryColor
# Replace: MesteriColors.secondary
```

**Step 3: Update Usage in Screens**
```dart
// BEFORE
AppBar(
  backgroundColor: AppTheme.primaryColor,
  // ...
)

// AFTER
AppBar(
  backgroundColor: MesteriColors.primary,
  // ...
)
```

---

## 2. Accessibility Implementation

### WCAG 2.1 AA Requirements
- **Contrast Ratio**: 4.5:1 for normal text, 3:1 for large text
- **Touch Targets**: Minimum 48x48 dp (Android), 44x44 dp (iOS)
- **Semantic Labels**: All interactive elements need labels for screen readers
- **Keyboard Navigation**: Full app navigation without touch

### Implementation Patterns

#### 2.1 Buttons with Semantics

**IconButton Pattern**
```dart
// BEFORE (No Accessibility)
IconButton(
  icon: const Icon(Icons.send),
  onPressed: _sendMessage,
)

// AFTER (With Accessibility)
Semantics(
  label: 'Trimite mesaj',
  button: true,
  enabled: _canSendMessage,
  child: Tooltip(
    message: 'Trimite mesaj',
    child: IconButton(
      icon: const Icon(Icons.send),
      onPressed: _canSendMessage ? _sendMessage : null,
    ),
  ),
)
```

#### 2.2 Images with Semantic Labels

```dart
// BEFORE
CircleAvatar(
  backgroundImage: NetworkImage(craftsman.avatarUrl),
)

// AFTER
Semantics(
  label: 'Fotografie profil ${craftsman.name}',
  image: true,
  child: CircleAvatar(
    backgroundImage: NetworkImage(craftsman.avatarUrl),
  ),
)
```

#### 2.3 Complex Widgets with ExcludeSemantics

```dart
// For decorative elements that shouldn't be read by screen readers
ExcludeSemantics(
  child: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade100, Colors.blue.shade50],
      ),
    ),
  ),
)
```

#### 2.4 Custom Semantic Actions

```dart
Semantics(
  label: 'Proiect ${project.title}',
  onTap: () => _openProject(project),
  customSemanticsActions: {
    CustomSemanticsAction(label: 'Detalii'): () => _openDetails(project),
    CustomSemanticsAction(label: 'Editează'): () => _editProject(project),
  },
  child: ProjectCard(project: project),
)
```

#### 2.5 Minimum Touch Target Size

```dart
// Ensure all tappable elements are at least 48x48
InkWell(
  onTap: _onTap,
  child: Container(
    constraints: const BoxConstraints(
      minWidth: 48,
      minHeight: 48,
    ),
    child: Icon(Icons.favorite),
  ),
)
```

#### 2.6 Screen Reader Testing Commands

**Android (TalkBack)**:
```
Settings → Accessibility → TalkBack → Enable
Test navigation with swipe left/right
```

**iOS (VoiceOver)**:
```
Settings → Accessibility → VoiceOver → Enable
Test navigation with swipe left/right
```

**Flutter Accessibility Tests**:
```dart
testWidgets('Login button meets accessibility guidelines', (tester) async {
  await tester.pumpWidget(MyApp());

  // Test touch target size
  await expectLater(
    tester,
    meetsGuideline(androidTapTargetGuideline),
  );

  // Test contrast ratios
  await expectLater(
    tester,
    meetsGuideline(textContrastGuideline),
  );

  // Test labeled tap targets
  await expectLater(
    tester,
    meetsGuideline(labeledTapTargetGuideline),
  );
});
```

---

## 3. Loading States & Skeleton Screens

### Why Skeleton Screens?
- **Perceived Performance**: Users perceive faster loading with skeletons
- **Reduced Bounce Rate**: Users are less likely to leave during loading
- **Professional Feel**: Modern apps (Facebook, LinkedIn) use skeletons

### Implementation

#### 3.1 Enable Shimmer Package

**pubspec.yaml** (already added, just enable usage)
```yaml
dependencies:
  shimmer: ^3.0.0
```

#### 3.2 Create Skeleton Widgets

**Job Card Shimmer**
```dart
// lib/src/core/widgets/skeletons/job_card_shimmer.dart

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class JobCardShimmer extends StatelessWidget {
  const JobCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title placeholder
              Container(
                height: 20,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              // Description placeholder
              Container(
                height: 14,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                height: 14,
                width: 200,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              // Footer with budget and location
              Row(
                children: [
                  Container(
                    height: 16,
                    width: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    height: 16,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

**Craftsman Card Shimmer**
```dart
// lib/src/core/widgets/skeletons/craftsman_card_shimmer.dart

class CraftsmanCardShimmer extends StatelessWidget {
  const CraftsmanCardShimmer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        child: ListTile(
          leading: const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey,
          ),
          title: Container(
            height: 16,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Container(
                height: 12,
                width: 100,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 4),
              Container(
                height: 12,
                width: 80,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

#### 3.3 Use in Screens

```dart
// In Jobs List Screen
class JobsListScreen extends StatefulWidget {
  // ...
}

class _JobsListScreenState extends State<JobsListScreen> {
  bool _isLoading = true;
  List<Job> _jobs = [];

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Show skeleton loading
      return ListView.builder(
        itemCount: 5, // Show 5 skeleton cards
        itemBuilder: (context, index) => const JobCardShimmer(),
      );
    }

    if (_jobs.isEmpty) {
      return const EmptyState(
        icon: Icons.work_off,
        title: 'Nu există proiecte',
        message: 'Revino mai târziu pentru noi oportunități',
      );
    }

    return ListView.builder(
      itemCount: _jobs.length,
      itemBuilder: (context, index) => JobCard(job: _jobs[index]),
    );
  }
}
```

---

## 4. Error Handling Patterns

### Problem: Generic Error Messages
```dart
// BAD - Shows raw exception
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(content: Text(e.toString())),
);
// User sees: "Exception: SocketException: Network unreachable"
```

### Solution: User-Friendly Error System

#### 4.1 Create Error Type Enum

```dart
// lib/src/core/errors/error_type.dart

enum ErrorType {
  network,
  authentication,
  validation,
  server,
  notFound,
  forbidden,
  timeout,
  unknown,
}

class AppError {
  final ErrorType type;
  final String message;
  final String? technicalDetails;
  final bool canRetry;

  AppError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.canRetry = true,
  });

  factory AppError.fromException(dynamic exception) {
    if (exception is SocketException) {
      return AppError(
        type: ErrorType.network,
        message: 'Nu s-a putut conecta la server. Verifică conexiunea la internet.',
        technicalDetails: exception.toString(),
        canRetry: true,
      );
    }

    if (exception is FirebaseAuthException) {
      return AppError(
        type: ErrorType.authentication,
        message: _getFirebaseAuthMessage(exception.code),
        technicalDetails: exception.toString(),
        canRetry: false,
      );
    }

    if (exception is DioException) {
      switch (exception.response?.statusCode) {
        case 401:
          return AppError(
            type: ErrorType.authentication,
            message: 'Sesiunea ta a expirat. Te rugăm să te autentifici din nou.',
            technicalDetails: exception.toString(),
            canRetry: false,
          );
        case 404:
          return AppError(
            type: ErrorType.notFound,
            message: 'Resursa solicitată nu a fost găsită.',
            technicalDetails: exception.toString(),
            canRetry: false,
          );
        case 500:
        case 502:
        case 503:
          return AppError(
            type: ErrorType.server,
            message: 'Serverul întâmpină probleme. Te rugăm să încerci din nou mai târziu.',
            technicalDetails: exception.toString(),
            canRetry: true,
          );
        default:
          return AppError(
            type: ErrorType.unknown,
            message: 'A apărut o eroare neașteptată. Te rugăm să încerci din nou.',
            technicalDetails: exception.toString(),
            canRetry: true,
          );
      }
    }

    return AppError(
      type: ErrorType.unknown,
      message: 'A apărut o eroare. Te rugăm să încerci din nou.',
      technicalDetails: exception.toString(),
      canRetry: true,
    );
  }

  static String _getFirebaseAuthMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Nu există niciun utilizator cu acest email.';
      case 'wrong-password':
        return 'Parola este incorectă.';
      case 'email-already-in-use':
        return 'Acest email este deja înregistrat.';
      case 'weak-password':
        return 'Parola este prea slabă. Folosește minim 6 caractere.';
      case 'invalid-email':
        return 'Email-ul nu este valid.';
      default:
        return 'Autentificarea a eșuat. Te rugăm să încerci din nou.';
    }
  }
}
```

#### 4.2 Create Error View Widget

```dart
// lib/src/core/widgets/error_view.dart

class ErrorView extends StatelessWidget {
  final AppError error;
  final VoidCallback? onRetry;
  final String? retryButtonText;

  const ErrorView({
    Key? key,
    required this.error,
    this.onRetry,
    this.retryButtonText,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon based on type
            Icon(
              _getIconForErrorType(error.type),
              size: 64,
              color: _getColorForErrorType(error.type),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Error message
            Text(
              error.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: AppSpacing.xl),
            // Retry button (if error can be retried)
            if (error.canRetry && onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryButtonText ?? 'Încearcă din nou'),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForErrorType(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.authentication:
        return Icons.lock_outline;
      case ErrorType.notFound:
        return Icons.search_off;
      case ErrorType.forbidden:
        return Icons.block;
      case ErrorType.server:
        return Icons.cloud_off;
      default:
        return Icons.error_outline;
    }
  }

  Color _getColorForErrorType(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return MesteriColors.warning;
      case ErrorType.authentication:
      case ErrorType.forbidden:
        return MesteriColors.error;
      default:
        return Colors.grey;
    }
  }
}
```

#### 4.3 Use in Screens

```dart
class JobsListScreen extends StatefulWidget {
  // ...
}

class _JobsListScreenState extends State<JobsListScreen> {
  bool _isLoading = true;
  List<Job> _jobs = [];
  AppError? _error;

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final jobs = await _jobsService.getJobs();
      if (mounted) {
        setState(() {
          _jobs = jobs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = AppError.fromException(e);
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ListView.builder(
        itemCount: 5,
        itemBuilder: (context, index) => const JobCardShimmer(),
      );
    }

    if (_error != null) {
      return ErrorView(
        error: _error!,
        onRetry: _error!.canRetry ? _loadJobs : null,
      );
    }

    if (_jobs.isEmpty) {
      return const EmptyState(
        icon: Icons.work_off,
        title: 'Nu există proiecte',
        message: 'Revino mai târziu pentru noi oportunități',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadJobs,
      child: ListView.builder(
        itemCount: _jobs.length,
        itemBuilder: (context, index) => JobCard(job: _jobs[index]),
      ),
    );
  }
}
```

---

## 5. State Management with Provider

### Problem: setState Everywhere
- Business logic in UI
- No state caching
- Code duplication
- Hard to test

### Solution: Provider Pattern

#### 5.1 Create a Provider

```dart
// lib/src/features/jobs/providers/jobs_provider.dart

import 'package:flutter/foundation.dart';
import '../services/jobs_service.dart';
import '../models/job.dart';
import '../../../core/errors/app_error.dart';

class JobsProvider with ChangeNotifier {
  final JobsService _jobsService;

  JobsProvider(this._jobsService);

  // State
  List<Job> _jobs = [];
  bool _isLoading = false;
  AppError? _error;
  JobFilter _filter = JobFilter();

  // Getters
  List<Job> get jobs => _jobs;
  bool get isLoading => _isLoading;
  AppError? get error => _error;
  JobFilter get filter => _filter;

  List<Job> get filteredJobs {
    return _jobs.where((job) {
      if (_filter.category != null && job.category != _filter.category) {
        return false;
      }
      if (_filter.urgency != null && job.urgency != _filter.urgency) {
        return false;
      }
      return true;
    }).toList();
  }

  // Actions
  Future<void> loadJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _jobs = await _jobsService.getJobs();
      _error = null;
    } catch (e) {
      _error = AppError.fromException(e);
      _jobs = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createJob(Job job) async {
    try {
      final createdJob = await _jobsService.createJob(job);
      _jobs.insert(0, createdJob);
      notifyListeners();
    } catch (e) {
      _error = AppError.fromException(e);
      notifyListeners();
      rethrow;
    }
  }

  void setFilter(JobFilter filter) {
    _filter = filter;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
```

#### 5.2 Register Provider

```dart
// lib/main.dart

import 'package:provider/provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => JobsProvider(JobsService()),
        ),
        ChangeNotifierProvider(
          create: (_) => ProjectsProvider(ProjectsService()),
        ),
        // Add more providers...
      ],
      child: const MyApp(),
    ),
  );
}
```

#### 5.3 Use in Screen

```dart
// lib/src/features/jobs/presentation/screens/jobs_list_screen.dart

class JobsListScreen extends StatelessWidget {
  const JobsListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<JobsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (context, index) => const JobCardShimmer(),
          );
        }

        if (provider.error != null) {
          return ErrorView(
            error: provider.error!,
            onRetry: provider.error!.canRetry
                ? () {
                    provider.clearError();
                    provider.loadJobs();
                  }
                : null,
          );
        }

        final jobs = provider.filteredJobs;

        if (jobs.isEmpty) {
          return const EmptyState(
            icon: Icons.work_off,
            title: 'Nu există proiecte',
            message: 'Revino mai târziu pentru noi oportunități',
          );
        }

        return RefreshIndicator(
          onRefresh: () => provider.loadJobs(),
          child: ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) => JobCard(job: jobs[index]),
          ),
        );
      },
    );
  }
}
```

---

## 6. Form Validation

### Pattern: Inline Validation with Visual Feedback

```dart
// lib/src/features/jobs/presentation/screens/post_job_screen.dart

class PostJobScreen extends StatefulWidget {
  const PostJobScreen({Key? key}) : super(key: key);

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _budgetController = TextEditingController();

  bool _autoValidate = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Titlul este obligatoriu';
    }
    if (value.trim().length < 10) {
      return 'Titlul trebuie să aibă minim 10 caractere';
    }
    if (value.trim().length > 100) {
      return 'Titlul trebuie să aibă maxim 100 caractere';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Descrierea este obligatorie';
    }
    if (value.trim().length < 50) {
      return 'Descrierea trebuie să aibă minim 50 caractere';
    }
    return null;
  }

  String? _validateBudget(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bugetul este obligatoriu';
    }
    final budget = double.tryParse(value);
    if (budget == null) {
      return 'Bugetul trebuie să fie un număr valid';
    }
    if (budget < 50) {
      return 'Bugetul minim este 50 RON';
    }
    if (budget > 100000) {
      return 'Bugetul maxim este 100,000 RON';
    }
    return null;
  }

  Future<void> _submitForm() async {
    setState(() => _autoValidate = true);

    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Te rugăm să corectezi erorile din formular'),
          backgroundColor: MesteriColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final job = Job(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        budget: double.parse(_budgetController.text),
      );

      await Provider.of<JobsProvider>(context, listen: false).createJob(job);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Proiectul a fost postat cu succes!'),
            backgroundColor: MesteriColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Eroare: ${AppError.fromException(e).message}'),
            backgroundColor: MesteriColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Postează un proiect')),
      body: Form(
        key: _formKey,
        autovalidateMode: _autoValidate
            ? AutovalidateMode.onUserInteraction
            : AutovalidateMode.disabled,
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            // Title Field
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Titlu proiect *',
                hintText: 'Ex: Reparație robinet bucătărie',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.title),
              ),
              validator: _validateTitle,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Description Field
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descriere *',
                hintText: 'Descrie detaliat ce lucrări sunt necesare...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
              validator: _validateDescription,
              maxLines: 5,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: AppSpacing.lg),

            // Budget Field
            TextFormField(
              controller: _budgetController,
              decoration: const InputDecoration(
                labelText: 'Buget (RON) *',
                hintText: '500',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.attach_money),
                suffixText: 'RON',
              ),
              validator: _validateBudget,
              keyboardType: TextInputType.number,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: AppSpacing.xl),

            // Submit Button
            SizedBox(
              height: 48,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text('Postează proiectul'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## 7. Animations & Micro-interactions

### 7.1 Hero Animations

```dart
// In search results list
Hero(
  tag: 'craftsman-${craftsman.id}',
  child: CircleAvatar(
    radius: 30,
    backgroundImage: NetworkImage(craftsman.avatarUrl),
  ),
)

// In profile screen
Hero(
  tag: 'craftsman-${craftsman.id}',
  child: CircleAvatar(
    radius: 60,
    backgroundImage: NetworkImage(craftsman.avatarUrl),
  ),
)
```

### 7.2 Scale Animation on Press

```dart
// lib/src/core/widgets/animated_button.dart

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Duration animationDuration;
  final double scaleValue;

  const AnimatedButton({
    Key? key,
    required this.child,
    this.onPressed,
    this.animationDuration = const Duration(milliseconds: 150),
    this.scaleValue = 0.95,
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.scaleValue,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}

// Usage
AnimatedButton(
  onPressed: () => print('Pressed!'),
  child: ElevatedButton(
    onPressed: null, // Handled by AnimatedButton
    child: const Text('Click Me'),
  ),
)
```

### 7.3 Staggered List Animations

```dart
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

ListView.builder(
  itemCount: jobs.length,
  itemBuilder: (context, index) {
    return AnimationConfiguration.staggeredList(
      position: index,
      duration: const Duration(milliseconds: 375),
      child: SlideAnimation(
        verticalOffset: 50.0,
        child: FadeInAnimation(
          child: JobCard(job: jobs[index]),
        ),
      ),
    );
  },
)
```

---

## 8. Bottom Navigation Implementation

```dart
// lib/src/navigation/main_navigator.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainNavigator extends StatefulWidget {
  const MainNavigator({Key? key}) : super(key: key);

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;

  // Define main sections
  static const List<({String label, IconData icon, String route})> _sections = [
    (label: 'Acasă', icon: Icons.home_outlined, route: '/home'),
    (label: 'Proiecte', icon: Icons.work_outline, route: '/jobs'),
    (label: 'Feed', icon: Icons.video_library_outlined, route: '/feed'),
    (label: 'Mesaje', icon: Icons.chat_bubble_outline, route: '/messages'),
    (label: 'Profil', icon: Icons.person_outline, route: '/profile'),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    context.go(_sections[index].route);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoRouterOutletWidget(), // Displays current route
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: MesteriColors.primary,
        unselectedItemColor: Colors.grey,
        items: _sections
            .map((section) => BottomNavigationBarItem(
                  icon: Icon(section.icon),
                  label: section.label,
                ))
            .toList(),
      ),
    );
  }
}

// Configure GoRouter
final router = GoRouter(
  initialLocation: '/home',
  routes: [
    ShellRoute(
      builder: (context, state, child) => MainNavigator(child: child),
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/jobs',
          builder: (context, state) => const JobsListScreen(),
        ),
        GoRoute(
          path: '/feed',
          builder: (context, state) => const InspirationFeedScreen(),
        ),
        GoRoute(
          path: '/messages',
          builder: (context, state) => const MessagesScreen(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfileScreen(),
        ),
      ],
    ),
  ],
);
```

---

## 9. Code Quality Checklist

### Before Committing Code, Ensure:

#### UI/UX Quality
- [ ] All interactive elements have minimum 48x48 dp touch targets
- [ ] All colors meet WCAG 2.1 AA contrast requirements (4.5:1)
- [ ] All IconButtons have Semantics labels
- [ ] All Images have semantic labels
- [ ] Loading states show skeleton screens (not just spinners)
- [ ] Error states show user-friendly messages with retry options
- [ ] Empty states show helpful messages with CTAs
- [ ] Forms have inline validation with clear error messages
- [ ] All buttons show loading state during async operations
- [ ] Animations are smooth (60fps, no jank)

#### Code Quality
- [ ] No hardcoded strings (use i18n or constants)
- [ ] No hardcoded spacing (use AppSpacing constants)
- [ ] No hardcoded colors (use MesteriColors)
- [ ] No business logic in UI (use Provider or services)
- [ ] All async operations have error handling
- [ ] All streams/controllers are disposed properly
- [ ] No setState after dispose (check `mounted`)
- [ ] Const constructors where possible
- [ ] Meaningful variable and function names

#### Testing
- [ ] Unit tests for business logic
- [ ] Widget tests for complex widgets
- [ ] Accessibility tests with `meetsGuideline`
- [ ] Manual testing on both iOS and Android
- [ ] Testing with TalkBack/VoiceOver

#### Performance
- [ ] Images use `CachedNetworkImage`
- [ ] Long lists use `ListView.builder` (not ListView with children)
- [ ] Heavy operations use `compute` for isolates
- [ ] No unnecessary rebuilds (use const, Provider selectors)

---

## 🎉 Summary

This implementation guide provides:
- ✅ Concrete code examples for all major UI/UX improvements
- ✅ Copy-paste ready patterns for accessibility, loading, errors
- ✅ Best practices from 2025 industry standards
- ✅ Quality checklist to ensure consistency

**Next Steps**:
1. Review this guide with the development team
2. Start with **Quick Wins** from the MVP Completion Report
3. Follow the **3.5-week timeline** for systematic improvements
4. Use this guide as a reference during implementation

**Happy coding! 🚀**
