# OOLAshop Mobile

Application mobile **OOLAshop** (Android + iOS) en **Flutter**, marketplace de vente
en ligne par video pour la Cote d'Ivoire. Elle se connecte a la plateforme
existante (API Laravel/Sanctum sur https://oolashop.com) : memes produits, memes
comptes, memes regles que le site web.

## Demarrer

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs   # genere freezed/json
flutter run
```

### Choisir l'API cible

La base de l'API est injectee au build (aucune URL en dur dans le code) :

```bash
# Production (defaut)
flutter run

# Backend local (emulateur Android -> 10.0.2.2)
flutter run --dart-define=OOLA_API_BASE=http://10.0.2.2:8000/api --dart-define=OOLA_NET_LOGS=true
```

## Documentation

- [Architecture](docs/ARCHITECTURE.md) — structure du code, conventions, flux d'auth.
- [Roadmap](docs/ROADMAP.md) — modules livres et a venir.
- [Notifications push](docs/PUSH.md) — activation Firebase (a faire).

## Stack

Riverpod (etat) · Dio (reseau) · go_router (navigation) · freezed (modeles) ·
flutter_secure_storage (token chiffre) · local_auth (biometrie) · Hive (cache
hors ligne) · video_player (feed) · screen_protector (anti-capture).
