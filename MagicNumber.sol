// SPDX-License-Identifier: MIT
pragma solidity ^0.6.0;

contract MagicNum {

  address public solver;

  constructor() public {}

  function setSolver(address _solver) public {
    solver = _solver;
  }

  /*
    ____________/\\\_______/\\\\\\\\\_____        
     __________/\\\\\_____/\\\///////\\\___       
      ________/\\\/\\\____\///______\//\\\__      
       ______/\\\/\/\\\______________/\\\/___     
        ____/\\\/__\/\\\___________/\\\//_____    
         __/\\\\\\\\\\\\\\\\_____/\\\//________   
          _\///////////\\\//____/\\\/___________  
           ___________\/\\\_____/\\\\\\\\\\\\\\\_ 
            ___________\///_____\///////////////__
  */
}

/* SOLUTION IS COMPLICATED! 
Read here for detailed explanation
References
- https://coder-question.com/cq-blog/525392
- https://medium.com/coinmonks/ethernaut-lvl-19-magicnumber-walkthrough-how-to-deploy-contracts-using-raw-assembly-opcodes-c50edb0f71a2

Final bytecode - '600a600c600039600a6000f3602a60505260206050f3'

Steps to Complete the Challenge
1. `bytecode = '600a600c600039600a6000f3602a60505260206050f3'`
2. `txn = await web3.eth.sendTransaction({from: player, data: bytecode})`
3. `solverAddr = txn.contractAddress`
4. `await contract.setSolver(solverAddr)`

*/

