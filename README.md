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

## Donnes gagnables

Toutes les donnes sont gagnables : le défi du jour, les parties ordinaires et
les donnes d'événement. Un solveur tourne dans un worker et ne sert une graine
qu'après avoir mené ses cinquante-deux cartes aux fondations.

La vérification se fait d'avance, pendant que l'accueil est affiché, et quelques
graines prouvées attendent en réserve — toucher « Nouvelle partie » ne déclenche
donc aucune attente. Si la réserve est vide, l'accueil l'annonce et la partie
part d'elle-même dès qu'une donne est prête.

Les graines prouvées sont gardées d'une ouverture à l'autre, avec le numéro de
version de la distribution : une ouverture à froid part donc avec une donne
prête, sans faire tourner le solveur. `DEAL_VERSION`, en tête de `dealFrom`,
doit être incrémenté dès que la distribution ou le modèle du solveur changent,
sinon une graine vérifiée par la version précédente servirait une donne qui
n'est plus la même.

Les donnes sont vérifiées à trois cartes, le tirage le plus exigeant : une ligne
gagnante à trois se rejoue telle quelle à une carte, en piochant trois fois de
suite au lieu d'une. Une donne prouvée à trois est donc gagnable dans les deux
réglages, la réciproque étant fausse.

Le solveur est volontairement conservateur : il refuse des donnes pourtant
solubles, on passe alors simplement à la graine suivante. Les donnes servies
sont de ce fait plutôt les plus accessibles. Et sans worker — navigateur trop
ancien, solveur en échec — le jeu distribue une donne quelconque plutôt que de
refuser de jouer, et l'accueil ne promet alors plus rien.

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

Le retour tactile passe par la coquille : `AppShell/HapticBridge.swift` répond à
`window.SolitaireHaptics(kind)`, que le jeu appelle quand le réglage
« Vibrations » est actif. Sans lui le jeu se rabat sur `navigator.vibrate`, qui
n'existe pas dans WebKit sur iOS — le réglage ne faisait alors rien. Cela ne se
vérifie que sur un vrai iPhone : un simulateur n'a pas de moteur Taptic.

Pour inspecter le jeu : Safari → Développement → Simulateur → `index.html`.
L'inspecteur n'est ouvert qu'en configuration Debug.

Avant toute publication sur l'App Store : renseigner une équipe de signature dans
l'onglet *Signing & Capabilities* de la cible et remplacer
`PRODUCT_BUNDLE_IDENTIFIER` — `com.example.solitaire` est un identifiant
d'exemple, il n'est pas publiable tel quel.

`ITSAppUsesNonExemptEncryption` est déclaré à `NO` : l'app n'embarque aucun
chiffrement, et App Store Connect ne repose donc plus la question de conformité
à l'export à chaque envoi.

## Publier

Dépôt public sur GitHub, puis Settings → Pages → Deploy from a branch → `main` → `/ (root)`.
L'adresse est `https://VOTRE-PSEUDO.github.io/NOM-DU-DEPOT/`.

## Mettre à jour

1. Remplacer `index.html`
2. Incrémenter `APP_VERSION` en bas de `index.html`
3. Incrémenter `CACHE_VERSION` en haut de `sw.js`
4. Attendre le redéploiement, puis rouvrir l'app deux fois sur le téléphone

Voir `TUTORIAL.md` pour la marche à suivre détaillée.
