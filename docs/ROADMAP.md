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

## Phase 2 — Fonctionnalites + connexion API

- [ ] Feed video vertical (autoplay/pause au scroll, son coupe par defaut).
- [ ] Fiche produit : video, prix, stock, variantes, avis, questions.
- [ ] Recherche + filtres par categorie ; boutiques.
- [ ] Panier, favoris, partage.
- [ ] Commande : adresse, frais de livraison par zone, code promo.
- [ ] Suivi de commande + code de confirmation a la reception.
- [ ] Compte : profil, adresses, historique, notifications.
- [ ] Vendeur : dashboard, ajout produit (video + poster), boutique, documents.
- [ ] Vendeur : portefeuille (recharge Mobile Money, retraits), commandes, sponsoring, ventes flash, coupons.
- [ ] Livreur : file, prise en charge, confirmation par code.

## Phase 3 — Securite, paiement, video

- [ ] Activation biometrie apres 1re connexion + re-verif operations sensibles.
- [ ] Anti-capture sur paiement / portefeuille / code de livraison.
- [ ] Paiement Mobile Money (retour dans l'app + mise a jour du statut).
- [ ] Compression video sur l'appareil + poster auto.

## Phase 4 — Notifications et finitions

- [ ] Push Firebase (voir docs/PUSH.md), notifications par role.
- [ ] Cache hors ligne (produits/commandes recents) via Hive.
- [ ] Economie de donnees (video a la demande).

## Phase 5 — Publication

- [ ] Icones, splash, signature, builds de test.
- [ ] Publication Play Store puis App Store.
