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
    Candidate[] private s_recentResults;

    uint256[] private s_electionsTimeList;
    mapping(uint256 => Candidate[]) private s_electionTimeToResults;

    // Events
    event VoteCasted(Candidate updatedCandidate);

    event ElectionStarted();

    event ElectionEnded();

    event CandidateAdded(Candidate candidate);

    event CandidateRemoved(uint256 id);

    event CandidateListEmptied();

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
    function startElection(
        uint256 electionTime
    ) public onlyOwner electionHasNotStarted {
        s_hasStarted = true;
        clearVoterToCandidateId();
        clearVotes();
        // clear voters
        // reset the votes of all the candidates
        removeRecentResults();
        addElectionTime(electionTime);
        emit ElectionStarted();
    }

    function endElection() public onlyOwner electionHasStarted {
        s_hasStarted = false;
        saveRecentResults();

        uint256[] memory electionsTimeList = s_electionsTimeList;
        uint256 lastIndex = electionsTimeList.length - 1;
        saveElectionResult(electionsTimeList[lastIndex]);

        emit ElectionEnded();
    }

    function voteToCandidate(uint256 id) public electionHasStarted onlyOnce {
        s_voters.push(msg.sender);
        s_voterToCandidateId[msg.sender] = id;
        uint256 candidateIndex = getCandidateIndex(id);
        s_candidates[candidateIndex].votes++;
        emit VoteCasted(s_candidates[candidateIndex]);
    }

    function addCandidate(
        uint256 id,
        string calldata name,
        string calldata partyName,
        string calldata imageUrl
    ) public onlyOwner electionHasNotStarted {
        Candidate memory candidate = Candidate({
            id: id,
            name: name,
            partyName: partyName,
            imageUrl: imageUrl,
            votes: 0
        });

        s_candidates.push(candidate);
        emit CandidateAdded(candidate);
    }

    function removeCandidate(
        uint256 id
    ) public onlyOwner electionHasNotStarted {
        uint256 delIndex = getCandidateIndex(id);

        Candidate[] storage candidatesList = s_candidates;

        if (delIndex >= candidatesList.length) {
            revert Election__NoCandidateWithGivenId(id);
        }

        emit CandidateRemoved(id);

        for (uint256 i = delIndex; i < candidatesList.length - 1; i++) {
            candidatesList[i] = candidatesList[i + 1];
        }
        candidatesList.pop();

        s_candidates = candidatesList;
    }

    function emptyCandidates() public onlyOwner electionHasNotStarted {
        delete s_candidates;
        emit CandidateListEmptied();
    }

    // private
    function getCandidateIndex(uint256 id) private view returns (uint256) {
        Candidate[] memory candidatesList = s_candidates;
        for (uint256 i = 0; i < candidatesList.length; i++) {
            if (candidatesList[i].id == id) {
                return i;
            }
        }
        revert Election__NoCandidateWithGivenId(id);
    }

    function clearVotes() private {
        Candidate[] storage candidatesList = s_candidates;
        for (uint256 i = 0; i < candidatesList.length; i++) {
            candidatesList[i].votes = 0;
        }
        s_candidates = candidatesList;
    }

    function clearVoterToCandidateId() private {
        for (uint256 i = 0; i < s_voters.length; i++) {
            delete s_voterToCandidateId[s_voters[i]];
        }
        delete s_voters;
    }

    function saveRecentResults() private {
        s_recentResults = s_candidates;
    }

    function removeRecentResults() private {
        delete s_recentResults;
    }

    function addElectionTime(uint256 electionTime) private {
        s_electionsTimeList.push(electionTime);
    }

    function saveElectionResult(uint256 electionTime) private {
        s_electionTimeToResults[electionTime] = s_candidates;
    }

    // view / pure
    function getHasVoted() public view returns (bool) {
        return s_voterToCandidateId[msg.sender] == 0 ? false : true;
    }

    function getHasStarted() public view returns (bool) {
        return s_hasStarted;
    }

    function getCurrentVoterToCandidateId() public view returns (uint256) {
        return s_voterToCandidateId[msg.sender];
    }

    function getCandidates() public view returns (Candidate[] memory) {
        return s_candidates;
    }

    function getRecentResults() public view returns (Candidate[] memory) {
        return s_recentResults;
    }

    function getElectionsTimeList() public view returns (uint256[] memory) {
        return s_electionsTimeList;
    }

    function getElectionTimeToResult(
        uint256 electionTime
    ) public view returns (Candidate[] memory) {
        return s_electionTimeToResults[electionTime];
    }
}
