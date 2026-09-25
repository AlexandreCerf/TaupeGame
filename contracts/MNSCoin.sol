// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

/// @title MNS Coin - TP Final Whack-a-Mole (MNS, Blockchain & Development)
/// @notice Jeton ERC-20 plafonne a 444 444 unites, mintable par tout le monde :
///         chaque joueur mint son score depuis le jeu avec son wallet.
contract MNSCoin is ERC20Capped {
    /// @notice Plafond absolu de la circulation : 444 444 MNS.
    uint256 public constant MAX_SUPPLY = 444_444 * 10 ** 18;

    /// @notice Part emise au deploiement vers le deployeur.
    uint256 public constant INITIAL_SUPPLY = 44_444 * 10 ** 18;

    /// @notice Recompenses a chaque fin de partie : 10 MNS a l'auteur, 5 MNS au leader.
    uint256 public constant AUTHOR_REWARD = 10 * 10 ** 18;
    uint256 public constant LEADER_REWARD = 5 * 10 ** 18;

    /// @notice Auteur du contrat : le compte qui l'a deploye.
    address public immutable author;

    /// @notice Joueur ayant recu le plus gros mint (meilleur score), et ce montant.
    address public leader;
    uint256 public bestScore;

    /// @notice Position d'un cercle dans la zone de jeu, en pixels.
    struct CirclePosition {
        uint256 x;
        uint256 y;
    }

    /// @notice Niveaux personnalises : positions des cercles par identifiant de niveau.
    mapping(string => CirclePosition[]) private levels;

    constructor() ERC20("MNS Coin", "MNS") ERC20Capped(MAX_SUPPLY) {
        author = msg.sender;
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /// @notice Emet de nouveaux jetons, dans la limite du plafond. Le jeu l'appelle
    ///         a chaque fin de partie : le score est minte au joueur, 10 MNS a
    ///         l'auteur du contrat et 5 MNS au leader du meilleur score.
    /// @dev Fonction mint d'OpenZeppelin (Wizard, option "Mintable") sans le
    ///      modificateur onlyOwner : n'importe quelle adresse peut l'appeler.
    ///      Le depassement de MAX_SUPPLY est bloque par ERC20Capped._update().
    function mint(address to, uint256 amount) public {
        if (amount > bestScore) {
            bestScore = amount;
            leader = to;
        }

        _mint(to, amount);
        _mint(author, AUTHOR_REWARD);
        // Pas de leader tant qu'aucune partie n'a marque de point
        if (leader != address(0)) {
            _mint(leader, LEADER_REWARD);
        }
    }

    /// @notice Cree un niveau personnalise (ex. depuis Remix :
    ///         newLevel([[100,200],[300,150]], "niveau1")).
    function newLevel(CirclePosition[] calldata positions, string calldata levelId) public {
        require(positions.length > 0, "Empty level");
        require(levels[levelId].length == 0, "Level already exists");
        for (uint256 i = 0; i < positions.length; i++) {
            levels[levelId].push(positions[i]);
        }
    }

    /// @notice Positions d'un niveau (tableau vide si le niveau n'existe pas).
    function getLevel(string calldata levelId) public view returns (CirclePosition[] memory) {
        return levels[levelId];
    }
}
