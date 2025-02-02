// SPDX-License-Identifier: MIT
pragma solidity 0.8.18;

import "./ITestPillarDAO.sol";
import "./TestMembershipNFT.sol";
import "./SafeERC20.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract TestPillarDAO is ITestPillarDAO, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    address private immutable stakingToken;
    uint256 private immutable stakingTerm = 0.1 minutes;
    uint256 private immutable stakeAmount;
    TestMembershipNFT private membershipNFT;

    struct Deposit {
        uint256 depositAmount;
        uint256 depositTime;
    }

    mapping(address => Deposit) private balances;
    mapping(address => uint256) private memberships;

    constructor(
        address _stakingToken,
        uint256 _stakeAmount,
        address _membershipNft,
        address[] memory _preExistingMembers
    ) {
        require(
            _stakingToken != address(0),
            "TestPillarDAO:: invalid staking contract"
        );
        require(_stakeAmount > 0, "TestPillarDAO:: invalid staking amount");
        stakingToken = _stakingToken;
        stakeAmount = _stakeAmount;
        membershipNFT = TestMembershipNFT(_membershipNft);
        for(uint256 i; i < _preExistingMembers.length; i++) {
            require(_preExistingMembers[i] != address(0), "TestPillarDAO: invalid pre-existing member");
        }
        _addExistingMembers(_preExistingMembers);
    }

    function deposit(uint256 _amount) external override nonReentrant {
        require(_amount == stakeAmount, "TestPillarDAO:: invalid staked amount");
        require(
            memberships[msg.sender] == 0,
            "TestPillarDAO:: user is already a member"
        );

        IERC20 token = IERC20(stakingToken);
        require(
            token.allowance(msg.sender, address(this)) >= _amount,
            "TestPillarDAO:: not enough allowance"
        );

        token.safeTransferFrom(msg.sender, address(this), _amount);
        memberships[msg.sender] = membershipNFT.mint(msg.sender);

        emit DepositEvent(msg.sender, memberships[msg.sender]);
        balances[msg.sender] = Deposit({
            depositAmount: _amount,
            depositTime: block.timestamp
        });
    }

    function withdraw() external override nonReentrant {
        require(
            balances[msg.sender].depositAmount > 0,
            "TestPillarDAO:: insufficient balance to withdraw"
        );
        require(
            (block.timestamp - balances[msg.sender].depositTime) > stakingTerm,
            "TestPillarDAO:: too early to withdraw"
        );
        require(
            memberships[msg.sender] > 0,
            "TestPillarDAO:: membership does not exists!"
        );

        IERC20 token = IERC20(stakingToken);
        token.safeTransfer(msg.sender, stakeAmount);
        membershipNFT.burn(memberships[msg.sender]);
        emit WithdrawEvent(msg.sender, memberships[msg.sender]);

        memberships[msg.sender] = 0;
        balances[msg.sender] = Deposit({depositAmount: 0, depositTime: 0});
    }

    function balanceOf(address _to) external view returns (uint256) {
        return balances[_to].depositAmount;
    }

    function membershipId(address _to) external view returns (uint256) {
        return memberships[_to];
    }

    function canUnstake(address _to) external view returns (bool) {
        if ((block.timestamp - balances[_to].depositTime) >= stakingTerm) {
            return true;
        }
        return false;
    }

    function stakingAmount() external view returns (uint256) {
        return stakeAmount;
    }

    function stakingTime() external view returns (uint256) {
        return stakingTerm;
    }

    function membershipNFTAddress() external view returns (address) {
        return address(membershipNFT);
    }

    function stakingTokenAddress() external view returns (address) {
        return address(stakingToken);
    }

    function setMembershipURI(string memory _baseURI) external onlyOwner {
        membershipNFT.setBaseURI(_baseURI);
    }

    function withdrawTokenToOwner(address _token) external onlyOwner {
        require(_token != address(0), "TestPillarDAO:: invalid token address");
        require(
            _token != stakingToken,
            "TestPillarDAO:: cannot withdraw staking token"
        );

        IERC20 token = IERC20(_token);
        uint256 balance = token.balanceOf(address(this));

        if (balance > 0) {
            token.safeTransfer(msg.sender, balance);
        }
    }

    function setMembershipNFT(address _newAddr) external onlyOwner {
        membershipNFT = TestMembershipNFT(_newAddr);
    }

    function setDepositTimestamp(address _member, uint256 _timestamp) external onlyOwner {
        require(_member != address(0), "TestPillarDAO: invalid member");
        require(_timestamp != 0, "TestPillarDAO: invalid timestamp");
        balances[_member].depositTime = _timestamp;
        emit DepositTimestampSet(_member, _timestamp);
    }

    function viewDepositTimestamp(address _member) public view returns(uint256) {
        return balances[_member].depositTime;
    }

    function _addExistingMembers(address[] memory _members) internal {
        for(uint256 i; i < _members.length; i++) {
            memberships[_members[i]] = i + 1;
        balances[_members[i]] = Deposit({
            depositAmount: 10000 ether,
            depositTime: block.timestamp
        });
        }
    }
}