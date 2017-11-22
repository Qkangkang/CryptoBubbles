pragma solidity ^0.4.11;

import "./GameToken.sol";

contract GameManager {

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    uint32[] gameBalances;
    uint numPlayers;
    mapping (uint => address) userPosition;

    mapping (address => uint) public balances;
    
    mapping (address => bool) public hasVoted;

    address public owner;
    GameToken public gameToken;

    bytes32 public currStateHash;
    uint public numStateVerified;
    bool public gameInProgress;
    bool public callTheServer;
    bool public playersVoted;

    uint ONE_PLAY = 1000;
    uint FEE = 200;
    uint MIN_PLAYERS = 5;

    function GameManager(address gameTokenAddress) public {
        owner = msg.sender;
        gameToken = GameToken(gameTokenAddress);
        gameInProgress = false;
        playersVoted = false;
        callTheServer = false;
        numStateVerified = 0;

        numPlayers = 0;
    }

    // before call the user has to approve the tokens to be spent
    function joinGame(address user, uint32 numTokens) public {
        require(numTokens > ONE_PLAY + FEE);
        require(gameInProgress == false);

        gameBalances[numPlayers] = numTokens;
        userPosition[numPlayers] = msg.sender;
        numPlayers++;
        
        if (numPlayers >= MIN_PLAYERS) {
            gameInProgress = true;
        }
        
        gameToken.transferFrom(user, this, numTokens);
    }

    //What happends if some of the players don't vote??
    function gameEnds(uint32[] state, uint position) public {
        require(userPosition[position] == msg.sender);
        require(hasVoted[msg.sender] == false);
        
        bytes32 stateHash = keccak256(state);
        
        if (currStateHash == 0x0) {
            currStateHash = stateHash;
            return;
        } 
        
        if (currStateHash == stateHash) {
            
            numStateVerified++;
            hasVoted[msg.sender] = true;

            // The last one
            if (numStateVerified >= numPlayers) {
                playersVoted = true;
                submitState(state);
            }
        } else {
            // Bad stuff somone is cheating, server will punish the cheater and give the money to the poor
            callTheServer = true;
        }
    }


    function submitState(uint32[] state) internal {
        require(playersVoted == true);
        
        for(uint i = 0; i < numPlayers; ++i) {
            balances[userPosition[i]] += state[i];
        }

        newGameSession();
    }

    function withdrawWins() public {
        require(balances[msg.sender] > 0);

        gameToken.transfer(msg.sender, balances[msg.sender]);
    }

    function changeFee(uint newFee) public onlyOwner {
        FEE = newFee;
    }
    
    function changeMinPlayers(uint _MIN_PLAYERS) public onlyOwner {
        MIN_PLAYERS = _MIN_PLAYERS;
    }

    function newGameSession() internal {
        gameInProgress = false;
        playersVoted = false;
        callTheServer = false;
        numStateVerified = 0;

        numPlayers = 0;
    }
    
}