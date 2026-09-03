# Solitaire

Klondike sans publicité, hors ligne, installable sur iPhone et Android.

## Contenu

| Fichier | Rôle |
|---|---|
| `index.html` | Le jeu complet, un seul fichier |
| `manifest.webmanifest` | Nom, icônes, couleurs, mode plein écran |
| `sw.js` | Service worker, mise en cache et fonctionnement hors ligne |
| `icons/` | Icônes d'accueil |
| `.nojekyll` | Désactive le traitement Jekyll de GitHub Pages |
| `Solitaire.xcodeproj` | Projet Xcode, pour lancer le jeu comme une app iOS |
| `AppShell/` | Coquille SwiftUI : une WKWebView plein écran, aucun code de jeu |

## Voir le jeu dans Xcode

```bash
open Solitaire.xcodeproj
```

Choisir un simulateur iPhone dans la barre du haut, puis ⌘R.

`AppShell/` ne contient que la coquille native : `index.html`, `manifest.webmanifest`,
`sw.js` et `icons/` sont embarqués tels quels dans l'app, sans copie séparée — modifier
`index.html` et relancer suffit à voir le changement.

Les fichiers sont servis sous le schéma `solitaire://game/` plutôt qu'en `file://` :
cela donne une vraie origine, donc un `localStorage` qui persiste d'un lancement à
l'autre. Le service worker, lui, ne s'enregistre pas dans ce contexte, ce qui est sans
effet ici puisque tout est déjà local.

Pour inspecter le jeu : Safari → Développement → Simulateur → `index.html`.

Pour installer sur un iPhone réel, il faut renseigner une équipe de signature dans
l'onglet *Signing & Capabilities* de la cible et changer `PRODUCT_BUNDLE_IDENTIFIER`
(`com.example.solitaire` par défaut).

## Publier

Dépôt public sur GitHub, puis Settings → Pages → Deploy from a branch → `main` → `/ (root)`.
L'adresse est `https://VOTRE-PSEUDO.github.io/NOM-DU-DEPOT/`.

## Mettre à jour

1. Remplacer `index.html`
2. Incrémenter `APP_VERSION` en bas de `index.html`
3. Incrémenter `CACHE_VERSION` en haut de `sw.js`
4. Attendre le redéploiement, puis rouvrir l'app deux fois sur le téléphone

Voir `TUTORIAL.md` pour la marche à suivre détaillée.
