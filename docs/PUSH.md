# Notifications push (Firebase) — a activer

Les notifications ne sont pas encore branchees pour garder le socle buildable
sans fichiers de config Firebase. Etapes d'activation (Phase 4) :

1. Creer un projet Firebase et ajouter les apps Android (`com.oolashop.oola_mobile`)
   et iOS (meme bundle id).
2. Installer FlutterFire : `dart pub global activate flutterfire_cli` puis
   `flutterfire configure` (genere `lib/firebase_options.dart`).
3. Deposer `android/app/google-services.json` et
   `ios/Runner/GoogleService-Info.plist` (ne pas committer si prive).
4. Reactiver dans `pubspec.yaml` : `firebase_core`, `firebase_messaging`,
   `flutter_local_notifications`.
5. Initialiser Firebase dans `main.dart` et enregistrer le token FCM cote API.

Cote backend, prevoir l'endpoint d'enregistrement du token de l'appareil et
l'envoi des notifications par role (cahier des charges §6.1) :
- Acheteur : confirmation de commande, changements d'etat, code de confirmation, promotions.
- Vendeur : nouvelle commande, produit accepte/refuse, mise en avant validee, nouvel avis, mouvement portefeuille.
- Livreur : nouvelle livraison disponible.
