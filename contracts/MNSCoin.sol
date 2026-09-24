// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";

/// @title MNS Coin - TP Final Whack-a-Mole (MNS, Blockchain & Development)
/// @notice Jeton ERC-20 plafonne a 444 444 unites, mintable par tout le monde :
///         chaque joueur mint son score depuis le jeu avec son compte MetaMask.
contract MNSCoin is ERC20Capped {
    /// @notice Plafond absolu de la circulation : 444 444 MNS.
    uint256 public constant MAX_SUPPLY = 444_444 * 10 ** 18;

    /// @notice Part emise au deploiement vers le deployeur.
    uint256 public constant INITIAL_SUPPLY = 44_444 * 10 ** 18;

    constructor() ERC20("MNS Coin", "MNS") ERC20Capped(MAX_SUPPLY) {
        _mint(msg.sender, INITIAL_SUPPLY);
    }

    /// @notice Emet de nouveaux jetons, dans la limite du plafond.
    /// @dev Fonction mint d'OpenZeppelin (Wizard, option "Mintable") sans le
    ///      modificateur onlyOwner : n'importe quelle adresse peut l'appeler.
    ///      Le depassement de MAX_SUPPLY est bloque par ERC20Capped._update().
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}
