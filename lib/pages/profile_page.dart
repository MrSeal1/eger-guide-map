import 'package:flutter/material.dart';
import 'package:maps_testing/pages/favorites_page.dart';

class ProfilePageWidget extends StatelessWidget {
  const ProfilePageWidget({super.key});

  static const String routeName = 'ProfilePage';
  static const String routePath = '/profilePage';

  Widget _buildCard(BuildContext context, List<Widget> children) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: children,
        ),
      ),
    );
  }

  Widget _buildProfileItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.green.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.green.shade800, size: 24),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.grey),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff5f5f5),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 30),
              
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: const DecorationImage(
                      image: NetworkImage('https://picsum.photos/seed/900/600'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),

              // 2. Fiók Kártya
              _buildCard(context, [
                _buildProfileItem(
                  context,
                  icon: Icons.favorite,
                  title: 'Kedvenc helyeim',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const FavoritesPage()),
                    );
                  },
                ),
                Divider(height: 1, indent: 70, endIndent: 20, color: Colors.grey.shade200),
                _buildProfileItem(
                  context,
                  icon: Icons.star,
                  title: 'Értékeléseim',
                  onTap: () {
                    // TODO: Értékelések oldal
                  },
                ),
              ]),

              _buildCard(context, [
                _buildProfileItem(
                  context,
                  icon: Icons.settings,
                  title: 'Beállítások',
                  onTap: () {},
                ),
                Divider(height: 1, indent: 70, endIndent: 20, color: Colors.grey.shade200),
                _buildProfileItem(
                  context,
                  icon: Icons.download,
                  title: 'Helyi adatok letöltése',
                  onTap: () {},
                ),
                Divider(height: 1, indent: 70, endIndent: 20, color: Colors.grey.shade200),
                _buildProfileItem(
                  context,
                  icon: Icons.info_outline,
                  title: 'Az alkalmazásról',
                  onTap: () {},
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