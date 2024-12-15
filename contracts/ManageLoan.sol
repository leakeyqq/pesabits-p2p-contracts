// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol"; // Import the IERC20 interface


contract ManageLoan is Ownable {

    using  Counters for Counters.Counter;
    Counters.Counter private _loanIDCounter; // Counter for unique loan IDs
    
    constructor(address initialOwner)
        Ownable(initialOwner) {}

    struct Loan {
        uint loanID;
        address lender;
        address borrower;
        address collateralContract;
        uint collateralAmount;
        string loanCurrency;
        uint256 loanAmount;
        bool isClosed; 
    }
    
    Loan[] public loans;

    event CreatedNewLoan(uint newLoanID, address indexed lender, address indexed borrower, address indexed collateralcontract , uint256 collateralAmount, string loanCurrency, uint256 loanAmount);
    event LoanClosed(uint loanID, address indexed borrower, address indexed lender, uint256 collateralAmount);

    function createNewLoan(address borrower, address lender, address collateralcontract, uint256 collateralAmount, string memory loanCurrency, uint256 loanAmount) external payable onlyOwner{


        // Increment the counter safely
        _loanIDCounter.increment();
        uint newLoanID = _loanIDCounter.current();

        Loan memory newLoan;
        newLoan.loanID = newLoanID;
        newLoan.lender = lender;
        newLoan.borrower = borrower;
        newLoan.collateralContract = collateralcontract;
        newLoan.collateralAmount = collateralAmount;
        newLoan.loanCurrency = loanCurrency;
        newLoan.loanAmount = loanAmount;
        loans.push(newLoan);

        emit CreatedNewLoan(newLoanID, lender,borrower, collateralcontract ,collateralAmount, loanCurrency,loanAmount);
        
    }


    function closeRepaidLoan(uint loanID) external onlyOwner {
        // Find the loan by ID
        require(loanID > 0 && loanID <= loans.length, "Loan ID does not exist");
        
        Loan storage loan = loans[loanID - 1]; // Loan ID is 1-indexed

        // Ensure the loan is not already closed
        require(!loan.isClosed, "Loan is already closed");

        // Mark the loan as closed
        loan.isClosed = true;

        // Transfer ERC20 collateral back to the borrower
        require(
            IERC20(loan.collateralContract).transfer(loan.borrower, loan.collateralAmount),
            "Collateral transfer failed"
        );


        // Emit event for loan closure
        emit LoanClosed(loanID, loan.borrower, loan.lender, loan.collateralAmount);
    }

    

    function getAllLoans() external view returns ( Loan[] memory) {
        return loans;
    }


}