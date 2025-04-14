import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class AccountCenterScreen extends StatelessWidget {
  const AccountCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.accountCenter),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          ListTile(
            leading: const Icon(Icons.person),
            title: Text('Modifier le profil'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigation vers l'édition de profil
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.lock),
            title: Text('Changer le mot de passe'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigation vers le changement de mot de passe
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.email),
            title: Text('Changer l\'email'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigation vers le changement d'email
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text('Paramètres de notification'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // Navigation vers les paramètres de notification
            },
          ),
        ],
      ),
    );
  }
}