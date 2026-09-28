---
name: run-game
description: Use when you need to see the Whack-a-Mole game actually running - opening it in a browser window, taking screenshots, checking a UI change, or forcing the "Beat the king" record states without a wallet. Triggers on "lance le jeu", "ouvre le jeu", "run the game", "screenshot the game", "teste l'interface".
---

# Lancer TaupeGame dans une fenêtre

Le jeu est du HTML/CSS/JS statique : **pas de build, pas de `node_modules`**.
Ne lance pas `npm install` — `serve.js` et `cdp.js` n'ont aucune dépendance
(Node ≥ 22 suffit, son client WebSocket est intégré).

`server.js` à la racine est un *autre* backend (Express + SQLite, version locale
sans blockchain). Il ne sert pas `play/`. Ignore-le pour piloter le jeu.

## 1. Servir le repo

```bash
node .claude/skills/run-game/serve.js . 8731 &
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1:8731/play/index.html   # 200
```

Sers la **racine du repo**, pas `play/` : `play/all.min.css` pointe ses polices
vers `../webfonts/`, qui est au niveau du repo. Sinon `fa-crown` sort en carré vide.

N'ouvre pas `play/index.html` en `file://` : la lecture du record passe par un
RPC HTTP et se fait bloquer.

## 2. Ouvrir la fenêtre

```bash
"/c/Program Files/Google/Chrome/Application/chrome.exe" \
  --new-window --remote-debugging-port=9333 \
  --user-data-dir="$TMPDIR/taupe-chrome" --no-first-run \
  --window-size=430,900 \
  "http://127.0.0.1:8731/play/index.html" &
```

`--user-data-dir` est obligatoire, sinon Chrome réutilise une instance déjà
ouverte et ignore le port de debug. Ajoute `--headless=new` pour les captures
automatiques sans fenêtre.

## 3. Piloter

```bash
S=.claude/skills/run-game/cdp.js
node $S size 390 844
node $S goto http://127.0.0.1:8731/play/index.html
node $S eval "document.title"
node $S shot /tmp/jeu.png
```

**Regarde la capture.** Une image noire ou vide = échec de lancement, pas un succès.

## Afficher une page directement

Les pages sont des `.page-cont` basculées en `display`. Pour sauter le menu :

```js
document.querySelectorAll('.page-cont').forEach(p => p.style.display = 'none');
document.querySelectorAll('.popupInfo').forEach(p => p.style.display = 'none');
pagePlayArea.style.display = 'block';   // ou pageYouLost, pageHighScore...
```

Après `goto`, attends ~2,5 s : il y a un splash animé et une tentative RPC.

## Forcer les états "Beat the king" sans wallet

`kingLeader`, `kingBestScore`, `kingStateLoaded` et `playerAddress` sont des
`let` au niveau du script. Assigne-les **sans `window.`** — un `let` de premier
niveau ne devient pas une propriété de `window`, mais reste accessible depuis la
console.

```js
playerAddress  = '0xAAaa...';   // le joueur
kingStateLoaded = true;         // false => barre masquée (RPC KO)
kingLeader      = '0xBBbb...';  // null  => barre masquée (aucun record)
kingBestScore   = 680;
gameEngine.score = 240; gmStatsScore.innerHTML = 240;
renderKingBar();                // barre en jeu
renderNewKing(hasBeatenKing(gameEngine.score));   // écran "New king!"
```

Mets `kingLeader === playerAddress` pour l'état roi (couronne + doré). Il faut
**dépasser** le record, pas l'égaler : `hasBeatenKing(680)` est `false` quand
`kingBestScore === 680`, comme le `>` du contrat.

## Pièges CSS

`play/index.html` charge `all.min.css` **après** `style.css`. Les règles
FontAwesome (`.fas { display: inline-block }`) gagnent donc à spécificité égale
sur celles de `style.css`. Qualifie tes sélecteurs d'icône par un parent
(`.king-bar-cont .king-bar-crown`) au lieu d'écrire `.king-bar-crown` seul.

`.game-stats-cont` (10 %) et `.game-space` (90 %) remplissent déjà la hauteur :
tout ce qu'on insère entre les deux doit être repris quelque part. Le cercle le
plus bas de `circlesPosition` est à `y:527px` + 44 px, soit **571 px requis**
dans `.game-space`, sinon il est rogné.
