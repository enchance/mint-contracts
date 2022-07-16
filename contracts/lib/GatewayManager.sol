//SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import 'hardhat/console.sol';
import "@openzeppelin/contracts/utils/Counters.sol";

contract GatewayManager {
    using Counters for Counters.Counter;

    mapping(uint => string) public gateways;
    Counters.Counter internal gatewayCounter;

    error InvalidGateway();


    constructor() {
        gatewayCounter.increment();
    }

    /**
     * Add a new gateway for a new token
     * @param   string  _uri    IPFS uri containing the CID and placeholder id
     * @example                 addGateway('https://gateway.pinata.cloud/<CID HERE>/{id}.json')
     */
    function _addGateway(string memory _uri) internal virtual {
        if(bytes(_uri).length == 0) revert InvalidGateway();
        uint gatewayId = gatewayCounter.current();
        gateways[gatewayId] = _uri;
        gatewayCounter.increment();
    }
}
