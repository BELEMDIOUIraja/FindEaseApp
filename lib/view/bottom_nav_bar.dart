import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as material;
import 'home_screen.dart';
import 'booking_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import 'account_center_screen.dart';
import 'match_reference_view.dart';
import 'match_housing_offers_view.dart';


class BottomNavBar extends StatelessWidget {
  final BuildContext context;
  final int currentIndex;

  const BottomNavBar({
    super.key,
    required this.context,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: Colors.orange,
      unselectedItemColor: Colors.grey,
      onTap: (index) => _onItemTapped(index, context),
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Icons.home),
          label: localizations.home,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.map),
          label: 'MatchMap', // Texte statique
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.help),
          label: localizations.help,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Icons.settings),
          label: localizations.settings,
        ),
      ],
    );
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        if (ModalRoute.of(context)?.settings.name != '/') {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
                (Route<dynamic> route) => false,
          );
        }
        break;
      case 1: // MatchMap
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const MatchReferenceView(),
          ),
        ).then((result) {
          if (result == 'success') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const MatchHousingOffersView(),
              ),
            );
          }
        });
        break;
      case 2: // Help
        _showHelpDialog(context);
        break;
      case 3: // Settings
        _showSettingsModal(context);
        break;
    }
  }

 void _showHelpDialog(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.assistance),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizations.helpQuestion),
            const SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: localizations.describeProblem,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(localizations.requestSent)),
              );
            },
            child: Text(localizations.send),
          ),
        ],
      ),
    );
  }

  void _showSettingsModal(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.settings,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(localizations.language),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showLanguageOptions(context),
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              title: Text(localizations.theme),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeOptions(context),
            ),
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(localizations.accountCenter),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _navigateToAccountCenter(context),
            ),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(localizations.logout, style: const TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguageOptions(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.changeLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Français'),
              onTap: () {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale(const Locale('fr'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('English'),
              onTap: () {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('العربية'),
              onTap: () {
                Provider.of<LocaleProvider>(context, listen: false)
                    .setLocale(const Locale('ar'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeOptions(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sélection du thème'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<ThemeMode>(
              title: const Text('Thème clair'),
              value: ThemeMode.light,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.themeMode = value!;
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Thème sombre'),
              value: ThemeMode.dark,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.themeMode = value!;
                Navigator.pop(context);
              },
            ),
            RadioListTile<ThemeMode>(
              title: const Text('Système'),
              value: ThemeMode.system,
              groupValue: themeProvider.themeMode,
              onChanged: (value) {
                themeProvider.themeMode = value!;
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAccountCenter(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AccountCenterScreen()),
    );
  }

  void _logout(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.logout),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              // Ajoutez ici votre logique de déconnexion
              Navigator.popUntil(context, (route) => route.isFirst);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
            child: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}