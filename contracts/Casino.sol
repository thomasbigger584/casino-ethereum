pragma solidity 0.5.8; // compiler version

/*
https://solidity.readthedocs.io/en/v0.4.20/units-and-global-variables.html

msg: values defined by the user when they execute the contract

msg.data (bytes): complete calldata
msg.gas (uint): remaining gas
msg.sender (address): sender of the message (current call)
msg.sig (bytes4): first four bytes of the calldata (i.e. function identifier)
msg.value (uint): number of wei sent with the message
*/

//This contract represents a single game
contract Casino {

    //The address variable called owner is that long string from your Metamask account
    //Something like 0x08f96d0f5C9086d7f6b59F9310532BdDCcF536e2
    address payable public owner;

    uint256 public minimumBet;
    uint256 public totalBet;
    uint256 public numberOfBets;
    uint256 public maxAmountOfBets = 100;
    address[] public players;

    struct Player {
        uint256 amountBet;
        uint256 numberSelected;
    }

    //Mapping between the players address and their user info (Player)
    //Using their address as the key to do something like this: playerInfo[address].amountBet
    mapping(address => Player) public playerInfo;


    //*********************************************************************
    //*********************************************************************

    //Fallback function in case someone sends ether to the contract so it
    //doesn't get lost and to increase the treasury of this contract that will be distributed in each game
    //This will allow you to save the ether you send to the contract. Otherwise it would be rejected
    function() external payable {}




    //Constructor
    //Defining the minimum bet for the game
    constructor(uint256 _minimumBet) public {
        //The user address that created this contract is the owner
        owner = msg.sender;
        if (_minimumBet != 0) minimumBet = _minimumBet;
    }


    //*********************************************************************
    //* PERFORMING A BET
    //*********************************************************************


    //To bet for a number between 1 and 10 both inclusive
    //Payable modifier means it can receive ether when executed
    //The msg.value is the amount of ether he paid when executing this payable function.
    function bet(uint256 numberSelected) public payable {

        //some sanity checks
        //If the function exits here then ether paid is reverted to the sender.
        require(!checkPlayerExists(msg.sender));
        require(numberSelected >= 1 && numberSelected <= 10);
        require(msg.value >= minimumBet);

        //adding the player to the mapping
        //their address is the key, the amount they are betting and the number selected
        playerInfo[msg.sender].amountBet = msg.value;
        playerInfo[msg.sender].numberSelected = numberSelected;

        //increment the number of bets so we can count and check up to 100
        numberOfBets++;

        //maintain a list of players also
        players.push(msg.sender);

        //maintain the pot of money for this game
        totalBet += msg.value;
    }

    //Constant modifier indicates that this function  doesn’t cost any gas to run
    //It’s returning an already existing value from the blockchain
    //Loops through the maintained players list and checks if the player is in it
    //It is free to the sender because we are checking a variable already in the chain
    function checkPlayerExists(address player) public view returns (bool){
        for (uint256 i = 0; i < players.length; i++) {
            if (players[i] == player) return true;
        }
        return false;
    }


    //*********************************************************************
    //* DETERMINING THE WINNERS
    //*********************************************************************


    //Generates a number between 1 and 10 that will be the winner
    function generateNumberWinner() public {
        uint256 numberGenerated = block.number % 10 + 1;
        // This isn't secure
        distributePrizes(numberGenerated);
    }

    //Sends the corresponding ether to each winner depending on the total bets
    function distributePrizes(uint256 numberWinner) public {
        //Memory keyword array get’s deleted after the function executes
        address[100] memory winners;

        //This is the count for the array of winners
        uint256 count = 0;

        //for each of the players figure out if they have won
        for (uint256 i = 0; i < players.length; i++) {
            address playerAddress = players[i];

            //if they have then add them to the winners array
            if (playerInfo[playerAddress].numberSelected == numberWinner) {
                winners[count] = playerAddress;
                count++;
            }

            //remove player from the playerinfo
            delete playerInfo[playerAddress];
        }

        resetData();

        //calculating how much ether to send to winners
        uint256 winnerEtherAmount = totalBet / winners.length;

        //calling transfer on address of the winners to send them that amount of money
        for (uint256 j = 0; j < count; j++) {

            //sanity check
            //check when iterating through array that it is an actual address and not an empty address
            if (winners[j] != address(0)) {
                address(uint160(winners[j])).transfer(winnerEtherAmount);
            }
        }
    }

    function resetData() public {
        players.length = 0;
        totalBet = 0;
        numberOfBets = 0;
    }


    //*********************************************************************
    //*********************************************************************

    //destroy the contract whenever you want
    function kill() public {
        //only the owner can kill it
        if (msg.sender == owner) selfdestruct(owner);
    }
}