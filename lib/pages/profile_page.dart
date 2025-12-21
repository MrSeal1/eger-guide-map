import 'package:flutter/material.dart';

class ProfilePageWidget extends StatelessWidget {
  const ProfilePageWidget({super.key});

  static const String routeName = 'ProfilePage';
  static const String routePath = '/profilePage';

  Widget _buildCard(BuildContext context, List<Widget> children) {
    final width = MediaQuery.of(context).size.width * 0.9;
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Container(
        width: width,
        decoration: BoxDecoration(
          color: Color(0xffffffff),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.titleLarge;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Color(0xf1f4f8ff), //theme.colorScheme.background,
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: AlignmentDirectional(0, -1),
                child: Container(
                  width: 150,
                  height: 150,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: Image.network(
                    'https://picsum.photos/seed/900/600',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 48),
                  child: _buildCard(context, [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.favorite_border),
                              title: Text('Kedvenc helyeim', style: titleStyle),
                              trailing: Icon(Icons.arrow_forward_ios_rounded,
                                  color: theme.textTheme.bodySmall?.color, size: 24),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            ListTile(
                              leading: const Icon(Icons.star_border),
                              title: Text('Értékeléseim', style: titleStyle),
                              trailing: Icon(Icons.arrow_forward_ios_rounded,
                                  color: theme.textTheme.bodySmall?.color, size: 24),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _buildCard(context, [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.settings_outlined),
                              title: Text('Beállítások', style: titleStyle),
                              trailing: Icon(Icons.arrow_forward_ios_rounded,
                                  color: theme.textTheme.bodySmall?.color, size: 24),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            ListTile(
                              leading: const Icon(Icons.download_outlined),
                              title: Text('Helyi adatok letöltése', style: titleStyle),
                              trailing: Icon(Icons.arrow_forward_ios_rounded,
                                  color: theme.textTheme.bodySmall?.color, size: 24),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
              Flexible(
                child: Padding(
                  padding: const EdgeInsets.only(top: 24),
                  child: _buildCard(context, [
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: ListView(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          children: [
                            ListTile(
                              title: Text('Az alkalmazásról', style: titleStyle),
                              trailing: Icon(Icons.arrow_forward_ios_rounded,
                                  color: theme.textTheme.bodySmall?.color, size: 24),
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
