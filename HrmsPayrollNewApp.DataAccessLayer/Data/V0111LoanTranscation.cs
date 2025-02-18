using System;
using System.Collections.Generic;

namespace HrmsPayrollNewApp.DataAccessLayer.Data;

public partial class V0111LoanTranscation
{
    public string LoanName { get; set; } = null!;

    public decimal LoanTranId { get; set; }

    public decimal CmpId { get; set; }

    public decimal LoanId { get; set; }

    public decimal EmpId { get; set; }

    public DateTime ForDate { get; set; }

    public decimal LoanOpening { get; set; }

    public decimal LoanIssue { get; set; }

    public decimal LoanReturn { get; set; }

    public decimal LoanClosing { get; set; }

    public decimal Expr2 { get; set; }

    public decimal Expr1 { get; set; }

    public decimal Expr3 { get; set; }

    public decimal Expr4 { get; set; }

    public DateTime Expr5 { get; set; }

    public decimal Expr6 { get; set; }

    public decimal Expr7 { get; set; }

    public decimal Expr8 { get; set; }

    public decimal Expr9 { get; set; }

    public decimal? LoanAppId { get; set; }

    public string LoanAprCode { get; set; } = null!;
}
