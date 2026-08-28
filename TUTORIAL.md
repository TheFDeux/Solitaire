# Mettre Solitaire en ligne et l'installer sur iPhone

Durée : environ 15 minutes la première fois, 2 minutes pour chaque mise à jour ensuite.
Aucun Mac, aucun Xcode, aucun compte développeur Apple. Tout se fait depuis un navigateur.

---

## Ce que tu as dans le dossier

```
solitaire/
├── index.html              le jeu complet
├── manifest.webmanifest    nom, icônes, couleurs, plein écran
├── sw.js                   service worker, cache et hors ligne
├── .nojekyll               évite que GitHub bricole les fichiers
├── README.md
├── TUTORIAL.md             ce fichier
└── icons/
    ├── apple-touch-icon.png    180×180, l'icône iPhone
    ├── icon-192.png
    ├── icon-512.png
    ├── icon-512-maskable.png
    └── favicon-32.png
```

Deux points importants avant de commencer :

Le fichier doit s'appeler **`index.html`**, pas `solitaire.html`. C'est ce nom que GitHub Pages sert automatiquement à la racine.

Le dossier **`icons/`** doit rester un dossier. Si les images se retrouvent à la racine, l'icône d'accueil sera un rectangle blanc.

---

## Étape 1 — Créer le dépôt GitHub

1. Va sur [github.com](https://github.com) et connecte-toi. Si tu n'as pas de compte, la création est gratuite et prend deux minutes.
2. En haut à droite, clique sur **+** puis **New repository**.
3. Remplis :
   - **Repository name** : `solitaire` (ce nom apparaîtra dans l'URL, choisis-le bien)
   - **Public** — obligatoire, GitHub Pages ne fonctionne pas sur un dépôt privé avec un compte gratuit
   - Ne coche **rien** d'autre, surtout pas « Add a README file »
4. **Create repository**.

Tu arrives sur une page vide avec des instructions en ligne de commande. Ignore-les.

---

## Étape 2 — Envoyer les fichiers

### Méthode A — Depuis le navigateur, sans installer quoi que ce soit

1. Sur la page du dépôt, clique sur le lien **uploading an existing file**.
2. Ouvre le dossier `solitaire` sur ton ordinateur, sélectionne **tout son contenu** (les fichiers *et* le dossier `icons`), et fais-le glisser dans la zone de dépôt.

   Attention : sélectionne le contenu du dossier, pas le dossier lui-même. Sinon tout se retrouve dans un sous-dossier et rien ne s'affichera.

3. En bas, dans **Commit changes**, écris `Première version` et clique sur **Commit changes**.

### Détails propres à Windows

**Décompresser le zip.** Clic droit sur `solitaire-github.zip` → **Extraire tout**. Windows crée souvent un dossier dans un dossier : `solitaire-github\solitaire-github\`. Descends jusqu'à voir directement `index.html` et le dossier `icons`, c'est ce niveau-là qui compte.

**Tout sélectionner.** Entre dans ce dossier, `Ctrl + A`, puis fais glisser la sélection dans la zone de dépôt de GitHub. Tu dois voir `index.html`, `manifest.webmanifest`, `sw.js`, `.nojekyll`, `README.md`, `TUTORIAL.md` et le dossier `icons`.

**Les extensions cachées.** L'Explorateur Windows masque les extensions connues par défaut, donc `index.html` s'affiche simplement comme `index`. Ce n'est pas un problème pour l'envoi. En revanche, ne renomme jamais un fichier depuis l'Explorateur, tu risques de fabriquer un `index.html.txt` invisible. Pour vérifier, onglet **Affichage** → coche **Extensions de noms de fichiers**.

**N'ouvre pas les fichiers avec le Bloc-notes.** Il peut casser les accents et les retours à la ligne. Si tu dois éditer quelque chose, fais-le directement sur github.com avec l'éditeur intégré, ou installe [VS Code](https://code.visualstudio.com) qui est gratuit.

Le fichier `.nojekyll` est visible sous Windows, contrairement à macOS. S'il venait à manquer, ce n'est pas grave ici : il ne sert que de précaution.

### Méthode B — En ligne de commande

Si tu as `git` installé (sous Windows : [git-scm.com](https://git-scm.com), ou [GitHub Desktop](https://desktop.github.com) qui évite la ligne de commande) :

```bash
cd chemin/vers/solitaire
git init
git add .
git commit -m "Première version"
git branch -M main
git remote add origin https://github.com/TON-PSEUDO/solitaire.git
git push -u origin main
```

---

## Étape 3 — Activer GitHub Pages

1. Dans le dépôt, onglet **Settings** (en haut à droite).
2. Menu de gauche, **Pages**.
3. Sous **Build and deployment** :
   - **Source** : `Deploy from a branch`
   - **Branch** : `main`, et juste à côté `/ (root)`
4. **Save**.

Une bannière apparaît. Attends une à trois minutes, puis recharge la page : elle affichera l'adresse de ton site.

Ton URL sera :

```
https://TON-PSEUDO.github.io/solitaire/
```

La barre oblique finale compte. Sans elle, les chemins relatifs vers `icons/` et `sw.js` peuvent casser.

Le HTTPS est fourni automatiquement par GitHub, ce qui est indispensable : un service worker refuse de démarrer en HTTP.

---

## Étape 4 — Vérifier depuis le PC

Avant de passer au téléphone, ouvre l'URL dans Chrome ou Edge sur ton PC. Le jeu doit s'afficher normalement.

Si tu veux contrôler que la partie installable fonctionne : `F12` pour ouvrir les outils de développement, onglet **Application**. Dans le menu de gauche, **Manifest** doit afficher le nom et les icônes, et **Service Workers** doit montrer un worker avec le statut `activated`. Si ces deux points sont bons, l'installation iPhone se passera bien.

---

## Étape 5 — Faire passer l'URL du PC à l'iPhone

L'adresse est longue à taper au doigt. Trois options, de la plus simple à la plus manuelle :

- Envoie-toi l'URL par mail ou par message, et ouvre le lien depuis l'iPhone.
- Si tu utilises Chrome ou Edge connecté au même compte sur les deux appareils, l'onglet apparaît dans les onglets synchronisés du navigateur mobile. Attention : il faudra ensuite rouvrir l'adresse dans **Safari** pour l'installation.
- Tape-la à la main, elle est courte : `TON-PSEUDO.github.io/solitaire/`

Donne-moi ton URL une fois en ligne, je peux te générer un QR code à scanner avec l'appareil photo de l'iPhone.

---

## Étape 6 — Installer sur iPhone

1. Ouvre l'URL **dans Safari**. Pas Chrome, pas Firefox, pas le navigateur intégré d'une app. Sur iOS, seul Safari sait ajouter à l'écran d'accueil.
2. Touche le bouton **Partager**, le carré avec la flèche vers le haut, en bas de l'écran.
3. Fais défiler et choisis **Sur l'écran d'accueil**.
4. Le nom proposé est « Solitaire ». Touche **Ajouter**.

Tu as maintenant une icône sur ton écran d'accueil. En la lançant, l'app s'ouvre en plein écran, sans barre d'adresse ni onglets. Elle fonctionne hors ligne, en avion, sans réseau.

**Le test qui confirme que tout est bon** : lance l'app, joue trois coups, ferme-la complètement en balayant vers le haut, rouvre-la. Tu dois retomber sur ta partie en cours avec le message « Partie reprise ».

---

## Étape 7 — Publier une mise à jour

C'est ici que le service worker demande un peu d'attention. Il met le jeu en cache pour le hors ligne, donc si tu ne changes que `index.html`, certains téléphones garderont l'ancienne version en mémoire.

La procédure fiable, à chaque fois :

1. **Remplace `index.html`** par la nouvelle version.

   Sur GitHub : ouvre le dépôt, clique sur `index.html`, puis sur l'icône crayon, colle le nouveau contenu, **Commit changes**. Ou bien retourne dans **Add file → Upload files** et dépose le nouveau fichier, il écrasera l'ancien.

2. **Incrémente le numéro de version** tout en bas de `index.html` :

   ```js
   window.APP_VERSION = '1.0.1';
   ```

3. **Incrémente le cache** tout en haut de `sw.js` :

   ```js
   const CACHE_VERSION = 'v1.0.1';
   ```

   Cette ligne est celle qui compte réellement. Elle force le service worker à jeter l'ancien cache et à tout retélécharger.

4. Attends une à deux minutes que GitHub redéploie. L'onglet **Actions** du dépôt affiche une coche verte quand c'est fini.

5. Sur l'iPhone, **ferme complètement l'app** en balayant vers le haut, puis rouvre-la. Le nouveau service worker s'installe. Referme et rouvre une seconde fois pour être certain.

Pour vérifier quelle version tourne réellement sur ton téléphone : ouvre les réglages dans l'app, le numéro de version est affiché tout en bas.

---

## Étape 8 — Travailler avec moi sur les évolutions

Le circuit le plus rapide :

1. Tu me dis ce que tu veux changer.
2. Je te renvoie un `index.html` complet, déjà testé.
3. Tu le déposes sur GitHub, tu montes les deux numéros de version, tu attends deux minutes.

Si tu préfères que je voie l'état réel du code avant de modifier, envoie-moi le fichier tel qu'il est en ligne, ou colle-moi l'URL brute :

```
https://raw.githubusercontent.com/TON-PSEUDO/solitaire/main/index.html
```

Chaque commit est conservé par GitHub. Si une mise à jour casse quelque chose, l'onglet **Commits** te permet de revenir à la version précédente en quelques clics.

---

## Problèmes courants

**Page blanche, ou erreur 404**
Vérifie que le fichier s'appelle exactement `index.html`, en minuscules, et qu'il est à la racine du dépôt et non dans un sous-dossier. GitHub Pages distingue les majuscules des minuscules, y compris pour `icons/`.

**Le site ne s'affiche pas juste après l'activation de Pages**
Le premier déploiement prend parfois cinq minutes. L'onglet **Actions** montre l'avancement.

**L'icône est un rectangle blanc ou une capture de la page**
Le dossier `icons/` n'a pas été envoyé, ou pas au bon endroit. Vérifie sur GitHub que `icons/apple-touch-icon.png` existe bien. Ensuite, iOS garde l'ancienne icône en mémoire : supprime l'app de l'écran d'accueil et réinstalle-la.

**L'app garde l'ancienne version malgré la mise à jour**
Tu as oublié de changer `CACHE_VERSION` dans `sw.js`. Corrige, puis supprime l'app de l'écran d'accueil et réinstalle-la depuis Safari.

**Les statistiques ont disparu**
iOS peut purger les données d'un site web que tu n'as pas visité depuis longtemps. Une app installée sur l'écran d'accueil est nettement mieux protégée qu'un simple onglet Safari, mais ce n'est pas une garantie absolue. C'est une des raisons de passer à un vrai wrapper natif si le projet se confirme.

**Rien ne se passe hors ligne**
Le service worker a besoin d'une première visite en ligne pour se mettre en place. Ouvre l'app une fois avec du réseau, ferme-la, rouvre-la, puis teste en mode avion.

**Les polices ont l'air différentes**
Normal et sans conséquence. Sur iPhone, le jeu utilise San Francisco, la police système, qui est le rendu voulu. Les polices Google servent uniquement de repli sur les autres plateformes.

---

## Et après

Ce que tu as là est une vraie web app installable, suffisante pour tester l'idée, la faire essayer, et mesurer si les gens y reviennent.

Le jour où tu voudras la vendre sur l'App Store, le code du jeu ne bougera pas. Il sera embarqué tel quel par Capacitor, et tu ajouteras autour les briques natives : haptique via le point d'accroche `window.SolitaireHaptics` déjà prévu dans le code, Game Center, iCloud, widget. Il te faudra à ce moment-là un Mac avec Xcode et le compte développeur à 99 € par an.
