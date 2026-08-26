# Roadmap

Suit le cahier des charges (Cahier_des_charges_OOLA_Mobile). Aligne sur les
phases du document.

## Phase 1 — Socle (fait)

- [x] Projet Flutter, structure feature-first + couches.
- [x] Theme de marque OOLA (flat, orange), locale fr.
- [x] Client Dio + interceptor Bearer/401, `ApiException`.
- [x] Stockage chiffre du token (`SecureStore`).
- [x] Session + garde de navigation par role (go_router).
- [x] Ecrans login (acheteur OTP + espace pro) et coquilles par role.
- [x] Services biometrie et anti-capture (a brancher aux ecrans).
- [x] Config native Android/iOS (permissions, FlutterFragmentActivity, Face ID).

## Phase 2 — Fonctionnalites + connexion API (fait)

- [x] Feed video vertical (autoplay/pause au scroll, son coupe par defaut).
- [x] Fiche produit : video, prix, stock, variantes, avis, questions.
- [x] Recherche + filtres par categorie.
- [x] Panier, favoris, partage.
- [x] Commande : coordonnees, frais de livraison par zone, code promo.
- [x] Suivi de commande + code de confirmation a la reception.
- [x] Compte : profil, adresses, historique, notifications.
- [x] Vendeur : dashboard, ajout produit (video galerie ou lien externe).
- [x] Vendeur : portefeuille (recharge Mobile Money, retraits), commandes (marquer prete).
- [x] Livreur : file, prise en charge, confirmation par code.
- [ ] Reste : ecriture d'avis/questions, ventes flash & coupons vendeur, sponsoring, boutique/documents vendeur.

## Phase 3 — Securite, paiement, video

- [x] Verrou biometrique a l'ouverture + re-verif operations sensibles (paiement, retrait, mot de passe, suppression).
- [x] Anti-capture sur suivi de commande (code) et portefeuille vendeur.
- [x] Paiement Mobile Money (ouverture page de paiement + suivi du statut).
- [ ] Compression video sur l'appareil + poster auto (upload direct en place).

## Phase 4 — Notifications et finitions

- [ ] Push Firebase (voir docs/PUSH.md), notifications par role.
- [ ] Cache hors ligne (produits/commandes recents) via Hive.
- [ ] Economie de donnees (video a la demande).

## Phase 5 — Publication

- [ ] Icones, splash, signature, builds de test.
- [ ] Publication Play Store puis App Store.
