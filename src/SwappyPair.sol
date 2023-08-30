pragma solidity ^0.8.19;

import "solmate/tokens/ERC20.sol";
import "./interfaces/IERC20.sol";
import "./libraries/Math.sol";

error InsufficientLiquidityProvided();
error InsufficientLiquidityBurned();

contract SwappyPair is ERC20,Math{

    uint256 private reserveX;
    uint256 private reserveY;
    address public tokenX;
    address public tokenY;
    uint256 constant MIN_LIQUIDITY = 1000;

    event Mint(address sender,uint256 tokenX,uint256 tokenY);
    event Burn(address sender,uint256 amount);

    constructor(address _tokenX,address _tokenY) ERC20("SwappyPair","SPR",18){
        tokenX = _tokenX;
        tokenY = _tokenY;
    }

    function getReserves()public view returns (uint256,uint256){
        return (reserveX,reserveY);
    }

    function _updateBalance(uint256 amountX,uint256 amountY)internal{
        reserveX = amountX;
        reserveY = amountY;
    }

    
    function mint()public {
        (uint256 _reserveX,uint256 _reserveY) = getReserves();
        uint256 balanceX = IERC20(tokenX).balanceOf(address(this));
        uint256 balanceY = IERC20(tokenY).balanceOf(address(this));
        uint256 amountX = balanceX - _reserveX; // amount of tokenX deposited
        uint256 amountY = balanceY - _reserveY; // amount of tokenY deposited
        uint256 liquidity;
        uint256 _totalSupply = totalSupply;

        if(_totalSupply==0){
            // When liquidity is initially deposited into the pool    
            liquidity = Math.sqrt(amountX*amountY)-MIN_LIQUIDITY;
        }
        else{
            // Some liquidity is already present
            liquidity = Math.min(_totalSupply*amountX/_reserveX,_totalSupply*amountY/_reserveY);
        }
        if(liquidity<=0){
            revert InsufficientLiquidityProvided();
        }

        // Mint certain of liquidity tokens for the sender
        _mint(msg.sender,liquidity);

        _updateBalance(balanceX,balanceY);
        emit Mint(msg.sender,amountX,amountY);
    }   

    function burn()public{
        uint256 liquidity = balanceOf[msg.sender];
        uint256 balanceX = IERC20(tokenX).balanceOf(address(this));
        uint256 balanceY = IERC20(tokenY).balanceOf(address(this));
        uint256 amountX = liquidity*balanceX/totalSupply;
        uint256 amountY = liquidity*balanceY/totalSupply;

        if(amountX<=0 || amountY<=0){
            revert InsufficientLiquidityBurned();
        }
        _burn(msg.sender,liquidity);
        IERC20(tokenX).transfer(msg.sender,amountX);
        IERC20(tokenY).transfer(msg.sender,amountY);

        _updateBalance(balanceX-amountX,balanceY-amountY);
        emit Burn(msg.sender,liquidity);
    }
}