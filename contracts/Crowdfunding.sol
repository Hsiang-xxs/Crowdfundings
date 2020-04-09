pragma solidity >=0.4.21 <0.7.0;


contract Crowdfunding {
    // author
    address public author;

    // joined amount
    mapping(address => uint) public joined;

    // crowdfunding target
    uint constant Target = 10 ether;

    uint public endTime;

    // record current crowdfunding price
    uint public price  = 0.02 ether ;

    // end crowdfunding, after author withdraw funds
    bool public closed = false;

    // address[] joinAccouts;
    event Join(address indexed user, uint price);

    constructor() public {
        author = msg.sender;
        endTime = now + 30 days;
    }

    // update price
    function updatePrice() internal {
        uint rise = address(this).balance / 1 ether * 0.002 ether;
        price = 0.02 ether + rise;
    }

    function () external payable {
        require(now < endTime && !closed  , "众筹已结束");
        require(joined[msg.sender] == 0 , "你已经参与过众筹");

        require (msg.value >= price, "出价太低了");
        joined[msg.sender] = msg.value;
        
        updatePrice();
        
        emit Join(msg.sender, msg.value);     //  48820  gas
        // joinAccouts.push(msg.sender);   // 88246  gas 
    } 

    // author withdraw funds
    function withdrawFund() external {
        require(msg.sender == author, "你不是作者");
        require(address(this).balance >= Target, "未达到众筹目标");
        closed = true;   
        msg.sender.transfer(address(this).balance);
    }

    // reader withdraw funds
    function withdraw() external {
        require(now > endTime, "还未到众筹结束时间");
        require(!closed, "众筹达标，众筹资金已提取");
        require(Target > address(this).balance, "众筹达标，你没法提取资金");
        
        msg.sender.transfer(joined[msg.sender]);
    }

}