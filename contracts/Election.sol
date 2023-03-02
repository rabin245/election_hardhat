// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// Errors
error Election__NotOwner(address sender, string error);

contract Election {
    // type declarations
    struct Candidate {
        uint256 id;
        string name;
        uint256 votes;
    }

    // struct Voter{
    //     address voterAddress;
    //     bool hasVoted;
    // }

    // state variables
    Candidate[] private s_candidates;
    address[] private s_voters;
    bool private s_hasStarted;
    mapping(address => uint256) private s_voterToCandidateId;
    address private immutable i_owner;

    // Events
    event voteCasted(Candidate updatedCandidate);

    event electionStarted();

    event electionEnded();

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert Election__NotOwner({
                sender: msg.sender,
                error: "You are not the owner!"
            });
        }
        _; // run rest of the lines
    }

    modifier onlyOnce() {
        require(
            s_voterToCandidateId[msg.sender] == 0,
            "Voter has already voted!"
        );
        _;
    }

    modifier electionHasStarted() {
        require(s_hasStarted, "Election has not started yet!");
        _;
    }

    // constructor
    constructor() {
        i_owner = msg.sender;
        s_hasStarted = false;
    }

    // public
    function startElection() public onlyOwner {
        require(s_hasStarted == false, "Already started!");
        s_hasStarted = true;
        emptyCandidates();
        setCandidates();
        emit electionStarted();
    }

    function endElection() public onlyOwner {
        require(s_hasStarted == true, "Already ended!");
        s_hasStarted = false;
        emit electionEnded();
    }

    // not really needed right now
    function addVoter() public {
        s_voters.push(msg.sender);
    }

    function voteToCandidate(uint256 id) public onlyOnce electionHasStarted {
        s_voterToCandidateId[msg.sender] = id;
        s_candidates[id - 1].votes++;
        emit voteCasted(s_candidates[id - 1]);
    }

    // private
    function setCandidates() private {
        for (uint256 i = 0; i < 5; i++) {
            s_candidates.push(Candidate({id: i + 1, name: "Name", votes: 0}));
        }
    }

    function emptyCandidates() private {
        delete s_candidates;
    }

    // view / pure
    function hasVoted() public view returns (bool) {
        return s_voterToCandidateId[msg.sender] == 0 ? false : true;
    }

    function getHasStarted() public view returns (bool) {
        return s_hasStarted;
    }

    function getCurrentVoterToCandidateId()
        public
        view
        returns (address, uint256)
    {
        return (msg.sender, s_voterToCandidateId[msg.sender]);
    }

    function getVoters() public view returns (address[] memory) {
        return s_voters;
    }

    function getCandidates() public view returns (Candidate[] memory) {
        return s_candidates;
    }

    function getCandidate(
        uint256 id
    ) public view electionHasStarted returns (Candidate memory) {
        return s_candidates[id - 1];
    }
}
