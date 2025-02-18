using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class TmpLoanPay
{
    public decimal LoanPayId { get; set; }

    public decimal LoanAprId { get; set; }

    public decimal CmpId { get; set; }

    public decimal? SalTranId { get; set; }

    public decimal? SSalTranId { get; set; }

    public decimal? LSalTranId { get; set; }

    public decimal LoanPayAmount { get; set; }

    public string LoanPayComments { get; set; } = null!;

    public DateTime LoanPaymentDate { get; set; }

    public string LoanPaymentType { get; set; } = null!;

    public string BankName { get; set; } = null!;

    public string LoanChequeNo { get; set; } = null!;

    public string? LoanPayCode { get; set; }

    public decimal? TempSalTranId { get; set; }

    public decimal InterestPercent { get; set; }

    public decimal InterestAmount { get; set; }

    public decimal InterestSubsidyAmount { get; set; }

    public decimal IsLoanInterestFlag { get; set; }

    public decimal IsSubsidyFlag { get; set; }

    public decimal SubsidyAmount { get; set; }

    public decimal? TempLoanPayId { get; set; }

    public decimal IsSubsidyLoan { get; set; }
}
