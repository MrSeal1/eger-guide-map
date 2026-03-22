import 'package:flutter/material.dart';
import 'package:maps_testing/logic/services/auth_service.dart';
import 'package:maps_testing/logic/user_data_provider.dart';
import 'package:maps_testing/pages/favorites_page.dart';
import 'package:maps_testing/pages/info_page.dart';
import 'package:maps_testing/pages/my_tours_page.dart';
import 'package:maps_testing/pages/reviews_page.dart';
import 'package:maps_testing/pages/settings_page.dart';
import 'package:provider/provider.dart';

class ProfilePageWidget extends StatelessWidget {
  const ProfilePageWidget({super.key});

  Widget _buildCard(BuildContext context, List<Widget> children) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(mainAxisSize: MainAxisSize.min, children: children),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: (iconColor ?? Theme.of(context).colorScheme.primary).withAlpha(
            25,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: iconColor ?? Theme.of(context).colorScheme.primary,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 18,
        color: Theme.of(context).hintColor,
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Fiók törlése'),
            ],
          ),
          content: const Text(
            'Biztosan törölni szeretnéd a fiókodat és minden mentett adatodat? Ez a művelet nem vonható vissza!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Mégse', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  await AuthService().deleteAccount();
                  if (context.mounted) {
                    context.read<UserDataProvider>().clearUserData();

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          "A fiók és minden adata sikeresen törölve lett.",
                        ),
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(e.toString()),
                        duration: const Duration(seconds: 5),
                      ),
                    );
                  }
                }
                if(context.mounted) {
                  Navigator.of(dialogContext).pop();
                }
              },
              child: const Text('Igen, törlöm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userEmail = context.watch<UserDataProvider>().userEmail;
    final initial = userEmail.isNotEmpty ? userEmail[0].toUpperCase() : '?';

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final dividerColor = theme.dividerColor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),

              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: colorScheme.primary,
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 40,
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userEmail,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // 1. Fiók kártya
              _buildCard(context, [
                _buildProfileItem(
                  context,
                  icon: Icons.favorite,
                  title: 'Kedvenc helyeim',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const FavoritesPage(),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: dividerColor,
                ),
                _buildProfileItem(
                  context,
                  icon: Icons.star,
                  title: 'Értékeléseim',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ReviewsPage(),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: dividerColor,
                ),
                _buildProfileItem(
                  context,
                  icon: Icons.route,
                  title: 'Saját túráim',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const MyToursPage(),
                      ),
                    );
                  },
                ),
              ]),

              // 2. beállítások és infó
              _buildCard(context, [
                _buildProfileItem(
                  context,
                  icon: Icons.settings,
                  title: 'Beállítások',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: dividerColor,
                ),
                _buildProfileItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'Az alkalmazásról',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const InfoPage()),
                    );
                  },
                ),
              ]),

              // 3. kijelentkezés és profil törlése
              _buildCard(context, [
                _buildProfileItem(
                  context,
                  icon: Icons.logout,
                  title: 'Kijelentkezés',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () async {
                    context.read<UserDataProvider>().clearUserData();
                    await AuthService().signOut();
                  },
                ),
                Divider(
                  height: 1,
                  indent: 20,
                  endIndent: 20,
                  color: dividerColor,
                ),
                _buildProfileItem(
                  context,
                  icon: Icons.delete,
                  title: 'Fiók végleges törlése',
                  iconColor: Colors.red,
                  textColor: Colors.red,
                  onTap: () {
                    _showDeleteAccountDialog(context);
                  },
                ),
              ]),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
