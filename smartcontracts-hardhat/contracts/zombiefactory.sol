// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <0.9.0;

import "./ownable.sol";
import "./safemath.sol";

contract ZombieFactory is Ownable { //contract ZombieFactory which is inherited from contract Ownable

  using SafeMath for uint256; // using SafeMath library for uint256, stops over/under flow of uint256
  using SafeMath32 for uint32; 
  using SafeMath16 for uint16;

  event NewZombie(uint zombieId, string name, uint dna); //event used to interect with the front end

  uint dnaDigits = 16;                //will be used to calculate dnaModulus
  uint dnaModulus = 10 ** dnaDigits;  //dnaModulus will be used to mod a uint to get a 16 digit
                                      //uint which will act as the dna of the zombie
                                      //since, x%10 gives single digit number
                                      //       x%100 gives double digit number
                                      //       x&10^n gives n digit number

uint cooldownTime = 1 days;           //time between two concesutive attacks by an zombie

  struct Zombie {                     //struct decleration for a zombie
    string name;
    uint dna;
    uint32 level;
    uint32 readyTime;
    uint16 winCount;
    uint16 lossCount;
  }

  Zombie[] public zombies;            //array of zombie named zombies

  mapping (uint => address) public zombieToOwner; //mapping from zombieId to owner address
  mapping (address => uint) ownerZombieCount;     //mapping from owner address to its zombie count

  function _createZombie(string memory _name, uint _dna) internal {  /*fn to create zombie with
  desired name and dna. This function is reserved to be called only internally since we don't
  want users to create a zombie of any name and data, it will be called by other fn which will
  assign a dna and name from its side to the zombie*/

    zombies.push(Zombie(_name, _dna, 1, uint32(block.timestamp + cooldownTime), 0, 0));
    uint id = zombies.length - 1;
    /*this line pushes the zombie in the zombies array and returns the lenght of the array
    we -1 from the length and stors it in the id uint which gives us the id of the zombie*/

    zombieToOwner[id] = msg.sender;  //msg.sender which will be the account or contract calling
    //this function is set to be the owner of the zombie with ID id.
    ownerZombieCount[msg.sender] = ownerZombieCount[msg.sender].add(1);
    emit NewZombie(id, _name, _dna);
  }

  function _generateRandomDna(string memory _str) private view returns (uint){
    //this fn generates a randon dna from a string provided
    uint rand = uint(keccak256(abi.encodePacked(_str))); //uint256 is generated
    return rand % dnaModulus;       // mod with dnaModulus to generate a 16 digit number
  }

  function createRandomZombie(string memory _name) public{
    //this fn uses the _generateRandomDna to generate a dna with name as provided
    require(ownerZombieCount[msg.sender] == 0); //the owner shoud not already have a zombie
    uint randDna = _generateRandomDna(_name);   //randDna is generated
    randDna = randDna - randDna % 100;          //the last two digits are set to 00
    _createZombie(_name, randDna);
  }

}