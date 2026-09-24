# TaupeGame – Whack-a-Mole Web3

Jeu Whack-a-Mole porté sur **Polygon Amoy** (testnet) pour le TP final du module *Blockchain & Development* (MNS).
À chaque fin de partie, le score est minté en jetons ERC-20 **MNS Coin** vers l'adresse MetaMask du joueur, et le classement affiche les transactions du token.

## Prérequis

- **Node.js 22** (ou plus récent) et npm
- **Chrome** avec l'extension **MetaMask**
- Le réseau **Polygon Amoy** ajouté dans MetaMask :

  | Champ | Valeur |
  |---|---|
  | Nom du réseau | Amoy |
  | URL RPC | `https://polygon-amoy-bor-rpc.publicnode.com` |
  | ID de chaîne | `80002` |
  | Symbole | `POL` |
  | Explorateur | `https://amoy.polygonscan.com` |

- Quelques **POL de test** sur le compte MetaMask pour payer les frais : https://faucet.polygon.technology/

## Installation

```bash
git clone https://github.com/AlexandreCerf/TaupeGame.git
cd TaupeGame
npm install
npm start
```

Ouvrir ensuite **http://localhost:3000** dans Chrome (celui où MetaMask est installé).

> Le jeu doit être servi en `http://` : ouvert directement en `file://`, MetaMask n'est pas injecté dans la page et l'API des scores ne répond pas.

## Utilisation

1. Dans le menu, cliquer sur **Connect MetaMask** (ou directement sur **New Game**) et autoriser le site.
   L'adresse du joueur s'affiche sous le titre.
2. Jouer une partie. Sur l'écran **Game Over**, cliquer sur **Submit score**.
3. Confirmer la transaction `mint` dans MetaMask : le score est minté en MNS vers l'adresse du joueur
   (un score de 70 donne 70 MNS). Un score de 0 n'est pas minté.
4. **High Scores** affiche les mints du jeu : date, montant, 6 premiers caractères du hash de transaction.

## Contrat MNS Coin

| | |
|---|---|
| Réseau | Polygon Amoy (80002) |
| Adresse | [`0x9Ac5630FB370888ff78A877be33bcCa5e1433DDB`](https://amoy.polygonscan.com/address/0x9Ac5630FB370888ff78A877be33bcCa5e1433DDB) (vérifié sur Polygonscan) |
| Bloc de déploiement | `48436400` |
| Source | [`contracts/MNSCoin.sol`](contracts/MNSCoin.sol) |

- ERC-20 OpenZeppelin `ERC20Capped` : plafond de 444 444 MNS, 44 444 MNS émis au déploiement.
- `mint(address to, uint256 amount)` est **public** : n'importe quelle adresse peut minter (demandé par le sujet).
  Limite connue : quelqu'un peut atteindre le plafond en un seul appel, ce qui bloquerait les mints suivants.

### Redéployer le contrat (Remix)

1. Coller `contracts/MNSCoin.sol` dans https://remix.ethereum.org et compiler (Solidity `0.8.20` ou plus récent).
2. *Deploy & run transactions* → Environment **Browser Extension / MetaMask**, réseau Amoy → **Deploy**.
3. Vérifier : clic droit sur le fichier → **Flatten**, puis plugin **Contract Verification** (Etherscan coché, Sourcify décoché).
4. Reporter la nouvelle adresse dans `TOKEN_ADDRESS` et le bloc de déploiement dans `TOKEN_DEPLOY_BLOCK`
   (`play/js/habibiScript.js`).

## ⚠️ Frais sur Amoy

Amoy refuse les transactions dont le **pourboire (priority fee) est inférieur à 25 gwei**, et MetaMask propose parfois 1,5 gwei.
Dans Remix, l'erreur apparaît seulement sous la forme `_context7.t3.error.indexOf is not a function`.

Solution : dans la popup MetaMask → frais de réseau → **Avancés** → *Frais de priorité* `35` gwei, *Frais de base max* `40` gwei.
Le jeu fixe déjà ces frais lui-même pour le mint du score (`AMOY_PRIORITY_FEE_GWEI` / `AMOY_MAX_FEE_GWEI`).

## Structure du projet

```
contracts/MNSCoin.sol     Contrat ERC-20 (mint public)
server.js                 Serveur Express : sert play/ et l'API des scores (SQLite, data/scores.db)
play/index.html           Page du jeu (charge jQuery, Bootstrap et web3.js 4.16)
play/js/habibiScript.js   Logique du jeu + intégration Web3
play/style.css            Styles du jeu
prototypes/               Prototypes historiques du jeu d'origine (non utilisés)
```

Sections Web3 dans `play/js/habibiScript.js` :

| Section | Rôle |
|---|---|
| *MetaMask session* | `TOKEN_ADDRESS`, `AMOY_CHAIN_ID`, connexion (`connectWallet`, `initWallet`), adresse du joueur (`playerAddress`) |
| *Mint du score* | `mintScore(score)` : bascule sur Amoy si besoin, appelle `mint(playerAddress, score × 10¹⁸)` |
| *Classement* | `GetTokenTransactions()` : lit les événements `Transfer` depuis l'adresse zéro via un RPC public, par tranches de 10 000 blocs (limite du RPC) |

API locale (toujours utilisée pour sauvegarder les parties) : `GET /api/health`, `POST /api/scores`, `GET /api/scores`, `GET /api/scores/:id`.

## Avancement du TP

| # | Tâche | Pts | État |
|---|---|---|---|
| 1 | Authentifier la session avec MetaMask | 2 | ✅ |
| 2 | Contrat mintable par tout le monde | 3 | ✅ |
| 3 | Déployer et vérifier sur Amoy, adresse en dur dans le jeu | 3 | ✅ |
| 4 | Minter le score vers l'adresse du joueur en fin de partie | 3 | ✅ |
| 5 | Afficher les transactions du token dans le classement | 3 | ✅ |
| 6 | À chaque fin de partie : +10 MNS à l'auteur du contrat, +5 MNS au leader | 2+2 | ⏳ à faire |
| Bonus | Niveaux personnalisés (`newLevel`, champ niveau, page de démarrage custom) | 4 | ⏳ facultatif |

### Pistes pour la tâche 6

- Modifier le contrat : mémoriser l'auteur (`msg.sender` du constructeur) et le joueur en tête, puis minter les récompenses dans une fonction appelée en fin de partie.
- Redéployer et revérifier le contrat, puis mettre à jour `TOKEN_ADDRESS` et `TOKEN_DEPLOY_BLOCK`.
- Le classement ne montre que les mints postérieurs à `TOKEN_DEPLOY_BLOCK` : les récompenses y apparaîtront aussi.

## Licence

MIT – jeu d'origine © 2018 Mahdi Al-Farra (voir [LICENSE](LICENSE)).
