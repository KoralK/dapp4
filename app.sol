// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

contract ProposalContract {
    struct Proposal {
        string title;         // New field for the title of the proposal
        string description;
        uint256 approve;
        uint256 reject;
        uint256 pass;
        uint256 total_vote_to_end;
        bool current_state;
        bool is_active;
    }

    mapping(uint256 => Proposal) public proposal_history;
    uint256 public nextProposalId; // Variable to track the next proposal ID

    address public owner; // Address of the contract owner

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    constructor() {
        owner = msg.sender; // Set the contract creator as the owner
    }

    // Adjusted function to create a new proposal with title
    function createProposal(string memory _title, string memory _description, uint256 _voteLimit) public onlyOwner {
        proposal_history[nextProposalId] = Proposal({
            title: _title,
            description: _description,
            approve: 0,
            reject: 0,
            pass: 0,
            total_vote_to_end: _voteLimit,
            current_state: false,
            is_active: true
        });
        nextProposalId++; // Increment the proposal ID for the next proposal
    }
// Voting function
    function vote(uint256 _proposalId, bool _approve, bool _reject, bool _pass) public {
        require(proposal_history[_proposalId].is_active, "Proposal is not active");
        require(_approve != _reject && _approve != _pass, "Invalid vote");

        // Update vote counts based on the user's vote
        if (_approve) {
            proposal_history[_proposalId].approve++;
        } else if (_reject) {
            proposal_history[_proposalId].reject++;
        } else if (_pass) {
            proposal_history[_proposalId].pass++;
        }

        // Check if the proposal should end
        if (proposal_history[_proposalId].approve + proposal_history[_proposalId].reject + proposal_history[_proposalId].pass >= proposal_history[_proposalId].total_vote_to_end) {
            proposal_history[_proposalId].is_active = false;
            // Update current_state based on the votes
            proposal_history[_proposalId].current_state = proposal_history[_proposalId].approve > proposal_history[_proposalId].reject;
        }
    }

    // Function to get the vote counts for a specific proposal
    function getVoteCounts(uint256 _proposalId) public view returns (uint256 approveCount, uint256 rejectCount, uint256 passCount) {
        Proposal storage proposal = proposal_history[_proposalId];
        return (proposal.approve, proposal.reject, proposal.pass);
    }

    // Function to get the current state of a proposal
    function getProposal(uint256 _proposalId) public view returns (Proposal memory) {
        return proposal_history[_proposalId];
    }
}