import "forge-std/Test.sol";
import "forge-std/console.sol";
import "../src/SwappyPair.sol";
import "solmate/tokens/ERC20.sol";
import "../src/implementations/ERC20Mintable.sol";
import "../src/interfaces/IERC20.sol";

contract SwappyPairTest is Test{

    ERC20Mintable tokenX;
    ERC20Mintable tokenY;
    SwappyPair public swappyPair;

    function setUp()public{
        tokenX = new ERC20Mintable("tokenX","TOKX");
        tokenY = new ERC20Mintable("tokenY","TOKY");
        tokenX.mint(address(this),1000000);
        tokenY.mint(address(this),1000000);
        swappyPair = new SwappyPair(address(tokenX),address(tokenY));
        tokenX.transfer(address(swappyPair),100000);
        tokenY.transfer(address(swappyPair),100000);
        swappyPair.mint();
    }

    function testSwappyPair()public{
        address userOne = makeAddr("userOne");
        vm.deal(userOne,10 ether);
        tokenX.mint(userOne,100000) ;
        tokenY.mint(userOne,100000);
        vm.prank(userOne);
        tokenX.transfer(address(swappyPair),10000);
        vm.prank(userOne);
        tokenY.transfer(address(swappyPair),100);
        vm.prank(userOne);
        swappyPair.mint();
        console.log(swappyPair.balanceOf(address(userOne)));
        vm.prank(userOne);
        swappyPair.burn();
        console.log(swappyPair.balanceOf(address(userOne)));
        console.log(tokenX.balanceOf(address(userOne)));
        console.log(tokenY.balanceOf(address(userOne)));

    }
}