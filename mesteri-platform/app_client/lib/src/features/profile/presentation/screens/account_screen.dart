import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_theme.dart';
import 'package:app_client/src/core/services/comprehensive_service.dart';
import 'package:app_client/src/features/profile/application/user_profile_controller.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  late final UserProfileController _controller;

  @override
  void initState() {
    super.initState();
    _controller = UserProfileController();
    // Assuming you have a way to get the current user's ID
    // For now, we'll use a placeholder or fetch it from a global state/auth service
    // This needs to be replaced with actual user ID from authenticated session
    _controller.fetchUserProfile('user_123'); // TODO: Replace with actual user ID
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Consumer<UserProfileController>(
        builder: (context, controller, child) {
          final userProfile = controller.userProfile;
          final isLoading = controller.isLoading;
          final error = controller.error;

          return Scaffold(
            appBar: AppBar(
              title: const Text('Cont'),
              automaticallyImplyLeading: false,
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Eroare: $error'),
                            ElevatedButton(
                              onPressed: () => controller.fetchUserProfile('user_123'), // TODO: Replace with actual user ID
                              child: const Text('Reîncercă'),
                            ),
                          ],
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          // Profile header
                          _buildProfileHeader(userProfile),

                          const SizedBox(height: 24),

                          // Menu items
                          _buildMenuItem(
                            context,
                            icon: Icons.person_outline,
                            title: 'Profilul Meu',
                            subtitle: 'Editează informațiile personale',
                            onTap: () {
                              Navigator.pushNamed(context, '/edit-profile');
                            },
                          ),

                          _buildMenuItem(
                            context,
                            icon: Icons.payment,
                            title: 'Metode de Plată',
                            subtitle: 'Gestionează cardurile și plățile',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Funcționalitatea va fi disponibilă în curând'),
                                ),
                              );
                            },
                          ),

                          _buildMenuItem(
                            context,
                            icon: Icons.history,
                            title: 'Istoric Tranzacții',
                            subtitle: 'Vezi toate plățile efectuate',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Funcționalitatea va fi disponibilă în curând'),
                                ),
                              );
                            },
                          ),

                          _buildMenuItem(
                            context,
                            icon: Icons.notifications_outlined,
                            title: 'Notificări',
                            subtitle: 'Configurează preferințele de notificare',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Funcționalitatea va fi disponibilă în curând'),
                                ),
                              );
                            },
                          ),

                          _buildMenuItem(
                            context,
                            icon: Icons.security,
                            title: 'Securitate',
                            subtitle: 'Schimbă parola și setări de securitate',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Funcționalitatea va fi disponibilă în curând'),
                                ),
                              );
                            },
                          ),

                          _buildMenuItem(
                            context,
                            icon: Icons.help_outline,
                            title: 'Centru de Ajutor',
                            subtitle: 'FAQ și suport tehnic',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Funcționalitatea va fi disponibilă în curând'),
                                ),
                              );
                            },
                          ),

                          _buildMenuItem(
                            context,
                            icon: Icons.info_outline,
                            title: 'Despre Aplicație',
                            subtitle: 'Versiune și informații legale',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Funcționalitatea va fi disponibilă în curând'),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // Logout button
                          _buildLogoutButton(context, controller),

                          const SizedBox(height: 24),
                        ],
                      ),
          );
        },
      ),
    );
  }

  Widget _buildProfileHeader(UserProfile? userProfile) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
            backgroundImage: userProfile?.profilePicture != null
                ? NetworkImage(userProfile!.profilePicture!) as ImageProvider
                : null,
            child: userProfile?.profilePicture == null
                ? Icon(
                    Icons.person,
                    size: 32,
                    color: AppTheme.primaryColor,
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userProfile?.name ?? 'Nume Utilizator',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userProfile?.email ?? 'email@exemplu.com',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                if (userProfile != null && userProfile.isVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Cont Verificat',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.edit,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: AppTheme.primaryColor,
            size: 20,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.grey[400],
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        tileColor: Colors.grey[50],
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, UserProfileController controller) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          _showLogoutDialog(context, controller);
        },
        icon: const Icon(Icons.logout),
        label: const Text('Deconectează-te'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, UserProfileController controller) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Deconectare'),
          content: const Text('Ești sigur că vrei să te deconectezi?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Anulează'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await controller.logout();
                if (!mounted) return;
                // Navigate back to welcome screen
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/',
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Deconectează-te'),
            ),
          ],
        );
      },
    );
  }
}