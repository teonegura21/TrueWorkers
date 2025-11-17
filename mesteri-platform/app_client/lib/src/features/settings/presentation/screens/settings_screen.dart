import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_client/src/core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  bool _notificationsEnabled = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _pushNotifications = true;
  bool _darkModeEnabled = false;
  String _language = 'ro';
  final String _currency = 'RON';
  double _fontSize = 16.0;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Setări',
          style: GoogleFonts.lato(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Section
              _buildAnimatedSection(_buildProfileSection()),

              const SizedBox(height: 32),

              // Account Settings
              _buildAnimatedSection(
                _buildSettingsSection('Setări Cont', Icons.account_circle, [
                  _buildSettingItem(
                    'Profilul Meu',
                    'Editează informațiile personale',
                    Icons.person_outline,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigare la Profil')),
                      );
                    },
                  ),
                  _buildSettingItem(
                    'Securitate',
                    'Schimbă parola și setări de securitate',
                    Icons.security_outlined,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigare la Securitate')),
                      );
                    },
                  ),
                  _buildSettingItem(
                    'Verificare Cont',
                    'Status verificare și documente',
                    Icons.verified_user_outlined,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigare la Verificare')),
                      );
                    },
                  ),
                ]),
              ),

              const SizedBox(height: 32),

              // Notifications Settings
              _buildAnimatedSection(
                _buildSettingsSection(
                  'Notificări',
                  Icons.notifications_outlined,
                  [
                    _buildSwitchSettingItem(
                      'Notificări',
                      'Activează/dezactivează toate notificările',
                      Icons.notifications_active_outlined,
                      _notificationsEnabled,
                      (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                    ),
                    if (_notificationsEnabled) ...[
                      _buildSwitchSettingItem(
                        'Email',
                        'Notificări prin email',
                        Icons.email_outlined,
                        _emailNotifications,
                        (value) {
                          setState(() {
                            _emailNotifications = value;
                          });
                        },
                      ),
                      _buildSwitchSettingItem(
                        'SMS',
                        'Notificări prin mesaj text',
                        Icons.sms_outlined,
                        _smsNotifications,
                        (value) {
                          setState(() {
                            _smsNotifications = value;
                          });
                        },
                      ),
                      _buildSwitchSettingItem(
                        'Push',
                        'Notificări push pe dispozitiv',
                        Icons.smartphone_outlined,
                        _pushNotifications,
                        (value) {
                          setState(() {
                            _pushNotifications = value;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Appearance Settings
              _buildAnimatedSection(
                _buildSettingsSection('Aspect', Icons.brush_outlined, [
                  _buildSwitchSettingItem(
                    'Mod Întunecat',
                    'Activează tema întunecată',
                    Icons.dark_mode_outlined,
                    _darkModeEnabled,
                    (value) {
                      setState(() {
                        _darkModeEnabled = value;
                      });
                    },
                  ),
                  _buildDropdownSettingItem(
                    'Limbă',
                    'Limba aplicației',
                    Icons.language_outlined,
                    _language,
                    ['ro', 'en'],
                    (value) {
                      if (value != null) {
                        setState(() {
                          _language = value;
                        });
                      }
                    },
                  ),
                  _buildSliderSettingItem(
                    'Dimensiune Text',
                    'Ajustează dimensiunea textului',
                    Icons.format_size_outlined,
                    _fontSize,
                    12.0,
                    20.0,
                    (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                  _buildSettingItem(
                    'Monedă preferată',
                    'Toate sumele sunt afișate în $_currency',
                    Icons.payments_outlined,
                    () => _showCurrencyInfo(),
                  ),
                ]),
              ),

              const SizedBox(height: 32),

              // Privacy Settings
              _buildAnimatedSection(
                _buildSettingsSection(
                  'Confidențialitate',
                  Icons.privacy_tip_outlined,
                  [
                    _buildSettingItem(
                      'Politica de Confidențialitate',
                      'Vezi politica noastră de confidențialitate',
                      Icons.policy_outlined,
                      () {
                        _showPrivacyPolicy();
                      },
                    ),
                    _buildSettingItem(
                      'Setări Cookie',
                      'Gestionează preferințele de cookie',
                      Icons.cookie_outlined,
                      () {
                        _showCookieSettings();
                      },
                    ),
                    _buildSettingItem(
                      'Partajare Date',
                      'Controlul partajării datelor cu terți',
                      Icons.data_usage_outlined,
                      () {
                        _showDataSharingSettings();
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Help & Support
              _buildAnimatedSection(
                _buildSettingsSection('Ajutor și Suport', Icons.help_outline, [
                  _buildSettingItem(
                    'Centru de Ajutor',
                    'Întrebări frecvente și ghiduri',
                    Icons.question_answer_outlined,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Navigare la Centru de Ajutor'),
                        ),
                      );
                    },
                  ),
                  _buildSettingItem(
                    'Contactează Suport',
                    'Trimite un mesaj echipei noastre',
                    Icons.support_agent_outlined,
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Navigare la Suport')),
                      );
                    },
                  ),
                  _buildSettingItem(
                    'Raportează o Problemă',
                    'Semnalează un bug sau o problemă',
                    Icons.bug_report_outlined,
                    () {
                      _showReportIssueDialog();
                    },
                  ),
                ]),
              ),

              const SizedBox(height: 32),

              // Legal
              _buildAnimatedSection(
                _buildSettingsSection('Legal', Icons.gavel_outlined, [
                  _buildSettingItem(
                    'Termeni și Condiții',
                    'Termenii de utilizare ai platformei',
                    Icons.description_outlined,
                    () {
                      _showTermsAndConditions();
                    },
                  ),
                  _buildSettingItem(
                    'Licențe Open Source',
                    'Licențele bibliotecilor folosite',
                    Icons.code_outlined,
                    () {
                      _showOpenSourceLicenses();
                    },
                  ),
                ]),
              ),

              const SizedBox(height: 32),

              // Danger Zone
              _buildAnimatedSection(_buildDangerZone()),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedSection(Widget child) {
    return FadeTransition(
      opacity: _animationController.drive(CurveTween(curve: Curves.easeOut)),
      child: SlideTransition(
        position: _animationController.drive(
          Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeOutCubic)),
        ),
        child: child,
      ),
    );
  }

  Widget _buildProfileSection() {
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
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.person, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ion Popescu',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ion.popescu@email.com',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.successColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.successColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'Cont Verificat',
                    style: TextStyle(
                      color: AppTheme.successColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Editează Profil')));
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(
    String title,
    IconData icon,
    List<Widget> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppTheme.primaryColor, size: 24),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceSecondary),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: AppTheme.onSurfaceSecondary,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchSettingItem(
    String title,
    String subtitle,
    IconData icon,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      secondary: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceSecondary),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.primaryColor,
    );
  }

  Widget _buildDropdownSettingItem(
    String title,
    String subtitle,
    IconData icon,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 24),
      ),
      title: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceSecondary),
      ),
      trailing: DropdownButton<String>(
        value: value,
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(item.toUpperCase()),
          );
        }).toList(),
        onChanged: onChanged,
        underline: Container(),
      ),
      onTap: null,
    );
  }

  Widget _buildSliderSettingItem(
    String title,
    String subtitle,
    IconData icon,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppTheme.primaryColor, size: 24),
          ),
          title: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
          ),
          subtitle: Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceSecondary),
          ),
          trailing: Text(
            '${value.toStringAsFixed(0)}px',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryColor,
            ),
          ),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: (max - min).toInt(),
          label: value.toStringAsFixed(0),
          activeColor: AppTheme.primaryColor,
          inactiveColor: Colors.grey[300],
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.errorColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber,
                  color: AppTheme.errorColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Zonă Periculoasă',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.errorColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Acțiunile din această secțiune sunt ireversibile și pot duce la pierderea permanentă a datelor tale.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.onSurfaceSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildDangerButton(
            'Dezactivează Cont',
            'Contul tău va fi dezactivat temporar',
            Icons.pause_circle_outline,
            AppTheme.warningColor,
            () {
              _showDeactivateAccountDialog();
            },
          ),
          const SizedBox(height: 12),
          _buildDangerButton(
            'Șterge Permanent Contul',
            'Toate datele tale vor fi șterse definitiv',
            Icons.delete_forever,
            AppTheme.errorColor,
            () {
              _showDeleteAccountDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDangerButton(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceSecondary),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: AppTheme.onSurfaceSecondary,
        ),
        onTap: onTap,
      ),
    );
  }

  void _showCurrencyInfo() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Moneda curentă este $_currency.')));
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.policy, color: AppTheme.primaryColor, size: 24),
              SizedBox(width: 12),
              Text('Politica de Confidențialitate'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\n'
              'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n'
              'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',
              style: TextStyle(height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Închide'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Politica de Confidențialitate descărcată'),
                  ),
                );
              },
              child: const Text('Descarcă PDF'),
            ),
          ],
        );
      },
    );
  }

  void _showCookieSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.cookie, color: AppTheme.primaryColor, size: 24),
              SizedBox(width: 12),
              Text('Setări Cookie'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Gestionează preferințele tale privind cookie-urile',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Cookie-uri Esențiale'),
                subtitle: const Text('Necesare pentru funcționarea aplicației'),
                value: true,
                onChanged: null,
                activeThumbColor: AppTheme.primaryColor,
              ),
              SwitchListTile(
                title: const Text('Cookie-uri Analitice'),
                subtitle: const Text(
                  'Ne ajută să înțelegem cum folosești aplicația',
                ),
                value: true,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Setări cookie actualizate')),
                  );
                  Navigator.pop(context);
                },
                activeThumbColor: AppTheme.primaryColor,
              ),
              SwitchListTile(
                title: const Text('Cookie-uri de Marketing'),
                subtitle: const Text('Folosite pentru reclame personalizate'),
                value: false,
                onChanged: (value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Setări cookie actualizate')),
                  );
                  Navigator.pop(context);
                },
                activeThumbColor: AppTheme.primaryColor,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Preferințe cookie salvate'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Salvează'),
            ),
          ],
        );
      },
    );
  }

  void _showDataSharingSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.data_usage, color: AppTheme.primaryColor, size: 24),
              SizedBox(width: 12),
              Text('Partajare Date'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Controlul partajării datelor cu terți',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.primaryColor.withValues(alpha: 0.1),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Datele tale personale nu sunt partajate cu terți fără consimțământul tău explicit.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Partajare Activă: 0 parteneri',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Închide'),
            ),
          ],
        );
      },
    );
  }

  void _showReportIssueDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.bug_report, color: AppTheme.primaryColor, size: 24),
              SizedBox(width: 12),
              Text('Raportează o Problemă'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Descrie problema pe care ai întâmpinat-o...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info, color: Colors.amber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Echipa noastră va analiza problema și te vom contacta prin email.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.amber,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Problemă raportată cu succes!'),
                    backgroundColor: AppTheme.successColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Trimite'),
            ),
          ],
        );
      },
    );
  }

  void _showTermsAndConditions() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.description, color: AppTheme.primaryColor, size: 24),
              SizedBox(width: 12),
              Text('Termeni și Condiții'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.\n\n'
              'Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.\n\n'
              'Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.',
              style: TextStyle(height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Închide'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Termenii și Condițiile au fost descărcate'),
                  ),
                );
              },
              child: const Text('Descarcă PDF'),
            ),
          ],
        );
      },
    );
  }

  void _showOpenSourceLicenses() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.code, color: AppTheme.primaryColor, size: 24),
              SizedBox(width: 12),
              Text('Licențe Open Source'),
            ],
          ),
          content: const SingleChildScrollView(
            child: Text(
              'Această aplicație folosește următoarele biblioteci open source:\n\n'
              'â€¢ Flutter - Licență BSD\n'
              'â€¢ Dart - Licență BSD\n'
              'â€¢ Provider - Licență MIT\n'
              'â€¢ Http - Licență BSD\n'
              'â€¢ Shared Preferences - Licență BSD\n'
              'â€¢ Path Provider - Licență BSD\n'
              'â€¢ Flutter SVG - Licență MIT\n'
              'â€¢ Intl - Licență BSD\n\n'
              'Toate licențele sunt conforme cu politicile noastre de utilizare.',
              style: TextStyle(height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Închide'),
            ),
          ],
        );
      },
    );
  }

  void _showDeactivateAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.pause_circle, color: AppTheme.warningColor, size: 24),
              SizedBox(width: 12),
              Text('Dezactivează Contul'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Ești sigur că vrei să dezactivezi contul?',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'â€¢ Contul tău va fi dezactivat temporar\n'
                'â€¢ Profilul tău nu va mai fi vizibil\n'
                'â€¢ Poți reactiva contul oricând\n'
                'â€¢ Datele tale vor fi păstrate',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Introdu parola pentru confirmare',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contul a fost dezactivat'),
                    backgroundColor: AppTheme.warningColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.warningColor,
              ),
              child: const Text('Dezactivează'),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.delete_forever, color: AppTheme.errorColor, size: 24),
              SizedBox(width: 12),
              Text('Șterge Permanent Contul'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Această acțiune este IREVERSIBILĂ!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.errorColor,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Ești SIGUR că vrei să ȘTERGI PERMANENT contul tău?',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.errorColor.withValues(alpha: 0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'URMĂTOARELE DATE VOR FI ȘTERSE DEFINITIV:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.errorColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'â€¢ Toate profilurile tale\n'
                      'â€¢ Istoricul tranzacțiilor\n'
                      'â€¢ Recenziile și ratingurile\n'
                      'â€¢ Conversațiile și mesajele\n'
                      'â€¢ Documentele de verificare',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.onSurfaceSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Introdu â€žȘTERGE CONTUL MEUâ€ pentru confirmare',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  hintText: 'Introdu parola pentru confirmare',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Contul a fost șters permanent'),
                    backgroundColor: AppTheme.errorColor,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.errorColor,
              ),
              child: const Text('Șterge Permanent'),
            ),
          ],
        );
      },
    );
  }
}
