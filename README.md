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

## Publier

Dépôt public sur GitHub, puis Settings → Pages → Deploy from a branch → `main` → `/ (root)`.
L'adresse est `https://VOTRE-PSEUDO.github.io/NOM-DU-DEPOT/`.

## Mettre à jour

1. Remplacer `index.html`
2. Incrémenter `APP_VERSION` en bas de `index.html`
3. Incrémenter `CACHE_VERSION` en haut de `sw.js`
4. Attendre le redéploiement, puis rouvrir l'app deux fois sur le téléphone

Voir `TUTORIAL.md` pour la marche à suivre détaillée.
