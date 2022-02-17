// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '../Access/BlockHeadAccessControl.sol';

contract VirtualBlockHeadToken is ERC20, Pausable {
  BlockHeadAccessControl public accessControl;

  constructor(address _accessControl) ERC20('Virtual BlackHead Token', 'VBLK') {
    accessControl = BlockHeadAccessControl(_accessControl);
    _mint(msg.sender, 1_000_000_000 * (10**decimals()));
  }

  modifier onlyPauser() {
    require(accessControl.hasPauserRole(msg.sender), 'BlockHead: Only pauser can perform this action');
    _;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal override whenNotPaused {
    super._beforeTokenTransfer(from, to, amount);
  }

  function pause() public onlyPauser {
    _pause();
  }

  function unpause() public onlyPauser {
    _unpause();
  }
}
