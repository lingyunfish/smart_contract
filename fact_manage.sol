// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract FactManageContract {
    struct Fact {
        string FileHash; 
        string FileName;
        uint256 Time;
    }

    event SaveFile(string indexed fileHash, string indexed fileName, uint256 time);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    // 定义交易结构体
    struct Transaction {
        address from;
        address to;
        uint256 value;
        uint256 timestamp;
        string memo;
    }

    // 用于生成唯一交易ID
    uint256 private transactionIdCounter = 0;

    // 使用 mapping 存储交易记录，key 是 uint256 类型的唯一交易ID
    mapping(uint256 => Transaction) public transactions;

    // 获取交易总数
    function getTransactionCount() public view returns (uint256) {
        return transactionIdCounter;
    }

    // 添加一笔交易到记录中
    function addTransaction(address _from, address _to, uint256 _value, string memory _memo) internal {
        uint256 currentId = transactionIdCounter;
        transactions[currentId] = Transaction({
            from: _from,
            to: _to,
            value: _value,
            timestamp: block.timestamp,
            memo: _memo
        });
        transactionIdCounter++;
        emit Transfer(_from, _to, _value);
    }

    // 根据交易ID获取交易详情
    function getTransaction(uint256 id) public view returns (
        address from, 
        address to, 
        uint256 value, 
        uint256 timestamp
    ) {
        require(id < transactionIdCounter, "Transaction ID out of bounds");
        Transaction memory t = transactions[id];
        return (t.from, t.to, t.value, t.timestamp);
    }

    // 获取交易列表
    function getTransactions() public view returns (Transaction[] memory) {
        uint256 length = transactionIdCounter;
        Transaction[] memory transactionList = new Transaction[](length);
        for (uint256 i = 0; i < length; i++) {
            transactionList[i] = transactions[i];
        }
        return transactionList;
    }


    string public name = "token";      //  token name
    string public symbol = "TK";           //  token symbol
    uint256 public decimals = 6;            //  token digit

    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    uint256 public totalSupply = 0;
    bool public stopped = false;

    uint256 constant valueFounder = 100000000000000000;
    address owner = address(0x0);
    
    // 体验网 constructor不能有参数
    constructor(){
        owner = msg.sender;
        totalSupply = valueFounder;
    }

    mapping(string => Fact) public facts;

    function save(string memory file_hash, string memory file_name, uint256 time) public {
        require(!stringsEquals(file_hash, ""), "fileHash can not be null");
        require(!stringsEquals(file_name, ""), "fileName can not be null");
        facts[file_hash] = Fact({
            FileHash: file_hash,
            FileName: file_name,
            Time: time
        });
        emit SaveFile(file_hash, file_name, time);
    }
    
    function findByFileHash(string memory file_hash) public view returns(string memory, string memory, uint256) {
        Fact memory fact = facts[file_hash];
        return (fact.FileHash, fact.FileName, fact.Time);
    }

    function stringsEquals(string memory s1, string memory s2) private pure returns (bool) {
        bytes memory b1 = bytes(s1);
        bytes memory b2 = bytes(s2);
        uint256 l1 = b1.length;
        if (l1 != b2.length) return false;
        for (uint256 i=0; i<l1; i++) {
            if (b1[i] != b2[i]) return false;
        }
        return true;
    }
    
    modifier isOwner {
        assert(owner == msg.sender);
        _;
    }

    modifier isRunning {
        assert (!stopped);
        _;
    }

    modifier validAddress {
        assert(address(0x0) != msg.sender);
        _;
    }
    function queryAddress() public view returns (address queryM) {
        return msg.sender;
    }


    function queryBalance() public view returns (address sender, uint256 balance) {
        return (msg.sender, balanceOf[msg.sender]);
    }

    function initOwner() public {
        owner = msg.sender;
        totalSupply = valueFounder;
        balanceOf[msg.sender] = valueFounder;
        
        emit Transfer(address(0x0), msg.sender, valueFounder);
    }

    function initUser(address _user, uint256 _value) public {
        balanceOf[_user] = _value;
        emit Transfer(address(0x0), _user, _value);
    }

    function queryUserBalance(address _user) public view returns (address user, uint256 balance) {
        return (_user, balanceOf[_user]);
    }

    function transfer(address _to, uint256 _value, string memory _memo) public isRunning validAddress returns (bool success) {
        require(balanceOf[msg.sender] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;

        addTransaction(msg.sender, _to, _value, _memo);

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public isRunning validAddress returns (bool success) {
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value >= balanceOf[_to]);
        require(allowance[_from][msg.sender] >= _value);
        balanceOf[_to] += _value;
        balanceOf[_from] -= _value;
        allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public isRunning validAddress returns (bool success) {
        require(_value == 0 || allowance[msg.sender][_spender] == 0);
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function stop() public isOwner {
        stopped = true;
    }

    function start() public isOwner {
        stopped = false;
    }

    function setName(string memory _name) public isOwner {
        name = _name;
    }

    function burn(uint256 _value) public {
        require(balanceOf[msg.sender] >= _value);
        balanceOf[msg.sender] -= _value;
        balanceOf[address(0x0)] += _value;
        emit Transfer(msg.sender, address(0x0), _value);
    }


}