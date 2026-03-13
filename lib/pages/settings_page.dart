import 'package:flutter/material.dart';
import 'package:maps_testing/logic/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Color> colorOptions = [
      Colors.green[700]!,
      Colors.blue[700]!,
      Colors.purple[700]!,
      Colors.red[700]!,
      Colors.orange[700]!,
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Beállítások'), centerTitle: true),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Megjelenés',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ),

              SwitchListTile(
                title: const Text('Sötét mód'),
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: Theme.of(context).colorScheme.primary,
                ),
                value: themeProvider.isDarkMode,
                onChanged: (value) => themeProvider.toggleTheme(value),
              ),

              const Divider(indent: 16, endIndent: 16),

              const ListTile(title: Text('Kiemelő szín')),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: colorOptions.map((color) {
                    final isSelected =
                        themeProvider.accentColor.toARGB32() ==
                        color.toARGB32();
                    return GestureDetector(
                      onTap: () => themeProvider.setAccentColor(color),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: isSelected
                              ? Border.all(
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodyLarge!.color!,
                                  width: 3,
                                )
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 20,
                              )
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
