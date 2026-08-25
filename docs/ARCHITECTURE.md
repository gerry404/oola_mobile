# Architecture

## Principes

- **Feature-first + couches.** Chaque fonctionnalite vit dans `lib/features/<feature>/`
  et se decompose en trois couches :
  - `data/` — repositories, appels reseau (Dio), mapping JSON.
  - `application/` — logique metier et etat (Riverpod Notifiers / providers).
  - `presentation/` — ecrans et widgets.
- **Le noyau est partage.** `lib/core/` contient l'infrastructure transverse
  (reseau, stockage, securite, config) ; `lib/shared/` les modeles et widgets communs.
- **Aucune URL/secret en dur.** La cible API vient de `--dart-define` (voir `core/config/env.dart`).
- **Pas de reconstruction backend.** L'app consomme l'API Laravel existante.

## Arborescence

```
lib/
  main.dart                      Point d'entree (ProviderScope + locale fr)
  app/
    app.dart                     MaterialApp.router
    router.dart                  go_router + garde par role
    theme/                       Palette de marque + ThemeData (flat, orange OOLA)
  core/
    config/env.dart              Base API, origine site (dart-define)
    network/
      dio_client.dart            Client Dio + interceptor Bearer + 401
      api_exception.dart         Erreur normalisee (message + erreurs par champ)
    storage/secure_store.dart    Token/prefs chiffres (Keystore/Keychain)
    auth/biometric_service.dart  Empreinte / Face (local_auth)
    security/secure_screen.dart  Anti-capture d'ecran (ecrans sensibles)
    utils/formatters.dart        FCFA, dates fr
    providers.dart               DI Riverpod (dio, secureStore, biometrie)
  shared/
    models/                      Modeles freezed partages (User, ...)
    widgets/                     BrandLogo, FeaturePlaceholder, ...
  features/
    auth/        data · application · presentation (login OTP + espace pro)
    client/      espace acheteur (feed video, recherche, panier)
    vendor/      espace vendeur (dashboard, produits, portefeuille)
    delivery/    espace livreur (file de livraisons)
    account/     onglet compte partage (profil, deconnexion)
```

## Authentification

Le token Sanctum est stocke **chiffre** (`flutter_secure_storage`) et ajoute a
chaque requete par l'interceptor Dio. `AuthController` (source de verite de la
session) :

1. Au demarrage, tente de restaurer la session via `/auth/me`.
2. Expose `requestClientCode` + `clientLogin` (acheteur, OTP) et `login`
   (vendeur/livreur/admin, email + mot de passe).
3. Sur **401**, l'interceptor purge le token et emet un signal ; la session
   repasse en `unauthenticated` et le router redirige vers le login.

Le `router` redirige selon le role : acheteur -> `/home`, vendeur -> `/vendor`,
livreur -> `/delivery` (l'admin utilise l'espace acheteur + moderation).

## Securite (cahier des charges §3)

- **Biometrie** (`BiometricService`) : deverrouillage de l'app et re-verification
  avant les operations sensibles (paiement, retrait, changement de mot de passe,
  suppression de compte). Repli sur code si indisponible.
- **Anti-capture** (`SecureScreen`) : a envelopper autour des ecrans paiement,
  portefeuille et code de livraison.
- **Stockage chiffre** : jamais de token en clair.

## Conventions

- Modeles immuables en **freezed** + `json_serializable` ; lancer
  `dart run build_runner build` apres toute modif de modele.
- Etat via **Riverpod** ; pas de logique metier dans les widgets.
- Erreurs reseau toujours converties en `ApiException` dans les repositories.
- Montants en **FCFA** via `formatCFA` ; textes en francais, sans emoji.
