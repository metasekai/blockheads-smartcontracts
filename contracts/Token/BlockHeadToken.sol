// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';
import '@openzeppelin/contracts/security/Pausable.sol';
import '../Access/BlockHeadAccessControl.sol';

contract BlockHeadToken is ERC20, Pausable {
  uint256 public maxCap;

  BlockHeadAccessControl public accessControl;

  constructor(uint256 _maxCap, address _accessControl) ERC20('BlockHead Token', 'BLK') {
    accessControl = BlockHeadAccessControl(_accessControl);
    maxCap = _maxCap;

    _mint(msg.sender, 100_000_000 * (10**decimals()));
  }

  modifier onlyPauser() {
    require(accessControl.hasPauserRole(msg.sender), 'BlockHead: Only pauser can perform this action');
    _;
  }

  modifier onlyAdmin() {
    require(accessControl.hasAdminRole(msg.sender), 'BlockHead: Only Admin can perform this action');
    _;
  }

  function _beforeTokenTransfer(
    address from,
    address to,
    uint256 amount
  ) internal virtual override whenNotPaused {
    super._beforeTokenTransfer(from, to, amount);
    if (!accessControl.hasAdminRole(to)) {
      require(balanceOf(to) + amount <= maxCap, 'BlockHead: Max Cap');
    }
  }

  function pause() public onlyPauser {
    _pause();
  }

  function unpause() public onlyPauser {
    _unpause();
  }

  function setMaxCap(uint256 _maxCap) public onlyAdmin {
    require(_maxCap > 0, 'BlockHead: Max Cap should be greater than 0');
    maxCap = _maxCap;
  }
}
