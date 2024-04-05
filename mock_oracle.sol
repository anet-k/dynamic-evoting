pragma solidity >=0.8.0 <0.9.0;

contract MockOracle {
    bool public result;
    string public data;

    function setResponse(bool _result, string memory _data) public {
        result = _result;
        data = _data;
    }
}