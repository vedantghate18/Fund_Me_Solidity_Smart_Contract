//Get Funds from Users
//Withdraw Funds
//Set a minimum funding value in USD

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from  "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

contract FundMe{
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 2e18;

    address[] public funders;
    mapping (address funder => uint256) public addressToAmountFunded;

    address public immutable i_owner;

    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable  {
        //Allow Users to send money
        //Have a minimum money sent
       require(msg.value.getConversionRate() >= MINIMUM_USD, "didnt send enough ETH");
        funders.push(msg.sender);
       addressToAmountFunded[msg.sender] += msg.value;
    }

    function withdraw() public onlyOwner{
       
        for (uint256 funderIndex = 0; funderIndex<funders.length; funderIndex ++) 
        {
           address funder =funders[funderIndex];
           addressToAmountFunded[funder] = 0;
        }
        // reset the array 
        funders = new address [](0);
        // withdraw the fund
        //call method
        (bool callSuccess,)=payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess , "call Failed");
    }

   modifier onlyOwner (){
    require(msg.sender == i_owner , "You are not the Owner");
    _;
   }

   // what happens if someone sends this contract ETH without calling the fund function
   receive() external payable {
    fund();
    }
    fallback() external payable {
        fund();
     }
}