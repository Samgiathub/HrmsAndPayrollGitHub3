using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0210MonthlyLoanPayment
{
    public decimal? LoanId { get; set; }

    public string? LoanName { get; set; }

    public decimal? LoanAprDeductFromSal { get; set; }

    public decimal? LoanAprPendingAmount { get; set; }

    public string? EmpFirstName { get; set; }

    public string? EmpFullName { get; set; }

    public decimal? EmpId { get; set; }

    public string? LoanAprCode { get; set; }

    public decimal LoanPayId { get; set; }

    public decimal LoanAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? SalTranId { get; set; }

    public decimal LoanPayAmount { get; set; }

    public string LoanPayComments { get; set; } = null!;

    public DateTime LoanPaymentDate { get; set; }

    public string LoanPaymentType { get; set; } = null!;

    public string BankName { get; set; } = null!;

    public string LoanChequeNo { get; set; } = null!;

    public string? EmpLeft { get; set; }

    public string? BranchName { get; set; }

    public decimal? BranchId { get; set; }

    public decimal? TempSalTranId { get; set; }

    public decimal InterestAmount { get; set; }

    public decimal IsLoanInterestFlag { get; set; }

    public string? LoanShortName { get; set; }
}
