// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

// Errors
// error Election__NotOwner(address sender, string error);
error Election__NoCandidateWithGivenId(uint256 id);

contract Election {
    // type declarations
    struct Candidate {
        uint256 id;
        string name;
        string partyName;
        string imageUrl;
        uint256 votes;
    }

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
        require(msg.sender == i_owner, "You are not the owner!");
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

    modifier electionHasNotStarted() {
        require(!s_hasStarted, "Election has already started!");
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
        emit electionStarted();
        emptyCandidates();
        setCandidates();
    }

    function endElection() public onlyOwner {
        require(s_hasStarted == true, "Already ended!");
        emit electionEnded();
        s_hasStarted = false;
    }

    // not really needed right now
    function addVoter() public {
        s_voters.push(msg.sender);
    }

    function voteToCandidate(uint256 id) public electionHasStarted onlyOnce {
        s_voterToCandidateId[msg.sender] = id;
        uint256 candidateIndex = getCandidateIndex(id);
        s_candidates[candidateIndex].votes++;
        emit voteCasted(s_candidates[candidateIndex]);
    }

    function addCandidates(
        uint256 id,
        string calldata name,
        string calldata partyName
    )
        public
        // string calldata imageUrl
        onlyOwner
        electionHasNotStarted
    {
        s_candidates.push(
            Candidate({
                id: id,
                name: name,
                partyName: partyName,
                imageUrl: "https://picsum.photos/400",
                votes: 0
            })
        );
    }

    function removeCandidate(
        uint256 id
    ) public onlyOwner electionHasNotStarted {
        uint256 delIndex = getCandidateIndex(id);

        if (delIndex >= s_candidates.length) {
            revert Election__NoCandidateWithGivenId(id);
        }

        for (uint256 i = delIndex; i < s_candidates.length - 1; i++) {
            s_candidates[i] = s_candidates[i + 1];
        }
        s_candidates.pop();
    }

    // private
    function setCandidates() private {
        for (uint256 i = 0; i < 5; i++) {
            s_candidates.push(
                Candidate({
                    id: i + 1,
                    name: "Name",
                    partyName: "party",
                    imageUrl: "https://picsum.photos/400",
                    votes: 0
                })
            );
        }
    }

    function emptyCandidates() private {
        delete s_candidates;
    }

    function getCandidateIndex(uint256 id) private view returns (uint256) {
        Candidate[] memory candidatesList = s_candidates;
        for (uint256 i = 0; i < candidatesList.length; i++) {
            Candidate memory cand = candidatesList[i];
            if (cand.id == id) {
                return i;
            }
        }
        revert Election__NoCandidateWithGivenId(id);
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
    ) public view electionHasStarted returns (Candidate memory candidate) {
        Candidate[] memory candidatesList = s_candidates;
        for (uint256 i = 0; i < candidatesList.length; i++) {
            Candidate memory cand = candidatesList[i];
            if (cand.id == id) {
                return cand;
            }
        }
        revert Election__NoCandidateWithGivenId(id);
    }
}
