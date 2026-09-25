# TaupeGame – Whack-a-Mole Web3

Jeu Whack-a-Mole sur **Polygon Amoy** (testnet) pour le TP final du module Blockchain & Development (MNS).
À chaque fin de partie, le score est minté en jetons **MNS Coin** vers le wallet du joueur,
avec 10 MNS pour l'auteur du contrat et 5 MNS pour le leader (meilleur score).

## Prérequis

- Node.js 22 et npm
- Un wallet dans le navigateur (MetaMask, Rabby…) sur le réseau **Polygon Amoy** (chain ID `80002`)
- Quelques POL de test : https://faucet.polygon.technology/

## Lancer le jeu

```bash
git clone https://github.com/AlexandreCerf/TaupeGame.git
cd TaupeGame
npm install
npm start
```

Puis ouvrir http://localhost:3000.

## Jouer

1. Cliquer sur **Connect wallet** et autoriser le site.
2. Jouer, puis cliquer sur **Submit score** et confirmer la transaction dans le wallet.
3. **High Scores** affiche le score de chaque partie (date, montant, début du hash de transaction).
4. **Custom Level** lance une partie sur un niveau créé avec `newLevel` dans le contrat
   (ex. dans Remix ou polygonscan : `newLevel([[100,200],[300,150],[450,400]], "niveau1")`), en saisissant son ID.

## Contrat

- Adresse : [`0xBE21be9Bc535f4F53217343aE7e13FBF729e74b9`](https://amoy.polygonscan.com/address/0xBE21be9Bc535f4F53217343aE7e13FBF729e74b9)
- Bloc de déploiement : `48513229`
- Source : [`contracts/MNSCoin.sol`](contracts/MNSCoin.sol)

## Licence

MIT – jeu d'origine © 2018 Mahdi Al-Farra (voir [LICENSE](LICENSE)).
