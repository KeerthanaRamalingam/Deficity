pragma solidity 0.6.6;

import "@chainlink/contracts/src/v0.6/VRFConsumerBase.sol";

/**
 * THIS IS AN EXAMPLE CONTRACT WHICH USES HARDCODED VALUES FOR CLARITY.
 * PLEASE DO NOT USE THIS CODE IN PRODUCTION.
 */
contract RandomNumberConsumer is VRFConsumerBase {
    
    bytes32 internal keyHash;
    uint256 internal fee;
    
    uint256 public randomResult;
    
    /**
     * Constructor inherits VRFConsumerBase
     * 
     * Network: Kovan
     * Chainlink VRF Coordinator address: 0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9
     * LINK token address:                0xa36085F69e2889c224210F603D836748e7dC0088
     * Key Hash: 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4
     */
    constructor() 
        VRFConsumerBase(
            0xdD3782915140c8f3b190B5D67eAc6dc5760C46E9, // VRF Coordinator
            0xa36085F69e2889c224210F603D836748e7dC0088  // LINK Token
        ) public
    {
        keyHash = 0x6c3699283bda56ad74f6b855546325b68d482e983852a7a82979cc4807b641f4;
        fee = 0.1 * 10 ** 18; // 0.1 LINK (Varies by network)
    }
    
    /** 
     * Requests randomness 
     */
    function getRandomNumber() public returns (bytes32 requestId) {
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK - fill contract with faucet");
        return requestRandomness(keyHash, fee);
    }

    /**
     * Callback function used by VRF Coordinator
     */
    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        randomResult = randomness;
    }

    // function withdrawLink() external {} - Implement a withdraw function to avoid locking your LINK in the contract
}

contract test {
    
    RandomNumberConsumer public RandomNumber;
    
    // constructor(RandomNumberConsumer _RandomNumberConsumer) public {
    //     RandomNumber = _RandomNumberConsumer;
    // }
    uint256[] public prefix;
    
    function myRand(uint256[] memory arr, uint256[] memory freq, uint256 n, uint256 random) public returns(uint256) {
	// Create and fill prefix array
    	
    	uint256 i;
    // 	prefix.push(1);
        // prefix.push(freq[0]);
        uint256 temp = 0;
    	for (i = 0; i < arr.length; ++i) {
    	    
    		prefix.push((temp + freq[i]));
    		temp = temp + freq[i];
    	}

    	// prefix[n-1] is sum of all frequencies.
    	// Generate a random number with
    	// value from 1 to this sum
    // 	uint256 random = 2;//RandomNumber.randomResult();
    	uint256 r = (random / (10) * prefix[n - 1]) + 1;
    
    	// Find index of ceiling of r in prefix array
    	uint256 indexc;// = findCeil(prefix, r, 0, n - 1);
    
    	uint256 mid;
    	uint256 l = 0;
    	uint256 h = n - 1;
    	uint256[] memory arrr = prefix;
    	uint256[] memory mids;
    	while (l < h) {
    		mid = l + ((h - l) >> 1); // Same as mid = (l+h)/2
    		(r > arrr[mid]) ? (l = mid + 1) : (h = mid);
    	}
    
    	indexc = (arrr[l] >= r) ? l : 4;
    
    	return indexc;
        // return prefix;
    }
}